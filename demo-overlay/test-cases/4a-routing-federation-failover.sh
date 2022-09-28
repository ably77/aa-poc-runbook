#!/bin/bash

cluster1_context="leaf1"

kubectl apply -k ../cluster1/2.2.a-workspace-settings-federation --context ${cluster1_context}

kubectl apply -k ../cluster1/2.3.b-routing-federation-failover --context ${cluster1_context}

read -p "Scale productpage down? " -n 1 -r
echo    # (optional) move to a new line
if [[ $REPLY =~ ^[Yy]$ ]]
then
    echo scaling down
    kubectl --context ${cluster1_context} -n bookinfo-frontends scale deploy/productpage-v1 --replicas=0
fi

read -p "Scale productpage back up? " -n 1 -r
echo    # (optional) move to a new line
if [[ $REPLY =~ ^[Yy]$ ]]
then
    echo scaling up
    kubectl --context ${cluster1_context} -n bookinfo-frontends scale deploy/productpage-v1 --replicas=1
fi