# Prune OCP projects

Use this image to prune Openshift projects

- Based on UBI 8
- Uses oc client 4.4

## Build image

### Dockerfile
```
docker build -t prune-ocp-projects .
```

### Buildah
```
./buildah.sh
```
or
```
buildah build -t prune-ocp-projects .
```
