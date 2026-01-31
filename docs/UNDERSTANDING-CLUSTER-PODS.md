# Understanding Your Kubernetes Cluster: Nodes vs Pods

**Date**: January 31, 2026  
**Cluster**: digitalbank-gke  
**Total Nodes**: 9  
**Total Pods**: 179

---

## Quick Answer

**You have only 4 application pods running your banking services.**  
The other 175 pods are Kubernetes infrastructure that makes everything work.

---

## What's the Difference?

### Nodes (Physical Resources)
- **Nodes** = Virtual machines (servers) in Google Cloud
- You have **9 nodes**, each is an `e2-standard-2` machine (2 vCPU, 8 GB RAM)
- Nodes are distributed across 3 availability zones for high availability
- Think of nodes as the "computers" that run your containers

### Pods (Containers)
- **Pods** = Containers running your applications or services
- You have **179 pods total** running across your 9 nodes
- Pods can be moved between nodes if a node fails
- Think of pods as the "programs" running on those computers

---

## Your Application Pods (Only 4!)

These are YOUR actual banking microservices:

| Service | Pod Count | What It Does |
|---------|-----------|--------------|
| **auth-api** | 1 | Authentication and user login |
| **accounts-api** | 1 | Bank account management |
| **transactions-api** | 1 | Payment processing and transfers |
| **digitalbank-frontend** | 1 | Web interface (React app) |
| **TOTAL** | **4** | Your complete banking application |

Each service runs in **1 pod** (you can scale to multiple pods later if needed).

---

## Why 179 Total Pods?

The remaining **175 pods** are Kubernetes infrastructure. Here's why you need them:

---

## Understanding DaemonSets

**Key Concept**: A DaemonSet automatically creates one pod on EVERY node.

### Formula:
```
If you have 9 nodes and 11 DaemonSets:
9 nodes × 11 DaemonSets = 99 pods
```

### Example - Calico Networking:

```
┌─────────────────────────────────────────────────────────┐
│ YOUR CLUSTER (9 Nodes)                                   │
├─────────────────────────────────────────────────────────┤
│                                                           │
│  Node 1 (us-central1-a)                                  │
│  └── calico-node-dlzls ◄── Networking pod for Node 1    │
│                                                           │
│  Node 2 (us-central1-a)                                  │
│  └── calico-node-jtmbl ◄── Networking pod for Node 2    │
│                                                           │
│  Node 3 (us-central1-a)                                  │
│  └── calico-node-88mqb ◄── Networking pod for Node 3    │
│                                                           │
│  Node 4 (us-central1-b)                                  │
│  └── calico-node-sctm8 ◄── Networking pod for Node 4    │
│                                                           │
│  Node 5 (us-central1-b)                                  │
│  └── calico-node-b728b ◄── Networking pod for Node 5    │
│                                                           │
│  Node 6 (us-central1-b)                                  │
│  └── calico-node-dkd4h ◄── Networking pod for Node 6    │
│                                                           │
│  Node 7 (us-central1-f)                                  │
│  └── calico-node-wbzzw ◄── Networking pod for Node 7    │
│                                                           │
│  Node 8 (us-central1-f)                                  │
│  └── calico-node-h6hlz ◄── Networking pod for Node 8    │
│                                                           │
│  Node 9 (us-central1-f)                                  │
│  └── calico-node-bshct ◄── Networking pod for Node 9    │
│                                                           │
└─────────────────────────────────────────────────────────┘

RESULT: 9 calico-node pods (one per node)
```

---

## DaemonSet Pods (Run on ALL Nodes)

These system components run **1 pod per node** = **9 pods each**:

| DaemonSet Name | Purpose | Pods (9 nodes) |
|----------------|---------|----------------|
| **calico-node** | Container networking between pods | 9 |
| **filebeat** | Collect logs from each node | 9 |
| **fluentbit-gke** | Send logs to Google Cloud Logging | 9 |
| **gke-metadata-server** | Provide GCP metadata to pods | 9 |
| **gke-metrics-agent** | Collect metrics from each node | 9 |
| **ip-masq-agent** | Manage IP masquerading for networking | 9 |
| **kube-proxy** | Route network traffic to correct pods | 9 |
| **netd** | GKE-specific networking | 9 |
| **pdcsi-node** | Enable persistent disk storage | 9 |
| **filestore-node** | Enable Google Filestore volumes | 9 |
| **prometheus-node-exporter** | Export node metrics to Prometheus | 9 |
| **SUBTOTAL** | | **~99 pods** |

**Why needed?**: Each node needs its own copy of these services to function properly.

---

## Complete Pod Breakdown

### Category 1: Your Applications (4 pods)
```
✅ auth-api              → 1 pod
✅ accounts-api          → 1 pod  
✅ transactions-api      → 1 pod
✅ digitalbank-frontend  → 1 pod
─────────────────────────────────
TOTAL: 4 pods
```

### Category 2: DaemonSet Pods (~99 pods)
```
System pods that MUST run on all 9 nodes:
- Networking (calico, kube-proxy, netd)         → 27 pods
- Logging (filebeat, fluentbit)                 → 18 pods
- Monitoring (gke-metrics, node-exporter)       → 18 pods
- Storage (pdcsi-node, filestore-node)          → 18 pods
- Other system agents (ip-masq, metadata)       → 18 pods
─────────────────────────────────────────────────────────
TOTAL: ~99 pods
```

### Category 3: Monitoring Stack (~30 pods)
```
Prometheus & Grafana:
- prometheus-server                             → 1 pod
- prometheus-operator                           → 1 pod
- prometheus-grafana                            → 1 pod
- alertmanager                                  → 1 pod
- kube-state-metrics                            → 1 pod

Google Managed Prometheus:
- gmp-operator                                  → 1 pod
- collectors (one per node)                     → 9 pods

Other monitoring:
- Various exporters and autoscalers             → ~15 pods
─────────────────────────────────────────────────────────
TOTAL: ~30 pods
```

### Category 4: Logging Stack (~20 pods)
```
ELK Stack:
- elasticsearch-master (3-node cluster)         → 3 pods
- elasticsearch (demo)                          → 1 pod
- kibana                                        → 2 pods
- logstash                                      → 2 pods
- Additional filebeat DaemonSets                → ~9 pods
- Other logging components                      → ~3 pods
─────────────────────────────────────────────────────────
TOTAL: ~20 pods
```

### Category 5: Kubernetes Core Services (~20 pods)
```
Essential cluster services:
- kube-dns (DNS resolution)                     → 2 pods
- kube-dns-autoscaler                           → 1 pod
- konnectivity-agent (API connectivity)         → 6 pods
- konnectivity-autoscaler                       → 1 pod
- calico-typha (networking controller)          → 2 pods
- calico-typha autoscalers                      → 2 pods
- calico-node autoscalers                       → 2 pods
- metrics-server                                → 1 pod
- event-exporter                                → 1 pod
- l7-default-backend (load balancer)            → 1 pod
- filestore-lock-controller                     → 1 pod
─────────────────────────────────────────────────────────
TOTAL: ~20 pods
```

### Category 6: DevOps & CI/CD Tools (~12 pods)
```
ArgoCD (GitOps):
- argocd-application-controller                 → 1 pod
- argocd-repo-server                            → 1 pod
- argocd-server (UI)                            → 1 pod
- argocd-redis                                  → 1 pod
- argocd-dex-server (SSO)                       → 1 pod
- argocd-notifications-controller               → 1 pod
- argocd-applicationset-controller              → 1 pod

Jenkins (CI/CD):
- jenkins                                       → 1 pod

Kyverno (Policy Engine):
- kyverno-admission-controller                  → 1 pod
- kyverno-background-controller                 → 1 pod
- kyverno-cleanup-controller                    → 1 pod
- kyverno-reports-controller                    → 1 pod
─────────────────────────────────────────────────────────
TOTAL: ~12 pods
```

### Category 7: Ingress & Networking (~3 pods)
```
- nginx-ingress-controller                      → 1 pod
- calico-typha (network policy)                 → 2 pods
─────────────────────────────────────────────────────────
TOTAL: ~3 pods
```

---

## Summary Table

| Category | Pod Count | Percentage | Purpose |
|----------|-----------|------------|---------|
| **Your Banking Apps** | **4** | **2.2%** | **Your actual business logic** |
| DaemonSet System Pods | 99 | 55.3% | Per-node agents (networking, logging, storage) |
| Monitoring Infrastructure | 30 | 16.8% | Prometheus, Grafana, metrics collection |
| Logging Infrastructure | 20 | 11.2% | Elasticsearch, Kibana, Logstash, log aggregation |
| Kubernetes Core | 20 | 11.2% | DNS, API connectivity, autoscaling, load balancing |
| DevOps Tools | 12 | 6.7% | ArgoCD, Jenkins, Kyverno policy engine |
| Ingress/Networking | 3 | 1.7% | External traffic routing |
| **GRAND TOTAL** | **179** | **100%** | |

---

## Visual Representation

```
┌──────────────────────────────────────────────────────┐
│           YOUR KUBERNETES CLUSTER                     │
│                                                        │
│  ┌──────────────────────────────────────────────┐   │
│  │  YOUR APPLICATIONS (4 pods)           2.2%    │   │
│  └──────────────────────────────────────────────┘   │
│                                                        │
│  ┌──────────────────────────────────────────────┐   │
│  │                                                │   │
│  │  DAEMONSET SYSTEM PODS (99 pods)      55.3%   │   │
│  │  (Required on every node)                     │   │
│  │                                                │   │
│  └──────────────────────────────────────────────┘   │
│                                                        │
│  ┌──────────────────────────────────────────────┐   │
│  │  MONITORING (30 pods)                 16.8%   │   │
│  └──────────────────────────────────────────────┘   │
│                                                        │
│  ┌──────────────────────────────────────────────┐   │
│  │  LOGGING (20 pods)                    11.2%   │   │
│  └──────────────────────────────────────────────┘   │
│                                                        │
│  ┌──────────────────────────────────────────────┐   │
│  │  KUBERNETES CORE (20 pods)            11.2%   │   │
│  └──────────────────────────────────────────────┘   │
│                                                        │
│  ┌──────────────────────────────────────────────┐   │
│  │  DEVOPS TOOLS (12 pods)                6.7%   │   │
│  └──────────────────────────────────────────────┘   │
│                                                        │
└──────────────────────────────────────────────────────┘
```

---

## Key Takeaways

### ✅ This is Normal!
A production Kubernetes cluster typically has **10-20x more infrastructure pods than application pods**. Your ratio of 4:175 (1:44) is expected for a well-monitored, production-grade cluster.

### ✅ Why So Many Infrastructure Pods?

1. **High Availability**: 3 zones × 3 nodes per zone = 9 nodes
2. **DaemonSets Scale with Nodes**: More nodes = more system pods
3. **Full Observability**: Complete monitoring and logging for production
4. **Enterprise Features**: ArgoCD, Jenkins, policy enforcement, security

### ✅ Benefits You Get:

| Infrastructure | What It Gives You |
|----------------|-------------------|
| DaemonSets (99 pods) | Networking, storage, and logging on every node |
| Monitoring (30 pods) | Real-time metrics, alerts, Grafana dashboards |
| Logging (20 pods) | Centralized log search and analysis (ELK) |
| ArgoCD (7 pods) | Automated GitOps deployments |
| Jenkins (1 pod) | CI/CD pipeline automation |
| Kyverno (4 pods) | Security policies and governance |
| DNS (2 pods) | Service discovery within cluster |
| Ingress (1 pod) | External access to your apps |

---

## Could You Reduce the Pod Count?

### Option 1: Reduce Nodes
- **Current**: 9 nodes = ~99 DaemonSet pods
- **If reduced to 3 nodes**: ~33 DaemonSet pods
- **Savings**: ~66 pods
- **Trade-off**: Less high availability, less capacity

### Option 2: Remove Monitoring/Logging
- **Remove ELK stack**: Save ~20 pods
- **Remove Prometheus**: Save ~30 pods
- **Trade-off**: No monitoring, no logs, blind to issues ❌

### Option 3: Remove DevOps Tools
- **Remove ArgoCD**: Save 7 pods
- **Remove Jenkins**: Save 1 pod
- **Remove Kyverno**: Save 4 pods
- **Trade-off**: Manual deployments, no policies ❌

### **Recommendation**: Keep current setup ✅
Your current configuration provides:
- Production-grade reliability
- Complete observability
- Automated deployments
- Security enforcement
- High availability across 3 zones

---

## Example: How a Request Flows Through Your Pods

```
User visits your banking app
         │
         ▼
1. nginx-ingress-controller (1 pod)
         │ ─── Routes traffic based on URL
         ▼
2. digitalbank-frontend (1 pod)
         │ ─── Serves React web app
         ▼
3. auth-api (1 pod)
         │ ─── Authenticates user
         ▼
4. accounts-api (1 pod)
         │ ─── Retrieves account data
         ▼
5. transactions-api (1 pod)
         │ ─── Processes payment
         ▼

Meanwhile, in the background:
- kube-proxy (9 pods) ─── Route network packets
- calico-node (9 pods) ─── Manage network policies
- filebeat (9 pods) ─── Collect logs from all pods
- prometheus (1 pod) ─── Scrape metrics every 15s
- node-exporter (9 pods) ─── Export node metrics
- elasticsearch (3 pods) ─── Store and index logs
- kibana (2 pods) ─── Provide log search UI
- argocd (7 pods) ─── Monitor Git repo for changes
- kyverno (4 pods) ─── Enforce security policies
```

---

## FAQs

### Q: Are we paying for all 179 pods?
**A**: You pay for the **9 nodes** (VMs), not individual pods. All 179 pods run on those 9 nodes using their CPU and memory.

### Q: Can we scale our 4 apps to more pods?
**A**: Yes! You can easily scale:
```bash
kubectl scale deployment auth-api -n digitalbank-apps --replicas=3
```
This would create 3 auth-api pods instead of 1.

### Q: What happens if a node fails?
**A**: Kubernetes automatically reschedules your 4 application pods to healthy nodes. DaemonSet pods are automatically recreated on replacement nodes.

### Q: Do we need Jenkins AND ArgoCD?
**A**: 
- **Jenkins**: Builds and tests your code (CI)
- **ArgoCD**: Deploys to Kubernetes (CD)
- They work together in your pipeline

### Q: What's using the most resources?
**A**: Check with:
```bash
kubectl top pods --all-namespaces
kubectl top nodes
```

---

## Conclusion

**You have 4 simple application pods running your banking services.**  
**The other 175 pods are the "operating system" of your Kubernetes cluster** – they provide networking, storage, monitoring, logging, security, and automation that makes modern cloud-native applications possible.

This is like asking why your computer runs 100+ processes when you only opened 4 programs – the operating system needs those background processes to make everything work!

---

**Document Version**: 1.0  
**Last Updated**: January 31, 2026  
**For Questions**: Review the [CLUSTER-INVENTORY.md](CLUSTER-INVENTORY.md) for detailed pod listings
