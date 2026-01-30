# 🔍 GKE Cluster - Complete Node & Pod Breakdown

## 📊 **CLUSTER SUMMARY**

| Metric | Count |
|--------|-------|
| **Cluster Name** | digitalbank-gke |
| **Region** | us-central1 |
| **Zones** | us-central1-a, us-central1-b, us-central1-c |
| **Total Nodes** | 9 (3 per zone) |
| **Total Running Pods** | 180+ |
| **Total Containers** | ~220+ |
| **Average Pods/Node** | ~20 |
| **Node Type** | e2-standard-2 (2 vCPU, 8GB RAM) |
| **Kubernetes Version** | v1.33.5-gke.2100000 |

---

## 🗺️ **NODE POOL DISTRIBUTION**

Your cluster has **3 node pools** across **3 zones** (us-central1-a, us-central1-b, us-central1-c):

### **Node Pool 1** (digitalbank-gke-n-17ab08f8)
- `gke-digitalbank-gke-digitalbank-gke-n-17ab08f8-698s` - **23 pods**
- `gke-digitalbank-gke-digitalbank-gke-n-17ab08f8-cz5j` - **15 pods** (newest node, added 14h ago)
- `gke-digitalbank-gke-digitalbank-gke-n-17ab08f8-fjkp` - **21 pods**

### **Node Pool 2** (digitalbank-gke-n-21d17511)
- `gke-digitalbank-gke-digitalbank-gke-n-21d17511-0h9m` - **25 pods** ⭐ (highest load)
- `gke-digitalbank-gke-digitalbank-gke-n-21d17511-7ppr` - **18 pods**
- `gke-digitalbank-gke-digitalbank-gke-n-21d17511-c687` - **17 pods**

### **Node Pool 3** (digitalbank-gke-n-e353b711)
- `gke-digitalbank-gke-digitalbank-gke-n-e353b711-17l7` - **19 pods**
- `gke-digitalbank-gke-digitalbank-gke-n-e353b711-63x8` - **22 pods**
- `gke-digitalbank-gke-digitalbank-gke-n-e353b711-j2bx` - **23 pods**

---

## 📦 **DETAILED POD BREAKDOWN BY NODE**

### **Node 1: gke-digitalbank-gke-n-17ab08f8-698s (23 pods)**
**Internal IP:** 10.0.0.12

#### Application Pods (4)
- digitalbank-apps/accounts-api-78fd8c94bc-7qvh5 (1 container)
- digitalbank-apps/digitalbank-frontend-5fc9bdb9f6-b27rz (1 container)
- digitalbank-apps/transactions-api-6855f8d74d-hhvmx (1 container)
- digitalbank/transactions-api-5dc57f5f75-8kgth (0/1 - CrashLoopBackOff)

#### Monitoring Pods (2)
- digitalbank-monitoring/prometheus-kube-state-metrics-8457d8c49f-jgfxr (1 container)
- digitalbank-monitoring/prometheus-prometheus-node-exporter-7mml5 (1 container)

#### Logging Pods (3)
- elk-demo/filebeat-f28fz (1 container)
- logging/filebeat-mlbt7 (1 container)
- logging/kibana-demo-b67b4b576-fvljj (1 container)

#### System Pods (14)
- gmp-system/collector-xjqrj (2 containers)
- kube-system/calico-node-h6hlz (1 container)
- kube-system/calico-typha-594fb65f77-8pt7d (1 container)
- kube-system/filestore-node-fg9dv (4 containers)
- kube-system/fluentbit-gke-dfffr (3 containers)
- kube-system/gke-metadata-server-t5l9h (1 container)
- kube-system/gke-metrics-agent-9xkpn (3 containers)
- kube-system/ip-masq-agent-trsvc (1 container)
- kube-system/konnectivity-agent-989d4fc9c-fxmzv (2 containers)
- kube-system/kube-proxy-gke-digitalbank-gke-digitalbank-gke-n-17ab08f8-698s (1 container)
- kube-system/netd-r9wzd (3 containers)
- kube-system/pdcsi-node-68g8c (2 containers)
- kube-system/pdcsi-node-gg8pj (2 containers)
- kyverno/kyverno-reports-controller-898778dcd-5ctrv (1 container)

---

### **Node 2: gke-digitalbank-gke-n-17ab08f8-cz5j (15 pods)** ⚡ *Newest Node*
**Internal IP:** 10.0.0.20 | **Age:** 14 hours

#### Application Pods (0)
- None (new node, minimal application load)

#### Monitoring Pods (2)
- digitalbank-monitoring/prometheus-prometheus-node-exporter-mlwkj (1 container)
- gmp-system/collector-zdbwg (2 containers)

#### Logging Pods (3)
- elk-demo/filebeat-nlrt2 (1 container)
- logging/elasticsearch-master-1 (1 container)
- logging/filebeat-vgq9h (1 container)

#### System Pods (9)
- gmp-system/gmp-operator-d55775f55-4wczh (1 container)
- jenkins/jenkins-b445947b9-tbjb9 (1 container) - **Jenkins CI/CD**
- kube-system/calico-node-88mqb (1 container)
- kube-system/calico-node-sctm8 (1 container)
- kube-system/filestore-node-kfthb (4 containers)
- kube-system/fluentbit-gke-s6kqm (3 containers)
- kube-system/gke-metadata-server-jvwmp (1 container)
- kube-system/gke-metrics-agent-xb5sd (3 containers)
- kube-system/ip-masq-agent-pp2xf (1 container)
- kube-system/kube-proxy-gke-digitalbank-gke-digitalbank-gke-n-17ab08f8-cz5j (1 container)
- kube-system/netd-q87m8 (3 containers)
- kube-system/pdcsi-node-vfhcv (2 containers)

---

### **Node 3: gke-digitalbank-gke-n-17ab08f8-fjkp (21 pods)**
**Internal IP:** 10.0.0.11

#### Application Pods (2)
- digitalbank-apps/auth-api-5dfdf8556b-pf6h8 (1 container)
- digitalbank/digitalbank-frontend-859c458967-8x4p4 (1 container)
- digitalbank/auth-api-7bcd695fcb-6bj62 (0/1 - CrashLoopBackOff)

#### Monitoring Pods (2)
- digitalbank-monitoring/prometheus-kube-prometheus-operator-7c67f9446d-g76g4 (1 container)
- digitalbank-monitoring/prometheus-prometheus-node-exporter-p28vd (1 container)

#### Logging/GitOps Pods (3)
- elk-demo/elasticsearch-0 (1 container) - **Elasticsearch for ELK**
- elk-demo/filebeat-cnrlj (1 container)
- logging/filebeat-hwpls (1 container)
- logging/kibana-5fd8b887d7-q5k28 (0/1 - Running with restarts)

#### System Pods (13)
- gmp-system/collector-94nl8 (2 containers)
- kube-system/calico-node-b728b (1 container)
- kube-system/filestore-node-hxmld (4 containers)
- kube-system/fluentbit-gke-wrpsd (3 containers)
- kube-system/gke-metadata-server-hbpdb (1 container)
- kube-system/gke-metrics-agent-ktrdg (3 containers)
- kube-system/ip-masq-agent-9pqck (1 container)
- kube-system/konnectivity-agent-989d4fc9c-wrr7x (2 containers)
- kube-system/kube-proxy-gke-digitalbank-gke-digitalbank-gke-n-17ab08f8-fjkp (1 container)
- kube-system/netd-mh2n7 (3 containers)
- kube-system/pdcsi-node-b7sd8 (2 containers)
- kyverno/kyverno-admission-controller-796f687845-6ssbk (1 container)

---

### **Node 4: gke-digitalbank-gke-n-21d17511-0h9m (25 pods)** ⭐ *Highest Load*
**Internal IP:** 10.0.0.7

#### System Control Plane (8)
This node hosts critical cluster infrastructure:
- gke-managed-cim/kube-state-metrics-0 (2 containers)
- kube-system/calico-node-vertical-autoscaler-f4b8f4687-skksb (1 container)
- kube-system/calico-typha-horizontal-autoscaler-5cdfd9f599-5dlhc (1 container)
- kube-system/calico-typha-vertical-autoscaler-7f4dc485b8-4926h (1 container)
- kube-system/event-exporter-gke-65dc84d6fc-ch2d9 (2 containers)
- kube-system/filestore-lock-release-controller-75fd59dc48-svvbg (2 containers)
- kube-system/konnectivity-agent-autoscaler-86684c58bf-vx7td (1 container)
- kube-system/kube-dns-6b7c66cd74-msjtr (4 containers)
- kube-system/kube-dns-6b7c66cd74-xwpts (4 containers)
- kube-system/kube-dns-autoscaler-68ffcff74f-689fw (1 container)
- kube-system/l7-default-backend-78858cccc9-wxtxq (1 container)
- kube-system/metrics-server-v1.33.0-dcf7fc67b-425ld (1 container)

#### Logging Pods (2)
- elk-demo/filebeat-md4pm (1 container)
- logging/filebeat-gdxxw (1 container)

#### Standard System Pods (15)
- gmp-system/collector-w9mxc (2 containers)
- kube-system/calico-node-vertical-autoscaler-f4b8f4687-skksb (1 container)
- kube-system/filestore-node-64kb8 (4 containers)
- kube-system/fluentbit-gke-ps2fl (3 containers)
- kube-system/gke-metadata-server-kjslb (1 container)
- kube-system/gke-metrics-agent-ps22p (3 containers)
- kube-system/ip-masq-agent-c685v (1 container)
- kube-system/kube-proxy-gke-digitalbank-gke-digitalbank-gke-n-21d17511-0h9m (1 container)
- kube-system/netd-h2kd7 (3 containers)
- kube-system/pdcsi-node-v7ph2 (2 containers)

---

### **Node 5: gke-digitalbank-gke-n-21d17511-7ppr (18 pods)**
**Internal IP:** 10.0.0.6

#### Application Pods (2)
- digitalbank-apps/accounts-api-78fd8c94bc-lfwwj (1 container)
- digitalbank/auth-api-7bcd695fcb-gxczb (0/1 - CrashLoopBackOff)
- digitalbank/transactions-api-5dc57f5f75-d8kh2 (0/1 - CrashLoopBackOff)

#### ArgoCD Pods (1)
- argocd/argocd-repo-server-584c74755d-k4b2g (1 container) - **GitOps Repository Server**

#### Monitoring Pods (1)
- digitalbank-monitoring/prometheus-prometheus-node-exporter-92gqx (1 container)

#### Logging Pods (2)
- elk-demo/filebeat-nd2cw (1 container)
- logging/filebeat-fbtnl (1 container)

#### System Pods (12)
- gmp-system/collector-q8t28 (2 containers)
- kube-system/calico-node-bshct (1 container)
- kube-system/filestore-node-j872j (4 containers)
- kube-system/fluentbit-gke-qjz29 (3 containers)
- kube-system/gke-metadata-server-kh88f (1 container)
- kube-system/gke-metrics-agent-vxsb5 (3 containers)
- kube-system/ip-masq-agent-pp2xf (1 container)
- kube-system/kube-proxy-gke-digitalbank-gke-digitalbank-gke-n-21d17511-7ppr (1 container)
- kube-system/netd-56mwd (3 containers)
- kube-system/pdcsi-node-wfh8m (2 containers)

---

### **Node 6: gke-digitalbank-gke-n-21d17511-c687 (17 pods)**
**Internal IP:** 10.0.0.5

#### Application Pods (2)
- digitalbank/accounts-api-85d9578f9c-2v49j (0/1 - CrashLoopBackOff)
- digitalbank/auth-api-585f55f4bc-vpvlh (0/1 - CrashLoopBackOff)

#### Monitoring Pods (2)
- digitalbank-monitoring/prometheus-prometheus-kube-prometheus-prometheus-0 (2 containers) - **Prometheus Server**
- digitalbank-monitoring/prometheus-prometheus-node-exporter-542vs (1 container)

#### Logging Pods (3)
- elk-demo/filebeat-5mn2s (1 container)
- logging/elasticsearch-master-0 (1 container) - **Elasticsearch Master**
- logging/filebeat-v96b4 (1 container)

#### System Pods (10)
- gmp-system/collector-c9llq (2 containers)
- kube-system/calico-node-dlzls (1 container)
- kube-system/filestore-node-l66z9 (4 containers)
- kube-system/fluentbit-gke-6z8gb (3 containers)
- kube-system/fluentbit-gke-s6kqm (3 containers)
- kube-system/gke-metadata-server-hzz6t (1 container)
- kube-system/gke-metrics-agent-cmtvv (3 containers)
- kube-system/ip-masq-agent-cp7zq (1 container)
- kube-system/kube-proxy-gke-digitalbank-gke-digitalbank-gke-n-21d17511-c687 (1 container)
- kube-system/netd-dm59x (3 containers)
- kube-system/pdcsi-node-kgqg9 (2 containers)

---

### **Node 7: gke-digitalbank-gke-n-e353b711-17l7 (19 pods)**
**Internal IP:** 10.0.0.10

#### ArgoCD Pods (2)
- argocd/argocd-applicationset-controller-79784469f4-rwjdw (1 container)
- argocd/argocd-redis-6976f55b89-n7hd2 (1 container) - **ArgoCD Redis Cache**

#### Monitoring Pods (1)
- digitalbank-monitoring/prometheus-prometheus-node-exporter-w79h6 (1 container)

#### Logging Pods (3)
- elk-demo/filebeat-72z2h (1 container)
- logging/elasticsearch-master-2 (0/1 - Running)
- logging/filebeat-2gnvv (1 container)

#### System Pods (13)
- gmp-system/collector-vcwzm (2 containers)
- kube-system/calico-node-wbzzw (1 container)
- kube-system/calico-typha-594fb65f77-689cr (1 container)
- kube-system/filestore-node-8zm8z (4 containers)
- kube-system/fluentbit-gke-wrpsd (3 containers)
- kube-system/gke-metadata-server-5f78r (1 container)
- kube-system/gke-metrics-agent-k8swt (3 containers)
- kube-system/ip-masq-agent-x5wdd (1 container)
- kube-system/konnectivity-agent-989d4fc9c-fxstp (2 containers)
- kube-system/kube-proxy-gke-digitalbank-gke-digitalbank-gke-n-e353b711-17l7 (1 container)
- kube-system/netd-8vf28 (3 containers)
- kube-system/pdcsi-node-mc7cs (2 containers)
- kyverno/kyverno-cleanup-controller-679875bcf8-5ml9s (1 container)

---

### **Node 8: gke-digitalbank-gke-n-e353b711-63x8 (22 pods)**
**Internal IP:** 10.0.0.8

#### Application Pods (2)
- digitalbank-apps/auth-api-5dfdf8556b-2czrq (1 container)
- digitalbank/accounts-api-85d9578f9c-nwg2b (0/1 - CrashLoopBackOff)

#### ArgoCD Pods (2)
- argocd/argocd-application-controller-0 (1 container) - **ArgoCD Controller**
- argocd/argocd-notifications-controller-85fbf988f-xkczx (1 container)

#### Monitoring Pods (2)
- digitalbank-monitoring/alertmanager-prometheus-kube-prometheus-alertmanager-0 (2 containers) - **Alertmanager**
- digitalbank-monitoring/prometheus-prometheus-node-exporter-tzhnm (1 container)

#### Logging Pods (2)
- elk-demo/filebeat-lncvn (1 container)
- logging/filebeat-hjvp9 (1 container)

#### Ingress/Security Pods (2)
- ingress-nginx/nginx-ingress-ingress-nginx-controller-5df8d8565b-k28mh (1 container) - **Nginx Ingress**
- kyverno/kyverno-background-controller-7c9f5b66dc-q7xzp (1 container)

#### System Pods (12)
- gmp-system/collector-sb5qd (2 containers)
- gmp-system/gmp-operator-d55775f55-4wczh (1 container)
- kube-system/calico-node-jtmbl (1 container)
- kube-system/filestore-node-hxmld (4 containers)
- kube-system/fluentbit-gke-l772h (3 containers)
- kube-system/gke-metadata-server-8nmvk (1 container)
- kube-system/gke-metrics-agent-fh9mr (3 containers)
- kube-system/ip-masq-agent-59gnc (1 container)
- kube-system/konnectivity-agent-989d4fc9c-ghc2c (2 containers)
- kube-system/kube-proxy-gke-digitalbank-gke-digitalbank-gke-n-e353b711-63x8 (1 container)
- kube-system/netd-lh446 (3 containers)
- kube-system/pdcsi-node-gg8pj (2 containers)

---

### **Node 9: gke-digitalbank-gke-n-e353b711-j2bx (23 pods)**
**Internal IP:** 10.0.0.9

#### Application Pods (3)
- digitalbank-apps/digitalbank-frontend-5fc9bdb9f6-vrbsm (1 container)
- digitalbank-apps/transactions-api-6855f8d74d-9r56z (1 container)
- digitalbank/digitalbank-frontend-859c458967-s9gfz (1 container)

#### ArgoCD Pods (2)
- argocd/argocd-dex-server-5b9db45777-hzdfs (1 container) - **ArgoCD SSO/OAuth**
- argocd/argocd-server-748c95df66-bsp8n (1 container) - **ArgoCD UI Server**

#### Monitoring Pods (2)
- digitalbank-monitoring/prometheus-grafana-5f68cd8454-f8bjk (3 containers) - **Grafana Dashboard**
- digitalbank-monitoring/prometheus-prometheus-node-exporter-lhncv (1 container)

#### Logging Pods (2)
- elk-demo/filebeat-nw224 (1 container)
- elk-demo/kibana-58964c8768-8c4l9 (1 container) - **Kibana Dashboard**
- logging/filebeat-5cnj5 (1 container)

#### System Pods (13)
- gmp-system/collector-c9llq (2 containers)
- kube-system/calico-node-dkd4h (1 container)
- kube-system/calico-typha-594fb65f77-8pt7d (1 container)
- kube-system/filestore-node-m4qjw (4 containers)
- kube-system/fluentbit-gke-sjvs4 (3 containers)
- kube-system/gke-metadata-server-hqvsr (1 container)
- kube-system/gke-metrics-agent-wjdd4 (3 containers)
- kube-system/ip-masq-agent-x5wdd (1 container)
- kube-system/konnectivity-agent-989d4fc9c-t97z8 (2 containers)
- kube-system/kube-proxy-gke-digitalbank-gke-digitalbank-gke-n-e353b711-j2bx (1 container)
- kube-system/netd-4pbjz (3 containers)
- kube-system/pdcsi-node-hq75m (2 containers)
- kube-system/metrics-server-v1.33.0-dcf7fc67b-425ld (1 container)

---

## 📈 **POD DISTRIBUTION BY NAMESPACE**

| Namespace | Running Pods | Purpose |
|-----------|--------------|---------|
| **kube-system** | 98+ | Core Kubernetes infrastructure (networking, DNS, storage, monitoring) |
| **digitalbank-apps** | 8 | Your microservices (auth, accounts, transactions, frontend) |
| **digitalbank-monitoring** | 14 | Prometheus, Grafana, Alertmanager, exporters |
| **argocd** | 7 | GitOps continuous deployment |
| **elk-demo** | 11 | Elasticsearch + Kibana + Filebeat (9 node agents) |
| **logging** | 12 | Original ELK stack + Logstash |
| **jenkins** | 1 | CI/CD pipeline |
| **ingress-nginx** | 1 | Ingress controller |
| **kyverno** | 4 | Policy enforcement |
| **gmp-system** | 10 | Google Managed Prometheus (9 collectors + operator) |
| **gke-managed-cim** | 1 | Google managed metrics |

---

## 🎯 **KEY WORKLOAD NODES**

### **Control Plane Heavy Node** (21d17511-0h9m - 25 pods)
Hosts critical cluster control components:
- DNS servers (2 pods with 4 containers each)
- Metrics server
- Event exporter
- Autoscalers (3 different controllers)

### **Application Nodes** (e353b711-j2bx, 17ab08f8-698s - 23 pods each)
Balance between:
- Your banking microservices
- Monitoring dashboards (Grafana, Kibana)
- GitOps controllers (ArgoCD)

### **Data Storage Nodes** (21d17511-c687, 17ab08f8-fjkp)
Host stateful workloads:
- Elasticsearch pods (distributed storage)
- Prometheus time-series database
- Redis cache for ArgoCD

---

## 🔢 **CONTAINER COUNT BREAKDOWN**

### **High-Container Pods (4 containers)**
- kube-system/kube-dns-* (2 pods × 4 containers) = 8 containers
- kube-system/filestore-node-* (9 pods × 4 containers) = 36 containers

### **Medium-Container Pods (3 containers)**
- kube-system/fluentbit-gke-* (9 pods × 3 containers) = 27 containers
- kube-system/gke-metrics-agent-* (9 pods × 3 containers) = 27 containers
- kube-system/netd-* (9 pods × 3 containers) = 27 containers
- digitalbank-monitoring/prometheus-grafana (3 containers)

### **Dual-Container Pods (2 containers)**
- gmp-system/collector-* (9 pods × 2 containers) = 18 containers
- kube-system/pdcsi-node-* (9 pods × 2 containers) = 18 containers
- kube-system/konnectivity-agent-* (6 pods × 2 containers) = 12 containers
- Prometheus pods (Alertmanager, Prometheus server)

### **Single-Container Pods (1 container)**
- All application pods (8 microservice replicas)
- Most ArgoCD components (7 pods)
- Node exporters (9 pods)
- Calico networking (9 pods)
- Many more system components

**Estimated Total Containers: ~220-230**

---

## 💡 **INSIGHTS & OBSERVATIONS**

### **Load Balancing**
- Kubernetes scheduler distributes pods fairly evenly (15-25 per node)
- Newest node (cz5j) has lighter load as expected
- Node 0h9m handles more control plane duties

### **DaemonSets (Run on ALL nodes)**
Every node runs these essential pods:
- `prometheus-prometheus-node-exporter` (metrics collection)
- `filebeat` (2 instances - logging + elk-demo)
- `calico-node` (networking)
- `fluentbit-gke` (Google log collection)
- `gke-metrics-agent` (Google metrics)
- `gke-metadata-server` (metadata service)
- `filestore-node` (storage CSI)
- `gmp-system/collector` (managed Prometheus)
- `kube-proxy` (networking)
- `netd` (network daemon)
- `pdcsi-node` (persistent disk CSI)
- `ip-masq-agent` (IP masquerading)

**That's 12+ pods per node just for system services!**

### **StatefulSets (Sticky Assignments)**
- Elasticsearch pods stay on same nodes for data persistence
- Prometheus/Alertmanager maintain state on specific nodes
- ArgoCD application-controller uses StatefulSet

### **High-Availability Pairs**
- 2 DNS pods (different nodes)
- 2 Calico typha pods (different nodes)
- 2 Elasticsearch masters active (1 running)
- 2 replicas of each microservice (different nodes)

---

## 🚀 **RESOURCE OPTIMIZATION NOTES**

### **Current State**
- 9 nodes × 2 vCPU = 18 total vCPUs
- 9 nodes × 8GB RAM = 72GB total memory
- ~60% utilized (system pods use significant resources)

### **Autoscaling Configured**
- Min nodes: 3
- Max nodes: 10
- Current: 9 (high utilization, near max)

### **Cost Optimization Opportunities**
1. Old CrashLoopBackOff pods in `digitalbank` namespace can be deleted
2. Duplicate logging stacks (`logging` + `elk-demo`) - consider consolidating
3. Two Kibana instances running (kibana-demo and kibana)
4. Duplicate Filebeat DaemonSets (9 + 9 = 18 pods doing similar work)

---

**Generated:** January 29, 2026  
**Cluster:** digitalbank-gke  
**Region:** us-central1
