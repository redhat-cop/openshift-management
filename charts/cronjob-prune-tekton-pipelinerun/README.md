# Delete Tekton Pipelinruns Job

A cronjob that enables OpenShift to delete Tekton Pipelineruns that have completed. The job will delete Pipelineruns above `NUM_TO_KEEP` in all namespaces (`^kube|^openshift|^default` are excluded). Individual pipelines can also be deleted through `PIPELINES` (use the following format: `"ns1/pipeline1 ns1/pipeline2 ns2/pipeline1"`).

## Using This Chart

This chart is geared toward Helm 3.

1. Clone the target repo

```
git clone https://github.com/redhat-cop/openshift-management.git
```

2. Change into ths job's directory

```
cd openshift-management/charts/cronjob-prune-tekton-pipelinerun
```

3. Deploy using the follow Helm command:

```
helm template prune-tekton-pipelinerun . \
  --set namespace=prune-jobs \
  --set num_to_keep=5 \
  --set pipelines="ns1/pipeline1 ns2/pipeline1"
| oc apply -f - -n target-namespace
```

The following variables maybe configured.

| Variable  | Used by | Usage | Default |
|---|---|--|--|
| `namespace`  | cronjob | The namespace where to install | `labs-ci-cd` |
| `job_name`  | cronjob | The name of the cronjob| `cronjob-prune-tekton-pipelinerun` |
| `schedule`  | cronjob | The cron schedule | `"*/30 * * * *"` |
| `num_to_keep`  | cronjob | The number of pipelineruns to retain (per pipeline). | `10` |
| `pipelines`  | cronjob | If set, then only these pipelines will be pruned. Should use format `namespace1/pipeline1`. Multiple pipelines are supported, use space delimited pipelines. | `""` |
| `failed_jobs_history_limit`  | cronjob | The number of failed jobs to keep. | `5` |
| `success_jobs_history_limit`  | cronjob | The number of successful jobs to keep. | `5` |
| `image` | cronjob | The container image to use for the cronjob. | `quay.io/openshift/origin-cli` |
| `image_tag` | cronjob | The container image tag to use for the cronjob. | `4.7` |
