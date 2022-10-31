#!/bin/bash

gloo_mesh_version="2.1.0-rc3"
control_plane_values="values/gloo-mesh-ee-values.yaml"
agent_values="values/gloo-mesh-agent-values.yaml"

helm template "gloo-mesh-enterprise" gloo-mesh-enterprise/gloo-mesh-enterprise -n gloo-mesh --version ${gloo_mesh_version} > deploy/mgmt/${gloo_mesh_version}-ee-out.yaml --values=${control_plane_values} --include-crds

helm template "gloo-mesh-agent" gloo-mesh-agent/gloo-mesh-agent -n gloo-mesh --version ${gloo_mesh_version} > deploy/agent/${gloo_mesh_version}-agent-out.yaml --values=${agent_values} --include-crds