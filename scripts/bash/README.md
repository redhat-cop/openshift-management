# OpenShift Admin Bash Scripts

This folder contains a collection of script to administer, diagnose, and troubleshoot issues in OpenShift.

These scripts can be run natively on the superior Linux OS, or MacOS.  Windows requires using a bash emulator (GitBash).

## Script Overview

The following table outlines the scripts and purpose.

Script Name | Description | Notes
--- | --- | ---
`cleanup-builds.sh` | Deletes builds older than 30 days. | Parameters required, check script doc.
`create-pvs.sh` | Creates a block of NFS based PVs. | Parameters required, check script doc.
`delete-dead-pods.sh` | Deletes all the dead or completed pods on the cluster. | Parameters and auth required, check script doc.
`delete-expired-replication-controllers.sh` | Deletes all RC's older than 60 days. | Parameters and auth required, check script doc.
`elasticsearch-health-check-ocp33.sh` | Returns the health of the integrated ES cluster. Only works on OCP =< 3.3  | Parameters and auth required, check script doc.
`elasticsearch-health-check-ocp34.sh` | Returns the health of the integrated ES cluster. Only works on OCP >= 3.4  | Parameters and auth required, check script doc, and will not work on GitBash (Windows).
`metrics-health-check.sh` | Checks if the metrics stack is up and running. | Parameters and auth required, check script doc.
`ocp-etcd.sh` | Returns the health or leader the of etcd cluster. | Must be run on an OCP master node.
`ocp-etcd-master-backup.sh` | Creates an etcd backup. | Must be run on an OCP master node.
`ocp-master-cert-backup.sh` | Creates a backup of the master certificates. | Must be run on an OCP master node.
`ocp-project-backup.sh` | Creates a yaml backup of all projects in the OpenShift cluster. | Must be run on an OCP master node.
