![Gitlab Delete Projects Container](https://github.com/redhat-cop/openshift-management/workflows/Gitlab%20Delete%20Projects%20Container/badge.svg)

# Gitlab Delete Projects Job

A cronjob that enables OpenShift to delete Gitlab projects that have become stale by checking the age of a repo. This also deletes groups that have no projects. Provide the job a top level group and it will search all projects under it and delete stale ones based on last activity and also remove empty groups.

The cronjob will not delete in the follow cases:

1. A group with the text `DO_NOT_DELETE` in the description will not delete the group, any subgroup and projects in the group and subgroups.
2. A project wit the text `DO_NOT_DELETE` in the description or a tag `DO_NOT_DELETE` in the tag list.

**Caution:** this jobs performs hard deletes. The actual deletion policy is influenced by overarching settings in Gitlab.

## Notification / Hook

This job has the ability to notify applications via a webhook. Specify the url to post to and the value of the secret header `x-notification-token` for the request to be invoked.

The json payload will look like

```
{
  "event_name": "project_deleted", # or group_deleted
  "group_id": 1424, # only set if group was deleted
  "project" { ...} # the full gitlab project structure, only set if project was deleted
}
```

## Using This Chart

This chart is geared toward Helm 3.

1. Clone the target repo

```
git clone https://github.com/redhat-cop/openshift-management.git
```

2. Change into ths job's directory

```
cd openshift-management/charts/cronjob-gitlab-delete-projects
```

3. Deploy using the follow Helm command:

```
helm template . \
  --set env.secret.name=my-openshift-secret-ref \
  --set env.gitlabApiUrl=https//my.gitlab.base.com \
  --set env.secret.personalAccessToken=bot-token-value \
  --set env.parentGroupId=-1 \
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
| `env.parentGroupId`  | cronjob | Group ID of the GitLab (sub)group to look for projects to delete. |
| `env.secret.notificationToken` | secret | The access token for the notification application |
| `env.notificationUrl` | cronjob | The url to notify when a delete has occurred. Disabled during a dry run unless the token is set to `DRYRUN` | 
