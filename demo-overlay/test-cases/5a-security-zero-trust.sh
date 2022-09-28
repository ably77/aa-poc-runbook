#!/bin/bash

cluster1_context="leaf1"

# apply route without isolation
echo "applying route without isolation"
kubectl apply -k ../cluster1/1.3.a-workspace-settings --context ${cluster1_context}
kubectl apply -k ../cluster1/2.1.b-routing-tls-single-upstream --context ${cluster1_context}

# sleep
echo
echo "sleeping for 10 seconds"
sleep 10

echo
echo "now curling reviews from sleep-not-in-mesh"
echo "using command: kubectl exec -it -n sleep deploy/sleep-not-in-mesh -- curl -s -o /dev/null -w "%{http_code}" http://reviews.bookinfo-backends.svc.cluster.local:9080/reviews/0 "
echo
echo "expected output: 200 status code:"
kubectl exec -it -n sleep deploy/sleep-not-in-mesh --context ${cluster1_context} -- curl -s -o /dev/null -w "%{http_code}" http://reviews.bookinfo-backends.svc.cluster.local:9080/reviews/0

# applying zero trust
echo
echo "now applying zero-trust in workspace settings"
kubectl apply -k ../cluster1/4.1.a.security-zero-trust --context ${cluster1_context}

# sleep
echo
echo "sleeping for 10 seconds"
sleep 10

echo
echo "now curling reviews from sleep-not-in-mesh"
echo "using command: kubectl exec -it -n sleep deploy/sleep-not-in-mesh -- curl -s -o /dev/null -w "%{http_code}" http://reviews.bookinfo-backends.svc.cluster.local:9080/reviews/0 "
echo
echo "expected output: 000 status code:"
kubectl exec -it -n sleep deploy/sleep-not-in-mesh --context ${cluster1_context} -- curl -s -o /dev/null -w "%{http_code}" http://reviews.bookinfo-backends.svc.cluster.local:9080/reviews/0

echo
echo "now reverting back to default workspace settings"
echo
kubectl apply -k ../cluster1/1.3.a-workspace-settings --context ${cluster1_context}
kubectl apply -k ../cluster1/2.1.b-routing-tls-single-upstream --context ${cluster1_context}
