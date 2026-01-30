# ELK Stack (Elasticsearch, Logstash, Kibana) - Deployment Summary

## ✅ Successfully Deployed Components

### Architecture Overview
```
┌─────────────────────────────────────────────────────────┐
│              GKE Cluster (9 nodes)                      │
│                                                          │
│  ┌────────────────────────────────────────────────┐    │
│  │  Namespace: logging                             │    │
│  │                                                  │    │
│  │  ┌──────────────────────────────────┐          │    │
│  │  │  Elasticsearch Cluster (3 nodes) │          │    │
│  │  │  - elasticsearch-master-0        │          │    │
│  │  │  - elasticsearch-master-1        │          │    │
│  │  │  - elasticsearch-master-2        │          │    │
│  │  │  Storage: 30Gi per node (90Gi)   │          │    │
│  │  └──────────────────────────────────┘          │    │
│  │                  ▲                               │    │
│  │                  │                               │    │
│  │  ┌───────────────┴──────────────┐              │    │
│  │  │  Logstash (2 replicas)       │              │    │
│  │  │  - Log processing            │              │    │
│  │  │  - JSON parsing              │              │    │
│  │  │  - Kubernetes enrichment     │              │    │
│  │  └───────────────▲──────────────┘              │    │
│  │                  │                               │    │
│  │  ┌───────────────┴──────────────┐              │    │
│  │  │  Filebeat DaemonSet (9 pods) │              │    │
│  │  │  - Runs on every node        │              │    │
│  │  │  - Collects container logs   │              │    │
│  │  │  - Kubernetes metadata       │              │    │
│  │  └──────────────────────────────┘              │    │
│  │                                                  │    │
│  │  ┌──────────────────────────────────┐          │    │
│  │  │  Kibana (1 replica)              │          │    │
│  │  │  - Log visualization             │          │    │
│  │  │  - Dashboard & search            │          │    │
│  │  │  - Port: 5601                    │          │    │
│  │  └──────────────────────────────────┘          │    │
│  └────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────┘
```

## Deployed Resources

### 1. Elasticsearch Cluster
- **Pods**: 3 (StatefulSet)
- **Status**: ✅ All Running
- **Storage**: 30Gi per node (90Gi total)
- **Resources**: 
  - CPU: 500m-1000m per pod
  - Memory: 2Gi-4Gi per pod
- **Endpoints**:
  - http://elasticsearch-master:9200 (HTTP API)
  - http://elasticsearch-master:9300 (Transport)

### 2. Kibana Dashboard
- **Pods**: 1 (Deployment)
- **Status**: 🔄 Initializing (503 - not ready yet)
- **Resources**:
  - CPU: 200m-500m
  - Memory: 512Mi-1Gi
- **Service**: ClusterIP on port 5601
- **Access**: Will be available at http://kibana:5601

### 3. Logstash Processors
- **Pods**: 2 (Deployment)
- **Status**: 🔄 Initializing
- **Resources**:
  - CPU: 200m-500m per pod
  - Memory: 1Gi-2Gi per pod
- **Ports**:
  - 5044 (Beats input)
  - 9600 (Monitoring API)
- **Pipeline**: Configured to parse JSON, add K8s metadata, index to Elasticsearch

### 4. Filebeat Log Collectors
- **Pods**: 9 (DaemonSet - one per node)
- **Status**: ✅ All Running (9/9)
- **Resources**:
  - CPU: 100m-200m per pod
  - Memory: 128Mi-256Mi per pod
- **Collection**: 
  - All container logs from `/var/log/containers/`
  - Filtered to digitalbank namespaces
  - Automatic Kubernetes metadata enrichment

## Services
```bash
NAME                            TYPE        PORT(S)
elasticsearch-master            ClusterIP   9200/TCP, 9300/TCP
elasticsearch-master-headless   ClusterIP   9200/TCP, 9300/TCP
kibana                          ClusterIP   5601/TCP
logstash                        ClusterIP   5044/TCP, 9600/TCP
```

## Log Flow
```
Application Pods (digitalbank-apps)
         │
         │ Write logs to stdout/stderr
         ▼
    Container Runtime
         │
         │ Logs to /var/log/containers/*.log
         ▼
    Filebeat DaemonSet (on each node)
         │
         │ Parse, filter, add K8s metadata
         ▼
    Logstash (port 5044)
         │
         │ Process, parse JSON, enrich
         ▼
    Elasticsearch Cluster
         │
         │ Index: digitalbank-{namespace}-{date}
         ▼
    Kibana Dashboard
         │
         │ Visualize & search
         ▼
      End User
```

## Log Index Pattern
Logs are indexed with pattern: `digitalbank-{namespace}-{YYYY.MM.dd}`

Examples:
- `digitalbank-digitalbank-apps-2026.01.28`
- `digitalbank-digitalbank-monitoring-2026.01.28`
- `digitalbank-argocd-2026.01.28`
- `digitalbank-logging-2026.01.28`

## Configuration Highlights

### Filebeat Filtering
Only collects logs from:
- `digitalbank-apps` namespace
- `digitalbank-monitoring` namespace
- `argocd` namespace
- `logging` namespace

### Logstash Pipeline
- **Input**: Beats on port 5044
- **Filters**:
  - JSON parsing for structured logs
  - Kubernetes metadata enrichment
  - Log level extraction (INFO, WARN, ERROR, etc.)
- **Output**: Elasticsearch with daily indices

### Elasticsearch
- **Cluster Name**: elasticsearch
- **Minimum Master Nodes**: 2
- **Java Heap**: 2GB per node
- **Persistence**: Enabled (PVC per node)

## Access Instructions

### Port Forward to Kibana
```bash
kubectl port-forward -n logging svc/kibana 5601:5601
# Then open: http://localhost:5601
```

### Port Forward to Elasticsearch
```bash
kubectl port-forward -n logging svc/elasticsearch-master 9200:9200
# Test: curl http://localhost:9200
```

### Check Elasticsearch Health
```bash
kubectl exec -n logging elasticsearch-master-0 -- \
  curl -s http://localhost:9200/_cluster/health?pretty
```

### Check Indices
```bash
kubectl exec -n logging elasticsearch-master-0 -- \
  curl -s http://localhost:9200/_cat/indices?v
```

## Verification Commands

### Check All ELK Pods
```bash
kubectl get pods -n logging
```

### Check Filebeat Logs
```bash
kubectl logs -n logging daemonset/filebeat --tail=50
```

### Check Logstash Pipeline
```bash
kubectl logs -n logging deployment/logstash --tail=50
```

### Check Kibana Status
```bash
kubectl exec -n logging deployment/kibana -- \
  curl -s http://localhost:5601/api/status
```

## Current Status

| Component      | Pods    | Status         | Ready |
|---------------|---------|----------------|-------|
| Elasticsearch | 3/3     | ✅ Running     | Yes   |
| Kibana        | 1/1     | 🔄 Starting    | No    |
| Logstash      | 2/2     | 🔄 Starting    | No    |
| Filebeat      | 9/9     | ✅ Running     | Yes   |

**Note**: Kibana and Logstash typically take 2-5 minutes to fully initialize and become ready. They need to:
1. Connect to Elasticsearch
2. Create system indices
3. Initialize plugins
4. Complete health checks

## Next Steps

1. **Wait for Readiness** (2-5 minutes)
   ```bash
   kubectl get pods -n logging -w
   ```

2. **Access Kibana Dashboard**
   ```bash
   kubectl port-forward -n logging svc/kibana 5601:5601
   ```

3. **Configure Index Pattern in Kibana**
   - Navigate to Stack Management → Index Patterns
   - Create pattern: `digitalbank-*`
   - Select `@timestamp` as time field

4. **View Logs**
   - Go to Discover in Kibana
   - Select the `digitalbank-*` index pattern
   - Filter by namespace, pod, container, etc.

5. **Create Dashboards**
   - Error rate by service
   - Request volume
   - Response times
   - Pod resource usage

## Troubleshooting

### Kibana Won't Start
```bash
# Check logs
kubectl logs -n logging deployment/kibana

# Check Elasticsearch connectivity
kubectl exec -n logging deployment/kibana -- \
  curl -s http://elasticsearch-master:9200
```

### No Logs Appearing
```bash
# Check Filebeat is collecting
kubectl logs -n logging daemonset/filebeat | grep "publish"

# Check Logstash is receiving
kubectl logs -n logging deployment/logstash | grep "beats"

# Check Elasticsearch indices
kubectl exec -n logging elasticsearch-master-0 -- \
  curl -s http://localhost:9200/_cat/indices
```

### High Resource Usage
```bash
# Check resource usage
kubectl top pods -n logging

# Reduce replicas if needed
kubectl scale deployment logstash -n logging --replicas=1
```

## Resource Requirements Summary

| Component      | CPU (request/limit) | Memory (request/limit) | Storage |
|---------------|---------------------|------------------------|---------|
| Elasticsearch | 500m / 1000m × 3    | 2Gi / 4Gi × 3         | 90Gi    |
| Kibana        | 200m / 500m         | 512Mi / 1Gi           | -       |
| Logstash      | 200m / 500m × 2     | 1Gi / 2Gi × 2         | -       |
| Filebeat      | 100m / 200m × 9     | 128Mi / 256Mi × 9     | -       |
| **Total**     | **~3.6 vCPU**       | **~17 GB**            | **90GB**|

---

**Deployment Date**: January 28, 2026  
**Namespace**: logging  
**Status**: ✅ Deployed, 🔄 Initializing  
**Components**: Elasticsearch (3), Kibana (1), Logstash (2), Filebeat (9)
