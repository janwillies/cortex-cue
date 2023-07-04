# cortex manifests for kubernetes
this repo hosts the configuration manifests to deploy a minimal `cortex` setup to kubernetes. 

it is based on the single-process [cortex config](https://github.com/cortexproject/cortex/blob/master/docs/configuration/single-process-config-blocks-local.yaml) and configured to have `minio` as a backend store

## setup
create a kubernetes cluster if you haven't
```bash
kind create cluster
```
### service installation
install `cortex` and `minio` to the kubernetes cluster:
```bash
kubectl apply -f generated.yaml
```

### prepare object store
we need to create a bucket before we can store rules in cortex

port-forward the minio api:
```bash
kubectl port-forward deployment/minio 9000
```
download the minio client ([mc](https://min.io/docs/minio/linux/reference/minio-mc-admin.html#id2)) and create the `cortex` bucket:
```bash
./mc alias set local http://localhost:9000 minioadmin minioadmin
./mc mb local/cortex
./mc tree local/
```
### test the setup
port-forward the cortex api:
```bash
kubectl port-forward deployment/cortex 9009
```
create an example [rule group](https://cortexmetrics.io/docs/api/#set-rule-group):
```bash
curl --location 'http://localhost:9009/api/v1/rules/ns1' \
--header 'Content-Type: application/yaml' \
--header 'X-Scope-OrgID: f00bar' \
--data 'name: rule1
rules:
  - record: instance_path:request_failures:rate5m
    expr: rate(request_failures_total{job="myjob"}[5m])
  - alert: HighCPUUtilization
    expr: avg(node_cpu{mode="system"}) > 80
    for: 5m
    annotations:
      annotation_name: test
    labels:
      label_name: test'

{"status":"success","data":null,"errorType":"","error":""}
```

## addendum
### generate yaml
```bash
cue dump ./... > generated.yaml
```

### single manifests per service
```bash
cue export --out yaml -e service.minio -e deployment.minio ./minio | kubectl apply -f -
cue export --out yaml -e configMap.cortex -e deployment.cortex ./cortex | kubectl apply -f -
```