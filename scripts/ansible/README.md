# OpenShift Admin Ansible Playbooks

This folder contains a collection of script to administer, diagnose, and troubleshoot issues in OpenShift.

These scripts where written to run on the jump box associated with the OpenShift cluster.

## Playbook Overview

The following table outlines the playbook and purpose.

Playbook Name | Description
--- | ---
`etcd-backup.yaml` | Ansible clone of the bash `ocp-etcd-master-backup.sh` script.
`master-backup.yaml` | Ansible clone of the bash `ocp-master-cert-backup.sh` script.
