# About
The overlays in this directory can be used to demonstrate declarative configuration and composability/reusability using Kustomize. The configurations here directly mirror the in-line YAML in the hands-on labs.

# How to use the Kustomize Overlays
This repo assumes that a user understands how to leverage Kustomize, if you need a refresher there are many useful links and tutorials to help build knowledge on the tool

## Viewing configuration
To view an overlay, simply use the `kubectl kustomize <directory>` command to output.

As an example, first switch into the `mgmt` directory
```
cd kustomize-overlay/mgmt
```

Now you can view the contents of a specified overlay
```
kubectl kustomize 1.1.a-root-trust
```

Output should provide all the manifests necessary for setting a RootTrustPolicy
```
% kubectl kustomize 1.1.a-root-trust 
apiVersion: admin.gloo.solo.io/v2
kind: RootTrustPolicy
metadata:
  name: root-trust-policy
  namespace: gloo-mesh
spec:
  config:
    autoRestartPods: true
    mgmtServerCa:
      generated: {}
```

Similarly for cluster1:
```
cd kustomize-overlay/cluster1
```

Output of kustomize to set up the failover lab using VirtualDestination, FailoverPolicy, and OutlierDetectionPolicy
```
% kubectl kustomize 2.3.b-routing-federation-failover 
apiVersion: networking.gloo.solo.io/v2
kind: RouteTable
metadata:
  labels:
    expose: "true"
  name: productpage
  namespace: bookinfo-frontends
spec:
  hosts:
  - '*'
  http:
  - forwardTo:
      destinations:
      - kind: VIRTUAL_DESTINATION
        port:
          number: 9080
        ref:
          name: productpage
          namespace: bookinfo-frontends
    matchers:
    - uri:
        exact: /productpage
    - uri:
        prefix: /static
    - uri:
        exact: /login
    - uri:
        exact: /logout
    - uri:
        prefix: /api/v1/products
    name: productpage
  virtualGateways:
  - cluster: cluster1
    name: north-south-gw
    namespace: istio-gateways
  workloadSelectors: []
---
apiVersion: networking.gloo.solo.io/v2
kind: VirtualDestination
metadata:
  labels:
    expose: "true"
    failover: "true"
  name: productpage
  namespace: bookinfo-frontends
spec:
  hosts:
  - productpage.global
  ports:
  - number: 9080
    protocol: HTTP
  services:
  - labels:
      app: productpage
    namespace: bookinfo-frontends
---
apiVersion: networking.gloo.solo.io/v2
kind: VirtualGateway
metadata:
  name: north-south-gw
  namespace: istio-gateways
spec:
  listeners:
  - allowedRouteTables:
    - host: '*'
    http: {}
    port:
      number: 443
    tls:
      mode: SIMPLE
      secretName: tls-secret
  workloads:
  - selector:
      labels:
        istio: ingressgateway
---
apiVersion: resilience.policy.gloo.solo.io/v2
kind: FailoverPolicy
metadata:
  name: failover
  namespace: bookinfo-frontends
spec:
  applyToDestinations:
  - kind: VIRTUAL_DESTINATION
    selector:
      labels:
        failover: "true"
  config:
    localityMappings: []
---
apiVersion: resilience.policy.gloo.solo.io/v2
kind: OutlierDetectionPolicy
metadata:
  name: outlier-detection
  namespace: bookinfo-frontends
spec:
  applyToDestinations:
  - kind: VIRTUAL_DESTINATION
    selector:
      labels:
        failover: "true"
  config:
    baseEjectionTime: 30s
    consecutiveErrors: 2
    interval: 5s
    maxEjectionPercent: 100
```

## Deploying a configuration
To deploy an overlay using Kustomize, just use the `kubectl apply -k <overlay>` command. Make sure that you are in the right cluster contexts (overlay tells you with the root folder either `mgmt` or `cluster1` for the workshop)