![Gitlab Delete Projects Container](https://github.com/redhat-cop/openshift-management/workflows/Gitlab%20Delete%20Projects%20Container/badge.svg)

# Gitlab Delete Projects Job

A cronjob that enables OpenShift to delete Gitlab projects that have become stale by checking the age of a repo. This also deletes groups that have no projects. Provide the job a top level group and it will search all projects under it and delete stale ones based on last activity and also remove empty groups.

The cronjob will not delete in the follow cases:

1. A group with the text `DO_NOT_DELETE` in the description will not delete the group, any subgroup and projects in the group and subgroups.
2.  A project wit the text `DO_NOT_DELETE` in the description or a tag `DO_NOT_DELETE` in the tag list.

**Caution:** this jobs performs hard deletes. The actual deletion policy is influenced by overarching settings in Gitlab.

## Using This Chart

This chart is geared toward Helm 3.

1. Clone the target repo

```
git clone https://github.com/redhat-cop/openshift-management.git
```

2. Change into ths job's directory

```
cd openshift-management/charts/gitlab-delete-stale-projects
```

3. Deploy using the follow Helm command:

```
helm template . \
  --set env.secret.name=my-openshift-secret-ref \
  --set env.secret.gitlabApiUrl=https//my.gitlab.base.com \
  --set env.secret.personalAccessToken=bot-token-value \
  --set env.secret.parentRepoId=-1 \
| oc apply -f - -n target-namespace
```

The following variables maybe configured.

| Variable  | Used by | Usage | Default |
|---|---|--|--|
| `image.name`  | cronjob | The name of the image | `quay.io/redhat-cop/gitlab-cleanup` |
| `image.tag`  | cronjob | The tag of the image | `latest` |
| `cron.schedule`  | cronjob | The cron schedule | `"1 0 * * *"` |
| `cron.historyLimit`  | cronjob | The amount of job runs to retain. | `5` |
| `generateSecret`  | secret | If true, then helm will generate the secret with values set at `env.secret.xxx`. | `false` |
| `env.deleteAfterInHours`  | cronjob | The job will delete itetms that are older than this amount of time. | `100 years` |
| `env.dryRun`  | cronjob | If true, then this job will not perform the deletes. Good for tetsting. | `true` |
| `env.logLevel`  | cronjob | Set the application log level. | `INFO` |
| `env.secret.name`  | cronjob, secret | A reference to an opaque secret that is deployed in the same namespace. Can be generated if necessary. | `secret-gitlab-info` |
| `env.gitlabApiUrl`  | cronjob | The url of the gitlab instance |
| `env.secret.personalAccessToken`  | secret | The personal access token for the user accessing gitlab. Bot recommended |
| `env.parentGroupId`  | cronjob | A reference to an opaque secret. Can be generated if necessary. |

## Development

The container can be built and run locally

To build:

```
docker build . -t gitlab-clean
```

To run:

```
docker run -e DRY_RUN=true -e PARENT_GROUP_ID=-10 -e GIT_TOKEN=xxxxx -e GITLAB_API_URL=https://gitlab.com -e DELETE_AFTER_HOURS=240000 -e LOG_LEVEL=DEBUG gitlab-clean
```
