import os
import json
import requests
import datetime
import logging
import math

currentTime = datetime.datetime.now()

logging.basicConfig(level="INFO")
logger = logging.getLogger("com.redhat.labs")
logger.setLevel(os.environ.get('LOG_LEVEL', 'INFO'))

gitlab_api_url = '/api/v4'
git_base_url = os.environ.get('GITLAB_API_URL')
git_token = os.environ.get('GIT_TOKEN')
parent_group_id = os.environ.get('PARENT_GROUP_ID')
delete_after_hours_string = os.environ.get('DELETE_AFTER_HOURS')
delete_after_hours = 2147483647 # default but line above must be set and is enforced
dry_run = os.environ.get('DRY_RUN').lower() == 'true'

def check_env_vars():
    if parent_group_id is None:
        raise ValueError('OMP Parent Group (PARENT_GROUP_ID) is required')
    if not parent_group_id.isnumeric():
        raise ValueError('OMP Parent Group (PARENT_GROUP_ID) has an invalid value of ' + parent_group)
    if not git_token:
        raise ValueError('Git Token (GIT_TOKEN) is required')
    if not git_base_url:
        raise ValueError('Git Url base url (GITLAB_API_URL) is required (eg. https://gitlab.com)')
    if not delete_after_hours_string:
        raise ValueError('You must set a time period to delete projects (DELETE_AFTER_HOURS)')
    if not delete_after_hours_string.isnumeric():
        raise ValueError('You must set a time period to delete projects (DELETE_AFTER_HOURS)')

# clean groups and projects at our below this level of the group hierarchy
# uses a staleness time measure to decide whether to delete
# if a group has no projects or subgroups it should also be deleted
# careful - recursion in use
def clean_group(group_id, group_name):
    # let's us know if the group represented by group_id was deleted. This is the return value
    cleanGroupDeleted = False

    logger.debug(f'clean group {group_id} - {group_name}')

    subgroups = find_subgroups(group_id)
    subgroup_count = len(subgroups)

    for subgroup in subgroups:
        if 'DO_NOT_DELETE' in subgroup['description']:
            logger.info(f"Group {subgroup['name']} with subgroups and projects are not eligible for deletion")
        else:
            deleted = clean_group(subgroup['id'], subgroup['name'])
            logger.debug(f"subgroup {subgroup['name']}")
            if deleted:
                subgroup_count -= 1

    projects = find_projects(group_id)
    all_projects_deleted = True
    for project in projects:
        if is_project_stale(project):
            delete_project(project)
        else:
            all_projects_deleted = False

    if subgroup_count == 0 and all_projects_deleted:
        cleanGroupDeleted = delete_group(group_id, group_name)

    logger.debug(f'clean group {group_id} finished')
    return cleanGroupDeleted

# end clean_group

# returns a list of subgroups for the super group_id
def find_subgroups(group_id):
    logger.debug(f'find subgroups {group_id}')

    response = requests.get(
        f'{git_base_url}{gitlab_api_url}/groups/{group_id}/subgroups',
        headers={"PRIVATE-TOKEN": git_token, 'Content-Type': 'application/json'},
    )

    if response.status_code == 200:
        return json.loads(response.text);
    if response.status_code == 401:
        raise ValueError('Git Token is not valid')

    return []
# end find_groups

def find_projects(group_id):
    logger.debug(f'find projects {group_id}')

    response = requests.get(
        f'{git_base_url}{gitlab_api_url}/groups/{group_id}/projects',
        headers={"PRIVATE-TOKEN": git_token, 'Content-Type': 'application/json'},
    )
    projects = json.loads(response.text)

    logger.debug(f'project count = {len(projects)}')
    return projects
# end find_projects

def delete_group(group_id, group_name):
    if(group_name == 'PARENT'):
        return False;

def delete_group(group_id, group_name):
    logger.info(f'delete group {group_id} {group_name} dry-run {dry_run}')

    if not dry_run:
        response = requests.delete(
            f'{git_base_url}{gitlab_api_url}/groups/{group_id}',
            headers={"PRIVATE-TOKEN": git_token},
        )

        if response.status_code == 202:
            logger.warn(f"deleted group {group_id}")
            return True

        logger.error(f"Failed to delete group {group_id} code {response.status}")

    return False
# end delete_group

def delete_project(project):
    project_id = project['id']
    logger.info(f"delete project {project_id} { project['name']} dry-run {dry_run}")

    if not dry_run:
        response = requests.delete(
            f"{git_base_url}{gitlab_api_url}/projects/{project_id}",
            headers={"PRIVATE-TOKEN": git_token},
        )

        if response.status_code == 202:
            logger.warn(f"deleted project {project_id} { project['name']} ")
            return True

        logger.error(f"Failed to delete project {project_id} { project['name']}  code {response.status}")

    return False
#end delete_project

# a job is considered stale if the amount of time that has occurred since its last activity is greater than the threshold amount of hours set in the env
def is_project_stale(project):
    shouldDelete = False

    logger.debug(f"is_project stale {project['path_with_namespace']}")

    doNotDeleteInDesc = project['description'] is not None and 'DO_NOT_DELETE' in project['description']

    if doNotDeleteInDesc or 'DO_NOT_DELETE' in project['tag_list']:
        logger.info(f"Project {project['path_with_namespace']} is not eligible for deletion")
        return shouldDelete

    lastActivity = datetime.datetime.strptime(project['last_activity_at'], '%Y-%m-%dT%H:%M:%S.%fZ')
    passedTime = currentTime - lastActivity
    elapsed_hours = passedTime.total_seconds() / 3600
    logger.debug(f"Last Activity {lastActivity:%b %d %Y} : Total Hours = { int(elapsed_hours) } (threshold = {delete_after_hours}) - {project['path_with_namespace']}")
    
    if elapsed_hours > delete_after_hours:
        logger.info(f"Stale repository found. Last Activity {lastActivity:%b %d %Y}  : Total Hours = { int(elapsed_hours) } (threshold = {delete_after_hours}) - {project['path_with_namespace']}")
        shouldDelete = True

    return shouldDelete
# end is_project_stale

check_env_vars()

if(dry_run):
   logger.info('In dry-run mode. No deletes will occur')

delete_after_hours = int(delete_after_hours_string)
logger.info("Delete projects after %i hours", delete_after_hours)

clean_group(parent_group_id, "PARENT")

logger.info("Gitlab clean up complete")
