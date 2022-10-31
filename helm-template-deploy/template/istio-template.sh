#!/bin/bash

istio_version="1.15.1"
istio_revision="1-15"
istio_cp_values="values/istio-cp-values.yaml"
istio_ns_ig_values="values/istio-ns-ig-values.yaml"
istio_ew_ig_values="values/istio-ew-ig-values.yaml"

helm template "istio-base" istio/base -n istio-system --version ${istio_version} > deploy/agent/istio/istio-base-${istio_revision}-out.yaml --include-crds

helm template "istiod-${istio_revision}" istio/istiod -n istio-system --version ${istio_version} --values ${istio_cp_values} > deploy/agent/istio/istiod-${istio_revision}-out.yaml

helm template "istio-ingressgateway-${istio_revision}" istio/gateway -n istio-gateways --version ${istio_version} --values ${istio_ns_ig_values} > deploy/agent/istio/istio-ingressgateway-${istio_revision}-out.yaml

helm template "istio-eastwestgateway-${istio_revision}" istio/gateway -n istio-gateways --version ${istio_version} --values ${istio_ew_ig_values} > deploy/agent/istio/istio-eastwestgateway-${istio_revision}-out.yaml