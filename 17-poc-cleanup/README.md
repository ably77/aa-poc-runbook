## Lab 17 - POC Clean Up <a name="lab-17---poc-clean-up-"></a>


You have completed the POC! The final step is to clean up the deployed assets and reset the environments back to their original state.

> Some of the commands here may try and cleanup things that dont exist. This is just to make sure all POC assets were accounted for. 


## Clean Up Applications

* Remove the Online Boutique Applications in leaf1
```shell
helm uninstall online-boutique \
  --namespace online-boutique \
  --kube-context leaf1

helm uninstall toys-catalog \
  --namespace online-boutique \
  --kube-context leaf1
```

* Remove the Online Boutique Applications in leaf2
```shell
helm uninstall ha-frontend \
  --namespace online-boutique \
  --kube-context leaf2

helm uninstall checkout-apis \
  --namespace checkout-apis \
  --kube-context leaf2
```

* Delete the namespaces
```shell
kubectl delete namespace online-boutique --context leaf1

kubectl delete namespace online-boutique --context leaf2
kubectl delete namespace checkout-apis --context leaf2
```

## Clean up Gloo Addons

* Remove the Gloo Addons
```shell
helm uninstall gloo-platform-addons \
  --namespace gloo-platform-addons \
  --kube-context leaf1
```

* Delete the Gloo Addons namespace
```
kubectl delete namespace gloo-platform-addons --context leaf1
```

## Clean Up Istio

* **NOTE** All sidecars must be removed from applications before the IstioLifecycleManager can be deleted. Istio will prevent the deletion of the control plane if data plane proxies exist.

* Delete GatewayLifecycleManagers
```shell
kubectl delete GatewayLifecycleManager --all -A --context management
```

* Delete IstioLifecycleManager
```shell
kubectl delete IstioLifecycleManager --all -A --context management
```

## Clean Up Gloo Platform

* Remove Agents from workload clusters
```shell
helm uninstall gloo-agent \
  --namespace gloo-mesh \
  --kube-context leaf1

helm uninstall gloo-agent \
  --namespace gloo-mesh \
  --kube-context leaf2
```

* Remove Gloo CRDs
```shell
helm uninstall gloo-platform-crds \
  --namespace gloo-mesh \
  --kube-context leaf1

helm uninstall gloo-platform-crds \
  --namespace gloo-mesh \
  --kube-context leaf2
```

* Delete gloo-mesh namespaces
```shell
kubectl delete namespace gloo-mesh --context leaf1

kubectl delete namespace gloo-mesh --context leaf2
```

* Remove the Workspace namespaces in management cluster
```shell
kubectl delete namespace ops-team --context management
kubectl delete namespace app-team --context management
kubectl delete namespace checkout-team --context management
```

* Cleanup management cluster
```shell
helm uninstall jaeger \
  --namespace gloo-mesh \
  --kube-context management

helm uninstall gloo-platform \
  --namespace gloo-mesh \
  --kube-context management

helm uninstall gloo-platform-crds \
  --namespace gloo-mesh \
  --kube-context management
```

* Remove namespace
```shell
kubectl delete namespace gloo-mesh --context management
```

## Optional Deployments

* Cleanup Keycloak
```shell
kubectl delete namespace keycloak --context leaf1
```

* Cleanup cert-manager
```shell
helm uninstall cert-manager \
  --namespace cert-manager \
  --kube-context management

helm uninstall cert-manager \
  --namespace cert-manager \
  --kube-context leaf1

helm uninstall cert-manager \
  --namespace cert-manager \
  --kube-context leaf2
```

* Cleanup cert-manager namespace
```shell
kubectl delete namespace cert-manager --context management
```

* Cleanup Vault
```shell
helm uninstall vault \
  --namespace vault \
  --kube-context management
```

* Cleanup vault namespace
```shell
kubectl delete namespace vault --context management
```
