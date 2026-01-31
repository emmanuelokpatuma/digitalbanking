# How to View Metrics in Grafana and Prometheus

**Date**: January 31, 2026  
**Cluster**: digitalbank-gke

---

## Quick Start - Access Credentials

### Grafana
- **URL**: http://136.111.5.250
- **Username**: `admin`
- **Password**: `admin123`

### Prometheus
- **URL**: http://34.71.18.248:9090
- **No authentication required** (open access)

---

## Part 1: Viewing Metrics in Grafana

### Step 1: Login to Grafana

1. Open your browser and go to: **http://136.111.5.250**

2. Login with:
   - Username: `admin`
   - Password: `admin123`

3. You'll see the Grafana home page

---

### Step 2: Explore Pre-built Dashboards

Grafana comes with pre-configured dashboards. Here's how to find them:

#### Method 1: Browse Dashboards
1. Click on **☰** (hamburger menu) in the top left
2. Click **"Dashboards"**
3. You'll see a list of available dashboards

#### Common Dashboards You'll See:

| Dashboard Name | What It Shows |
|----------------|---------------|
| **Kubernetes / Compute Resources / Cluster** | Overall cluster CPU, memory, network usage |
| **Kubernetes / Compute Resources / Namespace (Pods)** | Resource usage per namespace |
| **Kubernetes / Compute Resources / Node (Pods)** | Resource usage per node |
| **Kubernetes / Networking / Cluster** | Network I/O, packet rates |
| **Kubernetes / Persistent Volumes** | Storage usage |
| **Node Exporter / Nodes** | Detailed node metrics (CPU, memory, disk, network) |
| **Prometheus / Overview** | Prometheus server health |

---

### Step 3: View Your Application Metrics

#### View Namespace Metrics (Your Banking Apps)

1. Go to **Dashboards** → **Kubernetes / Compute Resources / Namespace (Pods)**

2. At the top, select:
   - **datasource**: `Prometheus`
   - **namespace**: `digitalbank-apps`

3. You'll see:
   - CPU usage for each pod (auth-api, accounts-api, transactions-api, frontend)
   - Memory usage per pod
   - Network I/O
   - Pod count

#### View Node Metrics

1. Go to **Dashboards** → **Node Exporter / Nodes**

2. Select a specific node from the dropdown

3. You'll see:
   - CPU usage (all cores)
   - Memory usage
   - Disk I/O
   - Network traffic
   - System load

---

### Step 4: Create Custom Queries

1. Click **"Explore"** in the left menu (compass icon 🧭)

2. Select **datasource**: `Prometheus`

3. In the **Metrics browser**, you can:
   - Click **"Metrics explorer"** to browse all available metrics
   - Type a query directly

#### Example Queries for Your Banking App:

```promql
# CPU usage for auth-api
rate(container_cpu_usage_seconds_total{namespace="digitalbank-apps", pod=~"auth-api.*"}[5m])

# Memory usage for accounts-api
container_memory_working_set_bytes{namespace="digitalbank-apps", pod=~"accounts-api.*"}

# Network receive rate for transactions-api
rate(container_network_receive_bytes_total{namespace="digitalbank-apps", pod=~"transactions-api.*"}[5m])

# HTTP request rate (if your app exports this metric)
rate(http_requests_total{namespace="digitalbank-apps"}[5m])

# Pod restart count
kube_pod_container_status_restarts_total{namespace="digitalbank-apps"}
```

4. Click **"Run query"** to see the results

5. Toggle between **Table**, **Graph**, or **Logs** view

---

### Step 5: Create Your Own Dashboard

1. Click **"+"** → **"Dashboard"** → **"Add new panel"**

2. In the query editor, enter a PromQL query:
   ```promql
   rate(container_cpu_usage_seconds_total{namespace="digitalbank-apps"}[5m])
   ```

3. Customize the visualization:
   - **Panel title**: "Digital Banking CPU Usage"
   - **Visualization type**: Time series, Gauge, Stat, etc.
   - **Legend**: Show pod names

4. Click **"Apply"** to add the panel

5. Click **"Save dashboard"** (💾 icon top right)

6. Name it: "Digital Banking Monitoring"

---

## Part 2: Viewing Metrics in Prometheus

### Step 1: Access Prometheus UI

1. Open your browser and go to: **http://34.71.18.248:9090**

2. You'll see the Prometheus web interface (no login required)

---

### Step 2: Explore Available Metrics

#### Method 1: Metrics Explorer
1. Click the **🌐 globe icon** next to the query box
2. Browse through all available metrics
3. Click any metric to insert it into the query

#### Method 2: Type and Autocomplete
1. Start typing in the query box
2. Prometheus will show autocomplete suggestions
3. Use arrow keys to select a metric

---

### Step 3: Common Metrics Categories

| Metric Prefix | What It Measures | Example |
|---------------|------------------|---------|
| `container_*` | Container/Pod metrics | `container_cpu_usage_seconds_total` |
| `kube_*` | Kubernetes object state | `kube_pod_status_phase` |
| `node_*` | Node-level metrics | `node_cpu_seconds_total` |
| `up` | Target scrape status | `up{job="kubernetes-pods"}` |
| `prometheus_*` | Prometheus internals | `prometheus_target_interval_length_seconds` |

---

### Step 4: Query Your Banking Application

#### Example 1: See All Pods in digitalbank-apps
```promql
up{namespace="digitalbank-apps"}
```
Result: Shows which pods are up (1) or down (0)

---

#### Example 2: CPU Usage by Pod
```promql
rate(container_cpu_usage_seconds_total{namespace="digitalbank-apps"}[5m])
```
- **Graph** tab: Shows CPU over time
- **Table** tab: Shows current values

---

#### Example 3: Memory Usage by Pod
```promql
container_memory_working_set_bytes{namespace="digitalbank-apps"} / 1024 / 1024
```
Result: Memory in MB for each pod

---

#### Example 4: Pod Restart Count
```promql
kube_pod_container_status_restarts_total{namespace="digitalbank-apps"}
```
Result: How many times each pod has restarted

---

#### Example 5: Network Traffic
```promql
rate(container_network_receive_bytes_total{namespace="digitalbank-apps"}[5m])
```
Result: Incoming network bytes per second

---

### Step 5: Advanced Queries

#### CPU Usage Percentage (0-100%)
```promql
sum(rate(container_cpu_usage_seconds_total{namespace="digitalbank-apps"}[5m])) by (pod) * 100
```

#### Top 5 Pods by Memory
```promql
topk(5, container_memory_working_set_bytes{namespace="digitalbank-apps"})
```

#### Total Requests Per Second (if app exports http_requests_total)
```promql
sum(rate(http_requests_total{namespace="digitalbank-apps"}[5m]))
```

#### Alert if Pod is Down
```promql
up{namespace="digitalbank-apps"} == 0
```

---

### Step 6: Visualize Data

1. **Graph Tab**: 
   - Shows time series over the selected time range
   - Adjust time range with the dropdown (Last 1h, 3h, 6h, 12h, 1d)
   - Hover over lines to see exact values

2. **Table Tab**: 
   - Shows current values in a table
   - Easier to compare multiple metrics

3. **Options**:
   - Click **"Add Query"** to add multiple metrics to one graph
   - Use **"- / +"** to zoom in/out on the graph
   - Click and drag to zoom into a specific time range

---

### Step 7: Check Prometheus Targets

See what Prometheus is monitoring:

1. Click **"Status"** → **"Targets"**

2. You'll see all monitored endpoints:
   - ✅ Green: Successfully scraped
   - ❌ Red: Scraping failed
   
3. Look for your apps under:
   - `kubernetes-pods` (auto-discovered pods)
   - `kubernetes-nodes` (node metrics)
   - `kubernetes-service-endpoints` (services)

---

## Part 3: Useful Metrics for Your Banking Platform

### Infrastructure Metrics

#### Cluster-Level
```promql
# Total nodes
count(kube_node_info)

# Total pods running
count(kube_pod_info)

# Pods by namespace
count(kube_pod_info) by (namespace)
```

#### Node Health
```promql
# Node CPU usage %
100 - (avg by (instance) (rate(node_cpu_seconds_total{mode="idle"}[5m])) * 100)

# Node memory available
node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes * 100

# Node disk usage %
100 - (node_filesystem_avail_bytes / node_filesystem_size_bytes * 100)
```

---

### Application Metrics

#### Your Banking Services
```promql
# Auth API CPU
rate(container_cpu_usage_seconds_total{namespace="digitalbank-apps", pod=~"auth-api.*"}[5m])

# Accounts API Memory (MB)
container_memory_working_set_bytes{namespace="digitalbank-apps", pod=~"accounts-api.*"} / 1024 / 1024

# Transactions API Network In (bytes/sec)
rate(container_network_receive_bytes_total{namespace="digitalbank-apps", pod=~"transactions-api.*"}[5m])

# Frontend Network Out (bytes/sec)
rate(container_network_transmit_bytes_total{namespace="digitalbank-apps", pod=~"digitalbank-frontend.*"}[5m])
```

#### Pod Status
```promql
# Pod status (1=Running, 0=Not Running)
kube_pod_status_phase{namespace="digitalbank-apps", phase="Running"}

# Pods not ready
kube_pod_status_ready{namespace="digitalbank-apps", condition="false"}

# Container restarts
kube_pod_container_status_restarts_total{namespace="digitalbank-apps"}
```

---

### Resource Usage by Namespace

```promql
# CPU usage per namespace
sum(rate(container_cpu_usage_seconds_total[5m])) by (namespace)

# Memory usage per namespace (GB)
sum(container_memory_working_set_bytes) by (namespace) / 1024 / 1024 / 1024

# Network traffic per namespace (MB/s)
sum(rate(container_network_transmit_bytes_total[5m])) by (namespace) / 1024 / 1024
```

---

### DevOps Infrastructure

```promql
# Jenkins pod status
up{namespace="jenkins"}

# ArgoCD pods status
kube_pod_status_phase{namespace="argocd", phase="Running"}

# Elasticsearch nodes
up{namespace="logging", job="elasticsearch"}

# Prometheus storage size
prometheus_tsdb_storage_blocks_bytes / 1024 / 1024 / 1024
```

---

## Part 4: Set Up Alerts (Optional)

### In Grafana:

1. Edit any dashboard panel
2. Click **"Alert"** tab
3. Click **"Create Alert Rule from this panel"**
4. Set conditions:
   - **When**: avg() of query
   - **Is Above**: 80 (for CPU %)
   - **For**: 5m (duration)
5. Add notification channel (email, Slack, etc.)
6. Save

### In Prometheus:

Prometheus alerts are configured via YAML files. Example alert:

```yaml
groups:
- name: banking_alerts
  rules:
  - alert: HighCPU
    expr: rate(container_cpu_usage_seconds_total{namespace="digitalbank-apps"}[5m]) > 0.8
    for: 5m
    labels:
      severity: warning
    annotations:
      summary: "High CPU usage on {{ $labels.pod }}"
```

---

## Part 5: Quick Reference Cheat Sheet

### Grafana Quick Actions

| Action | Steps |
|--------|-------|
| **View dashboards** | ☰ Menu → Dashboards |
| **Explore metrics** | 🧭 Explore → Select Prometheus |
| **Create dashboard** | + → Dashboard → Add panel |
| **Import dashboard** | + → Import → Enter dashboard ID |
| **Change time range** | Top right corner clock icon |
| **Refresh data** | Top right refresh icon |
| **Share dashboard** | Share icon → Link or Snapshot |

### Prometheus Quick Actions

| Action | URL / Tab |
|--------|-----------|
| **Query metrics** | Main page (Graph / Table) |
| **See all targets** | Status → Targets |
| **See configuration** | Status → Configuration |
| **Runtime info** | Status → Runtime & Build Information |
| **TSDB status** | Status → TSDB Status |
| **See rules** | Status → Rules |

---

## Common PromQL Functions

| Function | Purpose | Example |
|----------|---------|---------|
| `rate()` | Per-second rate over time | `rate(http_requests_total[5m])` |
| `sum()` | Add values together | `sum(container_cpu_usage) by (pod)` |
| `avg()` | Average values | `avg(node_memory_usage)` |
| `max()` | Maximum value | `max(container_memory_bytes)` |
| `min()` | Minimum value | `min(node_disk_free)` |
| `topk()` | Top K values | `topk(5, memory_usage)` |
| `count()` | Count items | `count(up == 1)` |

---

## Troubleshooting

### Grafana shows "No data"
1. Check datasource connection: Configuration → Data Sources → Prometheus
2. Verify Prometheus URL: `http://prometheus-kube-prometheus-prometheus.digitalbank-monitoring:9090`
3. Test connection (should show green checkmark)

### Prometheus shows no targets
```bash
kubectl get servicemonitor -n digitalbank-monitoring
kubectl get podmonitor -n digitalbank-monitoring
```

### Metrics not appearing
1. Check if pods have metrics endpoint:
```bash
kubectl get pods -n digitalbank-apps -o wide
kubectl port-forward -n digitalbank-apps <pod-name> 9090:9090
curl localhost:9090/metrics
```

2. Add annotations to your deployment for auto-discovery:
```yaml
annotations:
  prometheus.io/scrape: "true"
  prometheus.io/port: "3000"
  prometheus.io/path: "/metrics"
```

---

## Next Steps

### 1. Import Community Dashboards
Grafana has 1000s of pre-built dashboards:

1. Go to: https://grafana.com/grafana/dashboards/
2. Search for "Kubernetes" or "Node Exporter"
3. Copy the dashboard ID (e.g., 315, 1860, 7249)
4. In Grafana: + → Import → Paste ID → Load

**Recommended Dashboard IDs**:
- **315**: Kubernetes cluster monitoring
- **1860**: Node Exporter Full
- **7249**: Kubernetes Cluster
- **6417**: Kubernetes Pods
- **8588**: Kubernetes Deployment Stats

### 2. Export Application Metrics
Add metrics to your Node.js apps:

```javascript
// Install: npm install prom-client
const client = require('prom-client');

// Collect default metrics
const collectDefaultMetrics = client.collectDefaultMetrics;
collectDefaultMetrics({ timeout: 5000 });

// Custom counter
const httpRequestsTotal = new client.Counter({
  name: 'http_requests_total',
  help: 'Total HTTP requests',
  labelNames: ['method', 'route', 'status']
});

// Expose /metrics endpoint
app.get('/metrics', async (req, res) => {
  res.set('Content-Type', client.register.contentType);
  res.end(await client.register.metrics());
});
```

### 3. Set Up Alertmanager
Configure email/Slack alerts for critical issues.

---

## Summary

### Grafana (Visualization)
- **URL**: http://136.111.5.250
- **User**: admin / admin123
- **Best for**: Beautiful dashboards, long-term analysis, sharing reports

### Prometheus (Raw Data)
- **URL**: http://34.71.18.248:9090
- **No auth required**
- **Best for**: Quick queries, debugging, testing PromQL

**Both tools query the same data** - Prometheus stores it, Grafana visualizes it beautifully!

---

**Last Updated**: January 31, 2026  
**For questions**: See [SERVICE-ACCESS-URLS.md](SERVICE-ACCESS-URLS.md) for all access info
