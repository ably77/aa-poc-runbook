#!/bin/bash

cluster1_context="leaf1"

kubectl apply -k ../cluster1/2.2.a-workspace-settings-federation --context ${cluster1_context}

kubectl apply -k ../cluster1/2.3.b-routing-federation-failover --context ${cluster1_context}