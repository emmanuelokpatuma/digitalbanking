#!/bin/bash
# Digital Banking Platform - Access All Dashboards
# This script sets up port-forwarding for all monitoring and management tools

echo "🚀 Starting port-forwarding for all dashboards..."
echo "Press Ctrl+C to stop all port-forwards"
echo ""

# Function to start port-forward in background
start_forward() {
    local name=$1
    local namespace=$2
    local service=$3
    local local_port=$4
    local remote_port=$5
    
    echo "✅ Starting $name on http://localhost:$local_port"
    kubectl port-forward -n $namespace svc/$service $local_port:$remote_port > /dev/null 2>&1 &
}

# Start all port-forwards
start_forward "Kibana" "logging" "kibana" "5601" "5601"
start_forward "ArgoCD" "argocd" "argocd-server" "8080" "443"
start_forward "Prometheus" "digitalbank-monitoring" "prometheus-kube-prometheus-prometheus" "9090" "9090"
start_forward "Grafana" "digitalbank-monitoring" "prometheus-grafana" "3000" "80"

sleep 2
echo ""
echo "════════════════════════════════════════════════════════════"
echo "  🎉 All Dashboards Ready! Access URLs:"
echo "════════════════════════════════════════════════════════════"
echo ""
echo "📊 Kibana (Logs & Search)"
echo "   URL: http://localhost:5601"
echo "   Status: Initializing (may take 2-5 min on first access)"
echo ""
echo "🔄 ArgoCD (GitOps)"
echo "   URL: https://localhost:8080"
echo "   Username: admin"
echo "   Password: PJm6W1MKJDOEv9en"
echo "   Note: Accept self-signed certificate warning"
echo ""
echo "📈 Prometheus (Metrics)"
echo "   URL: http://localhost:9090"
echo "   Status: Query metrics and alerts"
echo ""
echo "📉 Grafana (Dashboards)"
echo "   URL: http://localhost:3000"
echo "   Username: admin"
echo "   Password: admin123"
echo ""
echo "════════════════════════════════════════════════════════════"
echo ""
echo "⚡ Quick Setup Tips:"
echo "   • Kibana: Create index pattern 'digitalbank-*' in Stack Management"
echo "   • ArgoCD: Connect your Git repo to enable GitOps"
echo "   • Grafana: Kubernetes dashboards are pre-loaded"
echo ""
echo "Press Ctrl+C to stop all port-forwards and exit"
echo "════════════════════════════════════════════════════════════"

# Wait for Ctrl+C
wait