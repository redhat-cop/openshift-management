# Gitlab Delete Projects Image

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
