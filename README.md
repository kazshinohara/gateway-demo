# Gateway API demo with GKE  

A demo application shows Multi-cluster Gateway with [Google Kubernetes Engine](https://cloud.google.com/kubernetes-engine).  

TODO: Demo Architecture diagram

## How to use
### Internal Multi-cluster gateway
#### Set up
1. Enable Google Cloud services 
```shell  gcloud services enable \
    container.googleapis.com \
    gkehub.googleapis.com \
    multiclusterservicediscovery.googleapis.com \
    multiclusteringress.googleapis.com \
    trafficdirector.googleapis.com \
```
2. enable workload identity on your GKE cluster

3. Register your GKE clusters to Feelt.
```shell
gcloud alpha container hub memberships register cluster-a \
--gke-cluster asia-northeast1-a/cluster-a \
--enable-workload-identity \
```
```shell
gcloud alpha container hub memberships register cluster-d \
--gke-cluster asia-northeast1-b/cluster-d \
--enable-workload-identity \
```

Confirm if your GKE clusters have been successfully registered.
```shell
gcloud alpha container hub memberships list
```

4. Enable Multi-cluster services
```shell
gcloud alpha container hub multi-cluster-services enable
```

5. Add a necessary role to the service accounts of MCS.
```shell
gcloud projects add-iam-policy-binding kzs-sandbox \
--member "serviceAccount:kzs-sandbox.svc.id.goog[gke-mcs/gke-mcs-importer]" \
--role "roles/compute.networkViewer" \
```

6. Check MCS status
```shell
gcloud alpha container hub multi-cluster-services describe --project=kzs-sandbox
```

7. Create Gateway API CRDs
```shell
kubectl kustomize "github.com/kubernetes-sigs/gateway-api/config/crd?ref=v0.3.0" \
| kubectl apply -f -
```

8. Enable Multi-cluster GKE Gateway controller
```shell
gcloud alpha container hub ingress enable \
--config-membership=cluster-a \
```

9. Add a necessary role to the service account of the controller
```shell
gcloud projects add-iam-policy-binding kzs-sandbox \
--member "serviceAccount:service-605899591260@gcp-sa-multiclusteringress.iam.gserviceaccount.com" \
--role "roles/container.admin" \
```
#### Deploy test workloads
1. Download this repo
```shell
git clone ```

```shell
cd ./gateway-demo/internal-mcgw
```

2. Deploy Blue workload to cluster-a
```shell
kubectx cluster-a
kubectl apply -f blue.yaml
```

3. Deploy Green workload to clsuter-d
```shell
kubectx cluster-d
kubectl apply -f green.yaml
```

4. Create Gateway via cluster-a (config cluster)
```shell
kubectx cluster-a
kubectl apply -f gw.yaml
```

5. Check the progress of gateway provisioning.
```shell
kubectx cluster-a
kubectl get events --field-selector involvedObject.kind=Gateway,involvedObject.name=internal-http
```

6. Apply HTTPRoute for header based routing
```shell
kubectx cluster-a
kubectl apply -f header-httproute.yaml
```

7. Test if the header based routing works well
Blue
```shell
curl -H "host: mc-gateway-demo.internal" http://${VIP}/ | jq
```
```shell
{
  "kind": "blue",
  "version": "v1",
  "region": "asia-northeast1",
  "cluster": "cluster-a",
  "hostname": "blue-bb64b946-kkj7q"
}
```

Green
```shell
curl -H "host: mc-gateway-demo.internal" -H "env: canary" http://${VIP}/ | jq
```
```shell
{
  "kind": "green",
  "version": "v1",
  "region": "asia-northeast1",
  "cluster": "cluster-d",
  "hostname": "green-554c54cf7-t5dpl"
}
```

8. Clean up HTTPRoute for header based routing
```shell
kubectx cluster-a
kubectl delete httproute header-httproute
```

9. Apply HTTPRoute for traffic split
```shell
kubectx cluster-a
kubectl apply -f split-httproute.yaml
```

10. Test if the traffic split works well (Blue: 90%, Green: 10%)
```shell
curl -H "host: mc-gateway-demo.internal" http://${VIP}/ | jq
```