# Jobs

This directory contains a collection of [jobs](https://docs.openshift.com/container-platform/latest/dev_guide/jobs.html) and [scheduled jobs](https://docs.openshift.com/container-platform/latest/dev_guide/scheduled_jobs.html).

The rest of this document describes the specific configurations that are applicable to the execution of certain jobs contained within this directory.

### [scheduledjob-prune-images.json](scheduledjob-prune-images.json)

Executes [image pruning](https://docs.openshift.com/container-platform/latest/admin_guide/pruning_resources.html#pruning-images) of the integrated docker registry on a regular basis.

Prior to instantiating the template, the following must be completed within a project:

1. Create a new service account

	```
	oc create serviceaccount pruner`
	```

2. Grant cluster *edit* permissions on the service account created previously (requires elevated rights)

	```
	oc adm policy add-cluster-role-to-user edit system:serviceaccount:<project-name>:pruner`
	```

Instantiate the template

```
oc process -v= JOB_SERVICE_ACCOUNT=pruner -f scheduledjob-prune-images.json | oc create -f-
```



