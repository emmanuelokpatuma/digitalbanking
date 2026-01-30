# GKE Cluster Inventory Report

**Generated**: January 30, 2026  
**Cluster Name**: digitalbank-gke  
**Region**: us-central1  
**Project**: charged-thought-485008-q7

---

## Executive Summary

| Metric | Value |
|--------|-------|
| **Total Nodes** | 9 |
| **Total Pods** | 179 |
| **Machine Type** | e2-standard-2 (2 vCPU, 8 GB RAM) |
| **Kubernetes Version** | v1.33.5-gke.2100000 |
| **Cluster Status** | RUNNING |
| **High Availability** | Multi-zone (3 zones) |

---

## Node Distribution by Zone

| Zone | Node Count | Pod Count | Percentage |
|------|-----------|-----------|------------|
| us-central1-a | 3 | 56 | 31.3% |
| us-central1-b | 3 | 60 | 33.5% |
| us-central1-f | 3 | 63 | 35.2% |
| **TOTAL** | **9** | **179** | **100%** |

---

## Detailed Node Inventory

### Zone: us-central1-a

| Node Name | Internal IP | Pod Count | Age | Status |
|-----------|-------------|-----------|-----|--------|
| gke-digitalbank-gke-digitalbank-gke-n-17ab08f8-698s | 10.0.0.12 | 21 | 2d8h | Ready |
| gke-digitalbank-gke-digitalbank-gke-n-17ab08f8-cz5j | 10.0.0.20 | 15 | 2d1h | Ready |
| gke-digitalbank-gke-digitalbank-gke-n-17ab08f8-fjkp | 10.0.0.11 | 20 | 2d8h | Ready |

### Zone: us-central1-b

| Node Name | Internal IP | Pod Count | Age | Status |
|-----------|-------------|-----------|-----|--------|
| gke-digitalbank-gke-digitalbank-gke-n-21d17511-0h9m | 10.0.0.7 | 25 | 2d8h | Ready |
| gke-digitalbank-gke-digitalbank-gke-n-21d17511-7ppr | 10.0.0.6 | 18 | 2d8h | Ready |
| gke-digitalbank-gke-digitalbank-gke-n-21d17511-c687 | 10.0.0.5 | 17 | 2d8h | Ready |

### Zone: us-central1-f

| Node Name | Internal IP | Pod Count | Age | Status |
|-----------|-------------|-----------|-----|--------|
| gke-digitalbank-gke-digitalbank-gke-n-e353b711-17l7 | 10.0.0.10 | 19 | 2d8h | Ready |
| gke-digitalbank-gke-digitalbank-gke-n-e353b711-63x8 | 10.0.0.8 | 22 | 2d8h | Ready |
| gke-digitalbank-gke-digitalbank-gke-n-e353b711-j2bx | 10.0.0.9 | 22 | 2d8h | Ready |

---

## Pods by Node (Detailed Breakdown)

### Node 1: gke-digitalbank-gke-digitalbank-gke-n-17ab08f8-698s
**Zone**: us-central1-a | **IP**: 10.0.0.12 | **Pods**: 21

| # | Namespace | Pod Name | Status |
|---|-----------|----------|--------|
| 1 | digitalbank-apps | transactions-api-6855f8d74d-hhvmx | Running |
| 2 | digitalbank-monitoring | prometheus-kube-state-metrics-8457d8c49f-jgfxr | Running |
| 3 | digitalbank-monitoring | prometheus-prometheus-node-exporter-782lz | Running |
| 4 | digitalbank | transactions-api-5dc57f5f75-8kgth | Running |
| 5 | elk-demo | filebeat-f28fz | Running |
| 6 | elk-demo | kibana-58964c8768-8c4l9 | Running |
| 7 | gmp-system | collector-xjqrj | Running |
| 8 | kube-system | calico-node-dlzls | Running |
| 9 | kube-system | calico-typha-594fb65f77-689cr | Running |
| 10 | kube-system | filestore-node-8zm8z | Running |
| 11 | kube-system | fluentbit-gke-6z8gb | Running |
| 12 | kube-system | gke-metadata-server-t5l9h | Running |
| 13 | kube-system | gke-metrics-agent-xb5sd | Running |
| 14 | kube-system | ip-masq-agent-trsvc | Running |
| 15 | kube-system | konnectivity-agent-989d4fc9c-fxmzv | Running |
| 16 | kube-system | kube-proxy-gke-digitalbank-gke-digitalbank-gke-n-17ab08f8-698s | Running |
| 17 | kube-system | netd-r9wzd | Running |
| 18 | kube-system | pdcsi-node-b7sd8 | Running |
| 19 | kyverno | kyverno-reports-controller-898778dcd-5ctrv | Running |
| 20 | logging | filebeat-hwpls | Running |
| 21 | logging | kibana-demo-b67b4b576-fvljj | Running |

---

### Node 2: gke-digitalbank-gke-digitalbank-gke-n-17ab08f8-cz5j
**Zone**: us-central1-a | **IP**: 10.0.0.20 | **Pods**: 15

| # | Namespace | Pod Name | Status |
|---|-----------|----------|--------|
| 1 | digitalbank-monitoring | prometheus-prometheus-node-exporter-lhncv | Running |
| 2 | elk-demo | filebeat-nlrt2 | Running |
| 3 | gmp-system | collector-zdbwg | Running |
| 4 | jenkins | jenkins-b445947b9-tbjb9 | Running |
| 5 | kube-system | calico-node-jtmbl | Running |
| 6 | kube-system | filestore-node-j872j | Running |
| 7 | kube-system | fluentbit-gke-s6kqm | Running |
| 8 | kube-system | gke-metadata-server-hzz6t | Running |
| 9 | kube-system | gke-metrics-agent-wjdd4 | Running |
| 10 | kube-system | ip-masq-agent-pp2xf | Running |
| 11 | kube-system | kube-proxy-gke-digitalbank-gke-digitalbank-gke-n-17ab08f8-cz5j | Running |
| 12 | kube-system | netd-mh2n7 | Running |
| 13 | kube-system | pdcsi-node-v7ph2 | Running |
| 14 | logging | elasticsearch-master-0 | Running |
| 15 | logging | filebeat-v96b4 | Running |

---

### Node 3: gke-digitalbank-gke-digitalbank-gke-n-17ab08f8-fjkp
**Zone**: us-central1-a | **IP**: 10.0.0.11 | **Pods**: 20

| # | Namespace | Pod Name | Status |
|---|-----------|----------|--------|
| 1 | digitalbank-monitoring | prometheus-kube-prometheus-operator-7c67f9446d-g76g4 | Running |
| 2 | digitalbank-monitoring | prometheus-prometheus-node-exporter-mlwkj | Running |
| 3 | digitalbank | auth-api-7bcd695fcb-6bj62 | Running |
| 4 | digitalbank | digitalbank-frontend-859c458967-8x4p4 | Running |
| 5 | elk-demo | elasticsearch-0 | Running |
| 6 | elk-demo | filebeat-cnrlj | Running |
| 7 | gmp-system | collector-5svr7 | Running |
| 8 | kube-system | calico-node-88mqb | Running |
| 9 | kube-system | filestore-node-fg9dv | Running |
| 10 | kube-system | fluentbit-gke-wkbv6 | Running |
| 11 | kube-system | gke-metadata-server-8nmvk | Running |
| 12 | kube-system | gke-metrics-agent-k8swt | Running |
| 13 | kube-system | ip-masq-agent-cp7zq | Running |
| 14 | kube-system | konnectivity-agent-989d4fc9c-wrr7x | Running |
| 15 | kube-system | kube-proxy-gke-digitalbank-gke-digitalbank-gke-n-17ab08f8-fjkp | Running |
| 16 | kube-system | netd-lh446 | Running |
| 17 | kube-system | pdcsi-node-68g8c | Running |
| 18 | kyverno | kyverno-admission-controller-796f687845-6ssbk | Running |
| 19 | logging | filebeat-vgq9h | Running |
| 20 | logging | kibana-5fd8b887d7-q5k28 | Running |

---

### Node 4: gke-digitalbank-gke-digitalbank-gke-n-21d17511-0h9m
**Zone**: us-central1-b | **IP**: 10.0.0.7 | **Pods**: 25

| # | Namespace | Pod Name | Status |
|---|-----------|----------|--------|
| 1 | digitalbank-monitoring | prometheus-prometheus-node-exporter-tzhnm | Running |
| 2 | elk-demo | filebeat-md4pm | Running |
| 3 | gke-managed-cim | kube-state-metrics-0 | Running |
| 4 | gmp-system | collector-w9mxc | Running |
| 5 | kube-system | calico-node-sctm8 | Running |
| 6 | kube-system | calico-node-vertical-autoscaler-f4b8f4687-skksb | Running |
| 7 | kube-system | calico-typha-horizontal-autoscaler-5cdfd9f599-5dlhc | Running |
| 8 | kube-system | calico-typha-vertical-autoscaler-7f4dc485b8-4926h | Running |
| 9 | kube-system | event-exporter-gke-65dc84d6fc-ch2d9 | Running |
| 10 | kube-system | filestore-lock-release-controller-75fd59dc48-svvbg | Running |
| 11 | kube-system | filestore-node-64kb8 | Running |
| 12 | kube-system | fluentbit-gke-l772h | Running |
| 13 | kube-system | gke-metadata-server-kh88f | Running |
| 14 | kube-system | gke-metrics-agent-ktrdg | Running |
| 15 | kube-system | ip-masq-agent-9pqck | Running |
| 16 | kube-system | konnectivity-agent-989d4fc9c-t97z8 | Running |
| 17 | kube-system | konnectivity-agent-autoscaler-86684c58bf-vx7td | Running |
| 18 | kube-system | kube-dns-6b7c66cd74-msjtr | Running |
| 19 | kube-system | kube-dns-6b7c66cd74-xwpts | Running |
| 20 | kube-system | kube-dns-autoscaler-68ffcff74f-689fw | Running |
| 21 | kube-system | kube-proxy-gke-digitalbank-gke-digitalbank-gke-n-21d17511-0h9m | Running |
| 22 | kube-system | l7-default-backend-78858cccc9-wxtxq | Running |
| 23 | kube-system | netd-dm59x | Running |
| 24 | kube-system | pdcsi-node-mc7cs | Running |
| 25 | logging | filebeat-fbtnl | Running |

---

### Node 5: gke-digitalbank-gke-digitalbank-gke-n-21d17511-7ppr
**Zone**: us-central1-b | **IP**: 10.0.0.6 | **Pods**: 18

| # | Namespace | Pod Name | Status |
|---|-----------|----------|--------|
| 1 | argocd | argocd-repo-server-584c74755d-k4b2g | Running |
| 2 | digitalbank-apps | accounts-api-78fd8c94bc-lfwwj | Running |
| 3 | digitalbank-monitoring | prometheus-prometheus-node-exporter-7mml5 | Running |
| 4 | digitalbank | auth-api-7bcd695fcb-gxczb | Running |
| 5 | digitalbank | transactions-api-5dc57f5f75-d8kh2 | Running |
| 6 | elk-demo | filebeat-nd2cw | Running |
| 7 | gmp-system | collector-q8t28 | Running |
| 8 | kube-system | calico-node-b728b | Running |
| 9 | kube-system | filestore-node-58rlr | Running |
| 10 | kube-system | fluentbit-gke-ps2fl | Running |
| 11 | kube-system | gke-metadata-server-jvwmp | Running |
| 12 | kube-system | gke-metrics-agent-ps22p | Running |
| 13 | kube-system | ip-masq-agent-59gnc | Running |
| 14 | kube-system | kube-proxy-gke-digitalbank-gke-digitalbank-gke-n-21d17511-7ppr | Running |
| 15 | kube-system | netd-4pbjz | Running |
| 16 | kube-system | pdcsi-node-wfh8m | Running |
| 17 | logging | filebeat-hjvp9 | Running |
| 18 | logging | logstash-6c575df7bf-m65bk | Running |

---

### Node 6: gke-digitalbank-gke-digitalbank-gke-n-21d17511-c687
**Zone**: us-central1-b | **IP**: 10.0.0.5 | **Pods**: 17

| # | Namespace | Pod Name | Status |
|---|-----------|----------|--------|
| 1 | digitalbank-monitoring | prometheus-prometheus-kube-prometheus-prometheus-0 | Running |
| 2 | digitalbank-monitoring | prometheus-prometheus-node-exporter-542vs | Running |
| 3 | digitalbank | accounts-api-85d9578f9c-2v49j | Running |
| 4 | digitalbank | auth-api-585f55f4bc-vpvlh | Running |
| 5 | elk-demo | filebeat-5mn2s | Running |
| 6 | gmp-system | collector-94nl8 | Running |
| 7 | kube-system | calico-node-dkd4h | Running |
| 8 | kube-system | filestore-node-m4qjw | Running |
| 9 | kube-system | fluentbit-gke-qjz29 | Running |
| 10 | kube-system | gke-metadata-server-hqvsr | Running |
| 11 | kube-system | gke-metrics-agent-9xkpn | Running |
| 12 | kube-system | ip-masq-agent-c685v | Running |
| 13 | kube-system | kube-proxy-gke-digitalbank-gke-digitalbank-gke-n-21d17511-c687 | Running |
| 14 | kube-system | netd-8vf28 | Running |
| 15 | kube-system | pdcsi-node-kgqg9 | Running |
| 16 | logging | elasticsearch-master-1 | Running |
| 17 | logging | filebeat-mlbt7 | Running |

---

### Node 7: gke-digitalbank-gke-digitalbank-gke-n-e353b711-17l7
**Zone**: us-central1-f | **IP**: 10.0.0.10 | **Pods**: 19

| # | Namespace | Pod Name | Status |
|---|-----------|----------|--------|
| 1 | argocd | argocd-applicationset-controller-79784469f4-rwjdw | Running |
| 2 | argocd | argocd-redis-6976f55b89-n7hd2 | Running |
| 3 | digitalbank-monitoring | prometheus-prometheus-node-exporter-w79h6 | Running |
| 4 | digitalbank | auth-api-7bcd695fcb-t2pmr | Running |
| 5 | elk-demo | filebeat-72z2h | Running |
| 6 | gmp-system | collector-vcwzm | Running |
| 7 | kube-system | calico-node-wbzzw | Running |
| 8 | kube-system | filestore-node-kfthb | Running |
| 9 | kube-system | fluentbit-gke-wrpsd | Running |
| 10 | kube-system | gke-metadata-server-kjslb | Running |
| 11 | kube-system | gke-metrics-agent-fh9mr | Running |
| 12 | kube-system | ip-masq-agent-v4vcg | Running |
| 13 | kube-system | konnectivity-agent-989d4fc9c-fxstp | Running |
| 14 | kube-system | kube-proxy-gke-digitalbank-gke-digitalbank-gke-n-e353b711-17l7 | Running |
| 15 | kube-system | netd-56mwd | Running |
| 16 | kube-system | pdcsi-node-vfhcv | Running |
| 17 | kyverno | kyverno-cleanup-controller-679875bcf8-5ml9s | Running |
| 18 | logging | elasticsearch-master-2 | Running |
| 19 | logging | filebeat-5cnj5 | Running |

---

### Node 8: gke-digitalbank-gke-digitalbank-gke-n-e353b711-63x8
**Zone**: us-central1-f | **IP**: 10.0.0.8 | **Pods**: 22

| # | Namespace | Pod Name | Status |
|---|-----------|----------|--------|
| 1 | argocd | argocd-application-controller-0 | Running |
| 2 | argocd | argocd-notifications-controller-85fbf988f-xkczx | Running |
| 3 | digitalbank-apps | auth-api-5dfdf8556b-2czrq | Running |
| 4 | digitalbank-monitoring | alertmanager-prometheus-kube-prometheus-alertmanager-0 | Running |
| 5 | digitalbank-monitoring | prometheus-prometheus-node-exporter-p28vd | Running |
| 6 | digitalbank | accounts-api-85d9578f9c-nwg2b | Running |
| 7 | elk-demo | filebeat-lncvn | Running |
| 8 | gmp-system | collector-sb5qd | Running |
| 9 | gmp-system | gmp-operator-d55775f55-4wczh | Running |
| 10 | kube-system | calico-node-h6hlz | Running |
| 11 | kube-system | filestore-node-hxmld | Running |
| 12 | kube-system | fluentbit-gke-dfffr | Running |
| 13 | kube-system | gke-metadata-server-5f78r | Running |
| 14 | kube-system | gke-metrics-agent-cmtvv | Running |
| 15 | kube-system | ip-masq-agent-2sq8g | Running |
| 16 | kube-system | konnectivity-agent-989d4fc9c-ghc2c | Running |
| 17 | kube-system | kube-proxy-gke-digitalbank-gke-digitalbank-gke-n-e353b711-63x8 | Running |
| 18 | kube-system | netd-q87m8 | Running |
| 19 | kube-system | pdcsi-node-gg8pj | Running |
| 20 | kyverno | kyverno-background-controller-7c9f5b66dc-q7xzp | Running |
| 21 | logging | filebeat-gdxxw | Running |
| 22 | logging | logstash-6c575df7bf-nnlbs | Running |

---

### Node 9: gke-digitalbank-gke-digitalbank-gke-n-e353b711-j2bx
**Zone**: us-central1-f | **IP**: 10.0.0.9 | **Pods**: 22

| # | Namespace | Pod Name | Status |
|---|-----------|----------|--------|
| 1 | argocd | argocd-dex-server-5b9db45777-hzdfs | Running |
| 2 | argocd | argocd-server-748c95df66-bsp8n | Running |
| 3 | digitalbank-apps | digitalbank-frontend-5fc9bdb9f6-vrbsm | Running |
| 4 | digitalbank-monitoring | prometheus-grafana-5f68cd8454-f8bjk | Running |
| 5 | digitalbank-monitoring | prometheus-prometheus-node-exporter-92gqx | Running |
| 6 | digitalbank | digitalbank-frontend-859c458967-s9gfz | Running |
| 7 | elk-demo | filebeat-nw224 | Running |
| 8 | gmp-system | collector-c9llq | Running |
| 9 | ingress-nginx | nginx-ingress-ingress-nginx-controller-5df8d8565b-k28mh | Running |
| 10 | kube-system | calico-node-bshct | Running |
| 11 | kube-system | calico-typha-594fb65f77-8pt7d | Running |
| 12 | kube-system | filestore-node-l66z9 | Running |
| 13 | kube-system | fluentbit-gke-sjvs4 | Running |
| 14 | kube-system | gke-metadata-server-hbpdb | Running |
| 15 | kube-system | gke-metrics-agent-vxsb5 | Running |
| 16 | kube-system | ip-masq-agent-x5wdd | Running |
| 17 | kube-system | konnectivity-agent-989d4fc9c-nwqn8 | Running |
| 18 | kube-system | kube-proxy-gke-digitalbank-gke-digitalbank-gke-n-e353b711-j2bx | Running |
| 19 | kube-system | metrics-server-v1.33.0-dcf7fc67b-425ld | Running |
| 20 | kube-system | netd-h2kd7 | Running |
| 21 | kube-system | pdcsi-node-hq75m | Running |
| 22 | logging | filebeat-2gnvv | Running |

---

## Pod Distribution by Namespace

| Namespace | Pod Count | Purpose |
|-----------|-----------|---------|
| kube-system | ~90 | Kubernetes system components (networking, DNS, storage, monitoring) |
| digitalbank-monitoring | ~20 | Prometheus, Grafana, Alertmanager, Node Exporters |
| logging | ~20 | Elasticsearch cluster, Kibana, Logstash, Filebeat DaemonSets |
| elk-demo | ~12 | Demo ELK stack deployment |
| gmp-system | ~10 | Google Managed Prometheus collectors and operators |
| argocd | 7 | GitOps continuous delivery (ArgoCD controllers and UI) |
| digitalbank-apps | 4 | **Production Digital Banking Applications** |
| kyverno | 4 | Kubernetes policy engine controllers |
| jenkins | 1 | CI/CD automation server |
| ingress-nginx | 1 | NGINX ingress controller |
| gke-managed-cim | 1 | GKE cluster inventory management |
| digitalbank | ~10 | Legacy/previous deployment (some in CrashLoopBackOff) |

---

## Application Services (digitalbank-apps namespace)

| Service | Pods | Type | Port | Status |
|---------|------|------|------|--------|
| auth-api | 1 | ClusterIP | 3001 | Running ✅ |
| accounts-api | 1 | ClusterIP | 3002 | Running ✅ |
| transactions-api | 1 | ClusterIP | 3003 | Running ✅ |
| digitalbank-frontend | 1 | ClusterIP | 80 | Running ✅ |

---

## Infrastructure Components

### Monitoring & Observability
- **Prometheus Stack**: Metrics collection and alerting
- **Grafana**: Visualization and dashboards
- **Alertmanager**: Alert routing and notification
- **ELK Stack**: Centralized logging (Elasticsearch, Logstash, Kibana)
- **Filebeat**: Log shipping from all nodes
- **Google Managed Prometheus**: Additional GCP-integrated monitoring

### GitOps & CI/CD
- **ArgoCD**: Continuous delivery with GitOps methodology
- **Jenkins**: Build and deployment automation

### Security & Policy
- **Kyverno**: Policy enforcement and governance
- **Network Policies**: Calico for network segmentation

### Ingress & Load Balancing
- **NGINX Ingress Controller**: External traffic routing
- **External IP**: 34.31.22.16

---

## Resource Allocation Summary

| Resource Type | Per Node | Total Cluster |
|---------------|----------|---------------|
| vCPU | 2 | 18 |
| Memory | 8 GB | 72 GB |
| Nodes | - | 9 |
| Pods (Running) | ~20 avg | 179 |
| Max Pods/Node | 110 | 990 |
| Utilization | ~18% | ~18% |

---

## High Availability Configuration

✅ **Multi-zone deployment** across 3 availability zones  
✅ **9 worker nodes** distributed evenly (3 per zone)  
✅ **Stateful workloads** (Elasticsearch) replicated across zones  
✅ **DaemonSets** ensure system components on every node  
✅ **Regional cluster** with automatic failover capabilities

---

## Notes

1. **Active Production Apps**: The `digitalbank-apps` namespace contains the current production deployment
2. **Legacy Pods**: Some pods in the `digitalbank` namespace show CrashLoopBackOff status (older deployments)
3. **System Stability**: 179/179 pods running successfully (excluding legacy namespace issues)
4. **Monitoring Coverage**: Full observability with dual monitoring stacks (Prometheus + GMP)
5. **Logging Coverage**: Complete log aggregation via Filebeat DaemonSets on all nodes

---

## Quick Access Commands

```bash
# View cluster status
kubectl get nodes
kubectl get pods --all-namespaces

# Access specific namespace
kubectl get pods -n digitalbank-apps
kubectl get svc -n digitalbank-apps

# View application logs
kubectl logs -n digitalbank-apps -l app=auth-api
kubectl logs -n digitalbank-apps -l app=accounts-api
kubectl logs -n digitalbank-apps -l app=transactions-api

# Access monitoring
kubectl get svc -n digitalbank-monitoring
kubectl get ingress --all-namespaces

# Check cluster health
kubectl top nodes
kubectl top pods --all-namespaces
```

---

**Document Version**: 1.0  
**Last Updated**: January 30, 2026  
**Maintained By**: DevOps Team
