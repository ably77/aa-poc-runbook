#!/bin/bash

cluster_context="mgmt"

# echo port-forward commands
echo 
echo "access argocd dashboard:"
echo "kubectl port-forward svc/argocd-server -n argocd 9999:443 --context ${cluster_context}"
echo
echo "navigate to http://localhost:9999/argo in your browser for argocd"
echo
echo "username: admin"
echo "password: solo.io"