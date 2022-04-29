# cronjob-etcd-backup

Creates a CronJob that creates etcd backups on a schedule and stores them on a PersistentVolume.

This essentially automates the [officially documented etcd backup process](https://docs.openshift.com/container-platform/4.10/backup_and_restore/control_plane_backup_and_restore/backing-up-etcd.html) with the additional step
that the etcd backup is moved to external storage via a PVC.

> :exclamation: **uses privileged** see [Permissions](#permissions)

## Use

### Manual
Installs and tests the helm chart
```bash
helm upgrade --install cronjob-etcd-backup ./cronjob-etcd-backup --namespace openshift-etcd-backup --create-namespace
helm test cronjob-etcd-backup
```

### ArgoCD
There innumerable different ways and opinions on doing GitOps, and even within ArgoCD there
are many ways. Here is a start if you don't already have an opinion.

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: openshift-etcd-backup
spec:
  destination:
    name: ''
    namespace: openshift-etcd-backup
    server: 'https://kubernetes.default.svc'
  source:
    path: charts/cronjob-etcd-backup
    repoURL: 'https://github.com/redhat-cop/openshift-management.git'
    targetRevision: master
    helm:
      values: |
        pvcStorage: 100Gi
        pvcStorageClassName:
        cronJobSchedule: '5 0 * * *'
        cronJobDaysToKeepPersistentETCDBackups: 5
  project: default
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
      - CreateNamespace=true
```

## Permissions
Yes, this chart uses the `privileged` security context, but it is not out of laziness, it is
out of necessity. To be able to run the `cluster-backup.sh` script on a control node you not only
need to be able to mount the host file system but you need to be able to sudo.

While the [officially documented etcd backup process](https://docs.openshift.com/container-platform/4.10/backup_and_restore/control_plane_backup_and_restore/backing-up-etcd.html)
has you manually create a debug pod for a control node to accomplish this, if you are automating this
process then the container created by the CronJob has to have the same permissions a debug pod
for a control node would have. So this is no more permissions then would be used doing this the
documented manual way, its just giving it to the "robot".
