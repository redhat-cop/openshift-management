# Jobs

This directory contains a collection of [jobs](https://docs.openshift.com/container-platform/latest/dev_guide/jobs.html) and [Cron jobs](https://docs.openshift.com/container-platform/latest/dev_guide/cron_jobs.html).

The rest of this document describes the specific configurations that are applicable to the execution of certain jobs contained within this directory.

### Git Backup

The [cronjob-git-sync.json](cronjob-git-sync.json) backs up one repository to another repository with all of it's branches on a regular basis.

Prior to instantiating the template, the following must be completed:

1. Two repositories created.

2. [SSH key created](https://help.github.com/articles/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent/) and put into base64 form for the `GIT_PRIVATE_KEY` param. Which can be done using:

	```
	cat <private_key> | base64
	```

2. The repository that will be pushed to, needs to have the public key added.

3. Instantiate the template

    ```
    oc process --param-file=params -f <template_file> | oc create -f-
    ```

   where the parameters file might look like this:
    ```
    GIT_PRIVATE_KEY=GIANTENCODEDSTRINGHERE
    GIT_HOST=github.com
    GIT_REPO=pcarney8/example.git
    GIT_SYNC_HOST=gitlab.com
    GIT_SYNC_PORT=2222
    GIT_SYNC_REPO=pcarney8/example-backup.git
    SCHEDULE=*/5 * * * *
    JOB_NAME=example-backup-job
    ```

### Pruning Resources

The [cronjob-prune-images.yml](cronjob-prune-images.yml) facilitates [image pruning](https://docs.openshift.com/container-platform/latest/admin_guide/pruning_resources.html#pruning-images) of the integrated docker registry while the [cronjob-prune-builds-deployments.yml](cronjob-prune-builds-deployments.yml) facilitates pruning [builds](https://docs.openshift.com/container-platform/latest/admin_guide/pruning_resources.html#pruning-builds) and [deployments](https://docs.openshift.com/container-platform/latest/admin_guide/pruning_resources.html#pruning-deployments) on a regular basis.

To instantiate the template, run the following.

1. Create a project in which to host your jobs.
	```
	oc new-project <project>
	```

2. Instantiate the template
```
oc process -f <template_file> \
-p NAMESPACE="<project name from previous step>"
-p JOB_SERVICE_ACCOUNT=pruner  | oc create -f-
```

*Note: Some templates require additional parameters to be specified. Be sure to review each specific template contents prior to instantiation*

### LDAP Group Synchronization

The [cronjob-ldap-group-sync.yml](cronjob-ldap-group-sync.yml) facilitates routine [LDAP Group Synchronization](https://docs.openshift.com/container-platform/latest/install_config/syncing_groups_with_ldap.html) synchronize groups defined in an LDAP store with OpenShift's internal group storage facility.

This template makes several assumptions about your LDAP architecture and intentions of your group sync process, and is meant to showcase a common use case seen in the field. It will likely need further updating to accommodate other sync strategies or LDAP architectures.

In this case, we use a top level group to designate all users and groups that will have access to OpenShift. We then create child groups to designate users who should have certain capabilities in OpenShift. A sample tree structure might look like:

```
openshift-users
 - cluster-admins
   * bob
 - app-team-a-devs
   * alice
   * suzie
```

We'll build a filter to return these groups in LDAP. Something like:
```
(&(objectclass=ipausergroup)(memberOf=cn=openshift-users,cn=groups,cn=accounts,dc=myorg,dc=example,dc=com))
```

#### Setup

The `cronjob-ldap-group-sync` template creates several objects in OpenShift.

* A custom `ClusterRole` that defines the proper permissions to do a group sync
* A `ServiceAccount` we will use to run the group sync
* A `ClusterRoleBinding` that maps the `ServiceAccount` to the `ClusterRole`
* A `ConfigMap` containing the `LDAPSyncConfig` [configuration file](https://docs.openshift.com/container-platform/latest/install_config/syncing_groups_with_ldap.html#configuring-ldap-sync).
* A `CronJob` to run the LDAP Sync on a schedule

To instantiate the template, run the following.

1. Create a project in which to host your jobs.
	```
	oc new-project <project>
	```
2. Instantiate the template
	```
	oc process -f jobs/cronjob-ldap-group-sync.yml \
	  -p NAMESPACE="<project name from previous step>"
	  -p LDAP_URL="ldap://idm-2.etl.rht-labs.com:389" \
	  -p LDAP_BIND_DN="uid=ldap-user,cn=users,cn=accounts,dc=myorg,dc=example,dc=com" \
		-p LDAP_BIND_PASSWORD="password1" \
		-p LDAP_GROUPS_SEARCH_BASE="cn=groups,cn=accounts,dc=myorg,dc=example,dc=com" \
		-p LDAP_GROUPS_FILTER="(&(objectclass=ipausergroup)(memberOf=cn=ose_users,cn=groups,cn=accounts,dc=myorg,dc=example,dc=com))" \
		-p LDAP_USERS_SEARCH_BASE="cn=users,cn=accounts,dc=myorg,dc=example,dc=com" \
		| oc create -f-
	```

#### Cleanup

You can clean up the objects created by the template with the following command.

```
oc delete cronjob,configmap,clusterrole,clusterrolebinding,sa -l template=cronjob-ldap-group-sync
```
