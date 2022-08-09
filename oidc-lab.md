## Lab 15 - Integrate Gloo Mesh UI with OIDC <a name="Lab-15"></a>
Next let's integrate the Gloo Mesh UI with our OIDC. The Gloo Mesh API server has its own external auth service built in. This way, you can manage external auth for the Gloo Mesh UI separately from the external auth that you set up for your application networking policies.

Integrating the Gloo Mesh UI with OIDC consists of a few steps:
```
- create app registration for the Gloo Mesh UI in your OIDC
- Using Helm, update Gloo Mesh with new OIDC configuration
```

The `gloo-mesh-enterprise` helm chart lets us define the OIDC values inline. The values OIDC values are described below:
```
glooMeshUi:
  enabled: true
  auth:
    enabled: true
    backend: oidc
    oidc:
      clientId: # From the OIDC provider
      clientSecret: # From the OIDC provider. Stored in a secret that you created in advance in the same namespace as the Gloo Mesh UI. In this example, the secret's name is 'dashboard'.
      clientSecretName: dashboard
      issuerUrl: # The URL to connect to the OpenID Connect identity provider, often in the format 'https://<domain>.<provider_url>/'.
      appUrl: # The URL that the Gloo Mesh UI is exposed at, such as 'https://localhost:8090'.
```

### Setting our Variables
Set the callback URL in your OIDC provider to map to our newly exposed Gloo Mesh UI route
```bash
export GMUI_CALLBACK_URL="https://$(kubectl --context ${MGMT} -n istio-gateways get svc istio-ingressgateway -o jsonpath='{.status.loadBalancer.ingress[0].*}')"

echo ${GMUI_CALLBACK_URL}
```

Replace the `OICD_CLIENT_ID` and `ISSUER_URL` values below with your OIDC app settings:
```bash
export GMUI_OIDC_CLIENT_ID="<client ID for Gloo Mesh UI app>"
export GMUI_OIDC_CLIENT_SECRET="<client secret for Gloo Mesh UI app>"
export ISSUER_URL="<OIDC issuer url (i.e. https://dev-22651234.okta.com/oauth2/default)>"
```

Let's make sure our variables are set correctly:
```bash
echo ${GMUI_OIDC_CLIENT_ID}
echo ${GMUI_OIDC_CLIENT_SECRET}
echo ${ISSUER_URL}
```

### Update Gloo Mesh Helm
Let's save a new `values-oidc.yaml` to fill in the auth config that we have uncommented below
```bash
cat <<EOF >>values-oidc.yaml
licenseKey: ${GLOO_MESH_LICENSE_KEY}
mgmtClusterName: mgmt
glooMeshMgmtServer:
  ports:
    healthcheck: 8091
  serviceType: LoadBalancer
glooMeshUi:
  enabled: true
  serviceType: ClusterIP
  auth:
    enabled: true
    backend: oidc
    oidc: 
      # From the OIDC provider
      clientId: "${GMUI_OIDC_CLIENT_ID}"
      # From the OIDC provider. To be base64 encoded and stored as a kubernetes secret.
      clientSecret: "${GMUI_OIDC_CLIENT_SECRET}"
      # Name for generated secret
      clientSecretName: dashboard
      # The issuer URL from the OIDC provider, usually something like 'https://<domain>.<provider_url>/'.
      issuerUrl: ${ISSUER_URL}
      # The URL that the UI for the OIDC app is available at, from the DNS and other ingress settings that expose the OIDC app UI service.
      appUrl: "${GMUI_CALLBACK_URL}"
  # if cluster is istio enabled we can also add the dashboard into the mesh
  deploymentOverrides:
    spec:
      template:
        metadata:
          annotations:
            sidecar.istio.io/inject: "true"
          labels:
            istio.io/rev: "1-13"
EOF
```

### Update Gloo Mesh using Helm
Now upgrade Gloo Mesh with our new `values-oidc.yaml` to pick up our new config
```bash
helm --kube-context ${MGMT} upgrade --install gloo-mesh-enterprise gloo-mesh-enterprise/gloo-mesh-enterprise -n gloo-mesh --version=2.0.9 --values=values-oidc.yaml
```

Once configured, we should be able to access the Gloo Mesh UI and it should be now be protected by OIDC.
```bash
echo ${GMUI_CALLBACK_URL}
```