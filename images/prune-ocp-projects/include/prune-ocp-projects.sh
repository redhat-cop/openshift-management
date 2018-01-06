#!/bin/bash

# Make sure to declare these two environment variables to prevent projects to be deleted
# The values should be set as a quoted list of projects - i.e:
# 'default openshift openshift-infra'
#PROJECT_EXCLUDE_SYSTEM
#PROJECT_EXCLUDE_USER

# Use an indexed array to keep track of existing projects
declare -A projects

for project in `oc get project -o=custom-columns=NAME:.metadata.name --no-headers`;
do
  projects["${project}"]="found"
done

# Eliminate the "System projects"
if [ -n "${PROJECT_EXCLUDE_SYSTEM}" ];
then
  for project in ${PROJECT_EXCLUDE_SYSTEM};
  do
    unset projects["${project}"]
  done
fi

# Eliminate the "User projects"
if [ -n "${PROJECT_EXCLUDE_USER}" ];
then
  for project in ${PROJECT_EXCLUDE_USER};
  do
    unset projects["${project}"]
  done
fi

# Capture the timestamp for each project and only delete projects older
# than the set number of hours
for project in "${!projects[@]}";
do
  # need variable for time
  purgetime=`date -d "${TIMESTAMP_HOURS_AGO}" +%s`
  temp=`oc get project ${project} -o=custom-columns=time:.metadata.creationTimestamp --no-headers`
  projects[${project}]=`date -d "${temp}" +%s`

  if [ ${purgetime} -gt ${projects[${project}]} ];
  then
     echo "Deleting project ${project}"
     oc delete project ${project}
  fi
done
