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

Prior to instantiating the template, the following must be completed within a project:

1. Create a new service account

	```
	oc create serviceaccount sync
	```

2. Grant cluster *cluster-admin* permissions on the service account created previously (requires elevated rights)

	```
	oc adm policy add-cluster-role-to-user cluster-admin system:serviceaccount:<project-name>:sync
	```

3. Configure the LDAP sync configuration file

Synchronizing groups into OpenShift from LDAP requires a [configuration file](https://docs.openshift.com/container-platform/latest/install_config/syncing_groups_with_ldap.html#configuring-ldap-sync) be provided to drive the entire synchronization process. The file will be stored in a [ConfigMap](https://docs.openshift.com/container-platform/latest/dev_guide/configmaps.html) and injected into the running container when the job is executed.

Define the synchronization configuration in a file called *ldap-group-sync.yaml*

Create a new ConfigMap called *ldap-sync* using the previously defined file:

```
oc create configmap ldap-sync --from-file=ldap-group-sync.yaml=ldap-group-sync.yaml
```

4. Instantiate the template

```
oc process -v=JOB_SERVICE_ACCOUNT=sync -v=CONFIGMAP_NAME=ldap-sync -v=CONFIGMAP_KEY=ldap-group-sync.yaml -f scheduledjob-ldap-group-sync.json | oc create -f-
```