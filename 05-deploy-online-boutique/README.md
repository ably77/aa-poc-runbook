## Lab 05 - Deploy Online Boutique <a name="lab-05---deploy-online-boutique-"></a>


The Online Boutique applicaion is a set of microservices that make up an online shopping website. There is a UI application that reaches out to many APIs to retrieve its data to populate the UI. This workshop will incrementally add features to this website in the coming labs. 

![Online Boutique leaf1](images/online-boutique-cluster1.png)

* Create the Online Boutique namespaces
```shell
kubectl apply --context leaf1 -f data/namespaces.yaml
```
* Deploy online boutique into leaf1
```shell
helm upgrade -i online-boutique --version "5.0.3" oci://us-central1-docker.pkg.dev/field-engineering-us/helm-charts/onlineboutique \
  --namespace online-boutique  \
  --kube-context leaf1 \
  -f data/values.yaml
```

* Verify pods are running
```bash
kubectl get pods -n online-boutique --context leaf1
```
