# zigbee2mqtt

[![Artifact Hub](https://img.shields.io/endpoint?url=https://artifacthub.io/badge/repository/helm-zigbee2mqtt)](https://artifacthub.io/packages/search?repo=helm-zigbee2mqtt)
[![Version: 1.3.0](https://img.shields.io/badge/Version-1.3.0-informational?style=flat-square)](https://github.com/Sironite/helm-zigbee2mqtt/releases/tag/zigbee2mqtt-v1.3.0) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) [![AppVersion: 2.9.2](https://img.shields.io/badge/AppVersion-2.9.2-informational?style=flat-square)](https://github.com/Koenkk/zigbee2mqtt/releases/tag/2.9.2)

Zigbee2MQTT on Kubernetes — bridges Zigbee devices to MQTT

This chart deploys [Zigbee2MQTT](https://www.zigbee2mqtt.io) as a `StatefulSet` with persistent
storage for `/app/data`. It bridges Zigbee devices to an MQTT broker and exposes a web frontend.

## Usage

**Helm repo (GitHub Pages):**

```bash
helm repo add sironite https://sironite.github.io/helm-zigbee2mqtt
helm repo update
helm install zigbee2mqtt sironite/zigbee2mqtt \
  --namespace zigbee2mqtt --create-namespace \
  -f my-values.yaml
```

**OCI (GHCR):**

```bash
helm install zigbee2mqtt oci://ghcr.io/sironite/zigbee2mqtt \
  --version 1.3.0 \
  --namespace zigbee2mqtt --create-namespace \
  -f my-values.yaml
```

## Integrations

### Configuration file (`config`)

Mount `configuration.yaml` directly from an existing Kubernetes resource — no External Secrets Operator required.

Use a **Secret** when the config contains credentials (MQTT passwords, Zigbee network keys):

```yaml
config:
  existingSecret: zigbee2mqtt-config
```

Use a **ConfigMap** for setups without sensitive data (network-attached coordinator, public MQTT broker):

```yaml
config:
  existingConfigMap: zigbee2mqtt-config
```

The Secret or ConfigMap must contain a key named `configuration.yaml`. Create it manually:

```bash
# from a Secret
kubectl create secret generic zigbee2mqtt-config \
  --from-file=configuration.yaml=./configuration.yaml \
  --namespace zigbee2mqtt

# from a ConfigMap
kubectl create configmap zigbee2mqtt-config \
  --from-file=configuration.yaml=./configuration.yaml \
  --namespace zigbee2mqtt
```

`existingSecret` takes precedence over `existingConfigMap` when both are set. Both are mutually exclusive with `externalSecrets`.

### External Secrets (`externalSecrets`)

[External Secrets Operator](https://external-secrets.io) (ESO) syncs secrets from an external store
(1Password, HashiCorp Vault, AWS SSM, …) into Kubernetes `Secret` resources mounted under `/app/data`.

The primary use case is injecting `configuration.yaml` from your secret store so that the MQTT broker
address, Zigbee adapter settings, and network keys never live in plain-text values files.

```yaml
externalSecrets:
  enabled: true
  items:
  - name: zigbee2mqtt-config
    secretStoreRef: my-cluster-secret-store
    remoteKey: zigbee2mqtt-config
    secretKey: configuration.yaml
    defaultMode: 0444
```

### USB Zigbee adapter (`device`)

When using a serial USB Zigbee coordinator (CC2531, SONOFF Zigbee 3.0 USB Dongle, etc.), mount the
host device into the container:

```yaml
device: /dev/serial/by-id/usb-Texas_Instruments_TI_CC2531_USB_CDC___0X00124B0018E00DA5-if00
```

Leave `device` empty when using a network-attached coordinator (e.g. Zigbee over TCP/IP).

### Authentik outpost (`authentikOutpost`)

Zigbee2MQTT ships a basic `frontend.auth_token` option, but an **Authentik outpost** gives you
full SSO with MFA, group-based access, and session management via your existing identity provider.

The outpost is a separate reverse proxy `Deployment` that validates sessions against your central
[Authentik](https://goauthentik.io) server before forwarding traffic to Zigbee2MQTT. Point your
HTTPRoute (or Ingress) backend at port `9000` of the outpost service instead of port `8080` of
Zigbee2MQTT directly.

**Prerequisites:**
- Authentik installed in the cluster
- A *Proxy Provider* + *Outpost* configured in Authentik for Zigbee2MQTT
- The outpost token stored in a secret

**Token secret** — choose one approach:

```yaml
# Option A: existing Kubernetes Secret (key must be named `token`)
authentikOutpost:
  enabled: true
  authentikHost: "http://authentik-server.authentik.svc"
  authentikHostBrowser: "https://sso.example.com"
  existingSecret: "my-outpost-token-secret"

# Option B: pull token from external store via ESO
authentikOutpost:
  enabled: true
  authentikHost: "http://authentik-server.authentik.svc"
  authentikHostBrowser: "https://sso.example.com"
  externalSecret:
    enabled: true
    secretStoreRef: onepassword-connect
    remoteKey: authentik-outpost-zigbee2mqtt   # must have a `token` property
```

When the outpost is enabled, update your HTTPRoute backend to target port `9000`:

```yaml
httproutes:
- enabled: true
  name: zigbee2mqtt-httproute
  hostname: zigbee.example.com
  backend:
    name: zigbee2mqtt-authentik-outpost
    port: 9000
```

### Gateway API HTTPRoutes (`httproutes`)

Creates `HTTPRoute` resources for use with a [Gateway API](https://gateway-api.sigs.k8s.io) compatible
controller. Requires Gateway API CRDs installed in the cluster.

```yaml
httproutes:
- enabled: true
  name: zigbee2mqtt-httproute
  hostname: zigbee.example.com
  path: /
  gateway:
    name: my-gateway
    namespace: kube-system
    sectionName: https-listener
  backend:
    name: zigbee2mqtt
    port: 8080
```

### Ingress (`ingress`)

Standard Kubernetes `Ingress` resource for clusters without Gateway API. Works with any ingress
controller (nginx, Traefik, HAProxy, …).

```yaml
ingress:
  enabled: true
  className: nginx
  hostname: zigbee.example.com
  tls:
  - hosts:
    - zigbee.example.com
    secretName: zigbee2mqtt-tls
```

### Cilium NetworkPolicy (`networkPolicy.cilium`)

Optional `CiliumNetworkPolicy` that restricts pod traffic to only what Zigbee2MQTT needs.
Requires [Cilium CNI](https://cilium.io).

```yaml
networkPolicy:
  cilium:
    enabled: true
  prometheusNamespace: monitoring   # allow Prometheus scraping
  mqttNamespace: emqx               # allow MQTT broker egress
  extraIngress: []                  # append custom ingress rules
  extraEgress: []                   # append custom egress rules
```

### Kubernetes NetworkPolicy (`networkPolicy.kubernetes`)

Standard `NetworkPolicy` for clusters without Cilium. Works with any CNI that supports NetworkPolicy
(Calico, Flannel, Weave, …). Controls ingress only; use `extraEgress` to add egress rules.

```yaml
networkPolicy:
  kubernetes:
    enabled: true
  prometheusNamespace: monitoring
  extraEgress:
  - to:
    - namespaceSelector:
        matchLabels:
          kubernetes.io/metadata.name: my-namespace
    ports:
    - port: 1883
```

Both `networkPolicy.cilium` and `networkPolicy.kubernetes` share the same namespace fields and
`extraIngress`/`extraEgress` lists — enable one or the other, not both.

## Prerequisites summary

| Feature | Cluster requirement |
|---------|-------------------|
| `externalSecrets.enabled` | [External Secrets Operator](https://external-secrets.io) |
| `authentikOutpost.enabled` | [Authentik](https://goauthentik.io) |
| `authentikOutpost.externalSecret.enabled` | [External Secrets Operator](https://external-secrets.io) |
| `ingress.enabled` | Any Kubernetes ingress controller |
| `httproutes` | [Gateway API CRDs](https://gateway-api.sigs.k8s.io) |
| `networkPolicy.cilium.enabled` | [Cilium CNI](https://cilium.io) |
| `networkPolicy.kubernetes.enabled` | Any CNI with NetworkPolicy support |

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| authentikOutpost | object | `{"authentikHost":"","authentikHostBrowser":"","enabled":false,"existingSecret":"","externalSecret":{"enabled":false,"remoteKey":"","secretStoreRef":""},"image":{"repository":"ghcr.io/goauthentik/proxy","tag":"2026.5.3"},"resources":{"limits":{"cpu":"200m","memory":"256Mi"},"requests":{"cpu":"20m","memory":"64Mi"}}}` | Authentik proxy outpost for the Zigbee2MQTT frontend. An outpost is a lightweight reverse proxy that enforces Authentik SSO authentication before forwarding traffic to Z2M. Requires [Authentik](https://goauthentik.io) installed in the cluster and a Proxy Provider + Outpost configured for Zigbee2MQTT. When enabled, point the HTTPRoute backend to port 9000 of the outpost service instead of port 8080 of the Zigbee2MQTT service. |
| authentikOutpost.authentikHost | string | `""` | Cluster-internal URL of the Authentik server (used by the outpost to validate sessions). |
| authentikOutpost.authentikHostBrowser | string | `""` | Public-facing Authentik URL (used for browser redirects to the login page). |
| authentikOutpost.enabled | bool | `false` | Enable the Authentik proxy outpost Deployment and Service. |
| authentikOutpost.existingSecret | string | `""` | Name of an existing Kubernetes Secret containing the outpost token under key `token`. Mutually exclusive with `externalSecret`. Create this secret manually or via another tool. |
| authentikOutpost.externalSecret | object | `{"enabled":false,"remoteKey":"","secretStoreRef":""}` | Fetch the outpost token from an external secret store via ESO instead of an existing secret. |
| authentikOutpost.externalSecret.enabled | bool | `false` | Enable ExternalSecret rendering for the outpost token. |
| authentikOutpost.externalSecret.remoteKey | string | `""` | Key in the secret store that holds the outpost token (must have a `token` property). |
| authentikOutpost.externalSecret.secretStoreRef | string | `""` | ClusterSecretStore name. |
| authentikOutpost.image | object | `{"repository":"ghcr.io/goauthentik/proxy","tag":"2026.5.3"}` | Authentik proxy image. |
| authentikOutpost.resources | object | `{"limits":{"cpu":"200m","memory":"256Mi"},"requests":{"cpu":"20m","memory":"64Mi"}}` | Resource requests and limits for the outpost proxy container. |
| config | object | `{"existingConfigMap":"","existingSecret":""}` | Mount `configuration.yaml` from an existing Kubernetes resource. Use `existingSecret` for configs containing credentials (MQTT passwords, network keys). Use `existingConfigMap` for configs without sensitive data (ignored when `existingSecret` is set). The resource must contain a key named `configuration.yaml`. Mutually exclusive with `externalSecrets` — use one approach, not both. |
| config.existingConfigMap | string | `""` | Name of an existing ConfigMap containing `configuration.yaml`. |
| config.existingSecret | string | `""` | Name of an existing Secret containing `configuration.yaml`. |
| device | string | `""` | Host device path for the Zigbee USB adapter (e.g. `/dev/ttyUSB0` or `/dev/serial/by-id/...`). When set, the device node is mounted into the container. Leave empty when using a network-attached coordinator. |
| env | list | `[{"name":"TZ","value":"UTC"}]` | Environment variables injected into the Zigbee2MQTT container. |
| externalSecrets | object | `{"enabled":false,"items":[]}` | External Secrets Operator integration for pulling secrets from an external secret store. Requires [ESO](https://external-secrets.io) installed in the cluster. Each item creates an `ExternalSecret` that syncs a secret into a Kubernetes `Secret`, which is then mounted into the Zigbee2MQTT container under `/app/data`. |
| externalSecrets.enabled | bool | `false` | Enable ExternalSecret rendering. |
| externalSecrets.items | list | `[]` | List of secrets to sync. |
| fullnameOverride | string | `""` | Override the full resource name prefix. |
| httproutes | list | `[]` | Gateway API `HTTPRoute` resources. Requires [Gateway API CRDs](https://gateway-api.sigs.k8s.io). |
| image | object | `{"pullPolicy":"IfNotPresent","repository":"koenkk/zigbee2mqtt","tag":""}` | Zigbee2MQTT container image. |
| image.pullPolicy | string | `"IfNotPresent"` | Image pull policy. |
| image.repository | string | `"koenkk/zigbee2mqtt"` | Image repository. |
| image.tag | string | `""` | Image tag. Defaults to `Chart.appVersion` when empty. |
| ingress | object | `{"annotations":{},"className":"","enabled":false,"hostname":"","tls":[]}` | Standard Kubernetes Ingress resource. Use when a Gateway API HTTPRoute is not available. |
| ingress.annotations | object | `{}` | Annotations merged onto the Ingress resource. |
| ingress.className | string | `""` | IngressClass name (e.g. `nginx`, `traefik`). |
| ingress.enabled | bool | `false` | Enable Ingress rendering. |
| ingress.hostname | string | `""` | Hostname for the Ingress rule. |
| ingress.tls | list | `[]` | TLS configuration. |
| nameOverride | string | `""` | Override the chart name used in resource names and labels. |
| namespaceLabels | object | `{}` | Extra labels merged onto the Namespace created by this chart. |
| networkPolicy | object | `{"cilium":{"enabled":false},"extraEgress":[],"extraIngress":[],"kubernetes":{"enabled":false},"mqttNamespace":"","prometheusNamespace":""}` | NetworkPolicy configuration. |
| networkPolicy.cilium.enabled | bool | `false` | Enable CiliumNetworkPolicy rendering. Requires [Cilium CNI](https://cilium.io). |
| networkPolicy.extraEgress | list | `[]` | Extra egress rules appended to the NetworkPolicy (both Cilium and Kubernetes). |
| networkPolicy.extraIngress | list | `[]` | Extra ingress rules appended to the NetworkPolicy (both Cilium and Kubernetes). |
| networkPolicy.kubernetes.enabled | bool | `false` | Enable standard Kubernetes NetworkPolicy rendering. Works with any CNI that supports NetworkPolicy. |
| networkPolicy.mqttNamespace | string | `""` | Namespace of the MQTT broker (e.g. EMQX). When set, adds an egress rule on port 1883. |
| networkPolicy.prometheusNamespace | string | `""` | Namespace where Prometheus runs. When set, adds an ingress rule allowing Prometheus scraping on port 8080. |
| persistence | object | `{"enabled":true,"size":"2Gi","storageClassName":""}` | Persistent storage for the Zigbee2MQTT `/app/data` directory. |
| persistence.enabled | bool | `true` | Enable the PersistentVolumeClaim. |
| persistence.size | string | `"2Gi"` | Storage size. |
| persistence.storageClassName | string | `""` | StorageClass name. Defaults to the cluster default when empty. |
| resources | object | `{"limits":{"cpu":"200m","memory":"256Mi"},"requests":{"cpu":"50m","memory":"128Mi"}}` | Resource requests and limits for the Zigbee2MQTT container. |
| service | object | `{"annotations":{},"port":8080,"type":"ClusterIP"}` | Kubernetes Service configuration. |
| service.annotations | object | `{}` | Annotations merged onto the Service resource. |
| service.port | int | `8080` | Port to expose. Zigbee2MQTT frontend listens on 8080 by default. |
| service.type | string | `"ClusterIP"` | Service type. |

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| sironite |  | <https://github.com/sironite> |

## Source Code

* <https://github.com/Koenkk/zigbee2mqtt>
* <https://github.com/sironite/helm-zigbee2mqtt>
