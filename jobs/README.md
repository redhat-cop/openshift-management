# Jobs

This directory contains a collection of [jobs](https://docs.openshift.com/container-platform/latest/dev_guide/jobs.html) and [scheduled jobs](https://docs.openshift.com/container-platform/latest/dev_guide/scheduled_jobs.html).

The rest of this document describes the specific configurations that are applicable to the execution of certain jobs contained within this directory.

### Pruning Resources

The [scheduledjob-prune-images.json](scheduledjob-prune-images.json) facilitates [image pruning](https://docs.openshift.com/container-platform/latest/admin_guide/pruning_resources.html#pruning-images) of the integrated docker registry while the [scheduledjob-prune-builds-deployments.json](scheduledjob-prune-builds-deployments.json) facilitates pruning [builds](https://docs.openshift.com/container-platform/latest/admin_guide/pruning_resources.html#pruning-builds) and [deployments](https://docs.openshift.com/container-platform/latest/admin_guide/pruning_resources.html#pruning-deployments) on a regular basis.

Prior to instantiating the template, the following must be completed within a project:

1. Create a new service account

	```
	oc create serviceaccount pruner
	```

2. Grant cluster *cluster-admin* permissions on the service account created previously (requires elevated rights)

	```
	oc adm policy add-cluster-role-to-user cluster-admin system:serviceaccount:<project-name>:pruner
	```

3. Instantiate the template

```
oc process -v=JOB_SERVICE_ACCOUNT=pruner -f <template_file> | oc create -f-
```

*Note: Some templates require additional parameters to be specified. Be sure to review each specific template contents prior to instantiation*

### LDAP Group Synchronization

The [scheduledjob-ldap-group-sync.json](scheduledjob-ldap-group-sync.json) facilitates routine [LDAP Group Synchronization](https://docs.openshift.com/container-platform/3.4/install_config/syncing_groups_with_ldap.html) synchronize groups defined in an LDAP store with OpenShift's internal group storage facility.

This template makes several assumptions about your LDAP architecture and intentions of your group sync process, and is meant to showcase a common use case seen in the field. In this case, we use a top level group to designate all users and groups that will have access to OpenShift. We then create child groups to designate users who should have certain capabilities in OpenShift. A sample tree structure might look like:

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

The `scheduledjob-ldap-group-sync` template creates several objects in OpenShift.

* A custom `ClusterRole` that defines the proper permissions to do a group sync
* A `ServiceAccount` we will use to run the group sync
* A `ClusterRoleBinding` that maps the `ServiceAccount` to the `ClusterRole`
* A `ConfigMap` containing the `LDAPSyncConfig` [configuration file](https://docs.openshift.com/container-platform/latest/install_config/syncing_groups_with_ldap.html#configuring-ldap-sync).
* A `ScheduledJob` to run the LDAP Sync on a schedule

To instantiate the template, run the following.

1. Create a project in which to host your jobs.
	```
	oc new-project cluster-ops
	```
2. Instantiate the template

```
oc process -f jobs/scheduledjob-ldap-group-sync.yml \
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
oc delete scheduledjob,configmap,clusterrole,clusterrolebinding,sa -l template=scheduledjob-ldap-group-sync
```
