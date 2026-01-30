# 🖥️ New System Setup Guide - Connect to Existing GCP Infrastructure

## Overview

This guide will help you connect to your existing Digital Banking infrastructure from a new Windows machine. Use this guide when:
- Setting up a new development machine
- Your previous system crashed and you need to reconnect
- A team member needs access to the infrastructure

**What you'll install:**
1. Google Cloud SDK (gcloud CLI)
2. kubectl (Kubernetes command-line tool)
3. Terraform (Infrastructure as Code tool)
4. Python (required by gcloud)
5. Git (version control)

**What you'll connect to:**
- GCP Project: `charged-thought-485008-q7`
- GKE Cluster: `digitalbank-gke`
- Region: `us-central1`
- Nodes: 9 Kubernetes nodes running

---

## Prerequisites

- Windows 10/11
- Administrator access
- Internet connection
- Google Account with access to GCP project

---

## Step 1: Install Python (Required for Google Cloud SDK)

### Why Python?
Google Cloud SDK is built with Python and requires it to run.

### Installation Steps:

1. **Using winget (Windows Package Manager)**:
```powershell
# Open PowerShell as Administrator
winget install Python.Python.3.12
```

2. **Verify Installation**:
```powershell
python --version
# Should show: Python 3.12.x
```

3. **If winget is not available**, download from:
   - https://www.python.org/downloads/
   - During installation, check "Add Python to PATH"

---

## Step 2: Install Google Cloud SDK

### What is gcloud?
The Google Cloud SDK (`gcloud`) is the command-line tool for interacting with Google Cloud Platform services.

### Installation Steps:

1. **Download the installer**:
   - Visit: https://cloud.google.com/sdk/docs/install
   - Or use PowerShell:
```powershell
Invoke-WebRequest -Uri "https://dl.google.com/dl/cloudsdk/channels/rapid/GoogleCloudSDKInstaller.exe" -OutFile "$env:USERPROFILE\Downloads\GoogleCloudSDKInstaller.exe"
```

2. **Run the installer**:
```powershell
& "$env:USERPROFILE\Downloads\GoogleCloudSDKInstaller.exe"
```

3. **During installation**:
   - Accept defaults
   - Check "Start Cloud SDK Shell when finished"
   - **Important**: Set Python path when prompted:
     - Set `CLOUDSDK_PYTHON` to your Python installation
     - Example: `C:\Users\YourName\AppData\Local\Programs\Python\Python312\python.exe`

4. **Complete installation**:
   - The installer will download required components
   - This may take 5-10 minutes

5. **Refresh your PowerShell**:
```powershell
# Close and reopen PowerShell, OR run:
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
```

6. **Verify Installation**:
```powershell
gcloud version
# Should show: Google Cloud SDK xxx.x.x
```

---

## Step 3: Authenticate with Google Cloud

### Why Authenticate?
You need to prove you have access to the GCP project before you can manage resources.

### Steps:

1. **Login to Google Cloud**:
```powershell
gcloud auth login
```
   - Browser window opens
   - Sign in with your Google account
   - Grant permissions
   - Return to terminal

2. **Set up Application Default Credentials** (for Terraform):
```powershell
gcloud auth application-default login
```
   - Browser window opens again
   - Sign in and grant permissions
   - These credentials are stored at: `%APPDATA%\gcloud\legacy_credentials\`

3. **Set your project**:
```powershell
gcloud config set project charged-thought-485008-q7
```

4. **Verify project access**:
```powershell
gcloud projects describe charged-thought-485008-q7
```

---

## Step 4: Install kubectl (Kubernetes CLI)

### What is kubectl?
`kubectl` is the command-line tool for interacting with Kubernetes clusters.

### Installation Steps:

1. **Install via gcloud** (easiest method):
```powershell
gcloud components install kubectl
```

2. **Or install via gcloud plugins**:
```powershell
gcloud components install gke-gcloud-auth-plugin
```

3. **Verify Installation**:
```powershell
kubectl version --client
```

---

## Step 5: Connect to Your GKE Cluster

### Get Cluster Credentials:

```powershell
# Connect to the cluster
gcloud container clusters get-credentials digitalbank-gke --region us-central1 --project charged-thought-485008-q7
```

**What this does:**
- Downloads cluster certificates
- Updates your `~/.kube/config` file
- Sets the current context to your cluster

### Verify Connection:

```powershell
# Set environment variable for auth plugin
$env:USE_GKE_GCLOUD_AUTH_PLUGIN = "True"

# Get list of nodes
kubectl get nodes
```

**Expected Output:**
```
NAME                                                  STATUS   ROLES    AGE   VERSION
gke-digitalbank-gke-digitalbank-gke-n-17ab08f8-698s   Ready    <none>   2d    v1.33.5-gke.2100000
gke-digitalbank-gke-digitalbank-gke-n-17ab08f8-cz5j   Ready    <none>   2d    v1.33.5-gke.2100000
gke-digitalbank-gke-digitalbank-gke-n-17ab08f8-fjkp   Ready    <none>   2d    v1.33.5-gke.2100000
gke-digitalbank-gke-digitalbank-gke-n-21d17511-0h9m   Ready    <none>   2d    v1.33.5-gke.2100000
gke-digitalbank-gke-digitalbank-gke-n-21d17511-7ppr   Ready    <none>   2d    v1.33.5-gke.2100000
gke-digitalbank-gke-digitalbank-gke-n-21d17511-c687   Ready    <none>   2d    v1.33.5-gke.2100000
gke-digitalbank-gke-digitalbank-gke-n-e353b711-17l7   Ready    <none>   2d    v1.33.5-gke.2100000
gke-digitalbank-gke-digitalbank-gke-n-e353b711-63x8   Ready    <none>   2d    v1.33.5-gke.2100000
gke-digitalbank-gke-digitalbank-gke-n-e353b711-j2bx   Ready    <none>   2d    v1.33.5-gke.2100000
```

You should see **9 nodes** all in "Ready" status.

### Test kubectl Commands:

```powershell
# Get all pods
kubectl get pods --all-namespaces

# Get deployments
kubectl get deployments -n digitalbank-apps

# Get services
kubectl get services -n digitalbank-apps
```

---

## Step 6: Install Terraform

### What is Terraform?
Terraform is the Infrastructure as Code (IaC) tool we use to manage the GCP infrastructure.

### Installation Steps:

1. **Install via winget**:
```powershell
winget install HashiCorp.Terraform
```

2. **Refresh PATH**:
```powershell
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
```

3. **Verify Installation**:
```powershell
terraform --version
# Should show: Terraform v1.14.x
```

---

## Step 7: Clone and Setup Your Repository

### Clone the Repository:

```powershell
# Navigate to your workspace
cd C:\Users\$env:USERNAME\Desktop

# Clone the repository
git clone https://github.com/emmanuelokpatuma/digitalbanking.git
cd digitalbanking
```

### Initialize Terraform:

```powershell
# Navigate to terraform directory
cd terraform

# Set credentials environment variable
$env:GOOGLE_APPLICATION_CREDENTIALS = "$env:APPDATA\gcloud\legacy_credentials\your-email@gmail.com\adc.json"

# Initialize Terraform
terraform init
```

**Expected Output:**
```
Initializing the backend...
Initializing provider plugins...
- Reusing previous version of hashicorp/google
- Reusing previous version of hashicorp/kubernetes
- Installing providers...

Terraform has been successfully initialized!
```

### Verify Terraform State:

```powershell
# Check infrastructure state
terraform state list
```

**You should see ~35 resources** including:
- google_container_cluster.primary
- google_container_node_pool.primary_nodes
- google_sql_database_instance.auth_db
- google_sql_database_instance.accounts_db
- google_sql_database_instance.transactions_db
- And more...

### Check Current vs Desired State:

```powershell
terraform plan
```

**Expected Output:**
```
No changes. Your infrastructure matches the configuration.

Terraform has compared your real infrastructure against your configuration 
and found no differences, so no changes are needed.
```

If you see this, your local Terraform configuration perfectly matches what's running in GCP! ✅

---

## Step 8: Verify Access to All Services

### Check Nodes:

```powershell
kubectl get nodes
```
**Expected: 9 nodes in Ready status**

### Check Pods:

```powershell
kubectl get pods -n digitalbank-apps
```
**Expected: auth-api, accounts-api, transactions-api, frontend pods running**

### Check Databases:

```powershell
# List Cloud SQL instances
gcloud sql instances list --project charged-thought-485008-q7
```
**Expected: 3 databases (auth, accounts, transactions)**

### Check Services:

```powershell
kubectl get services -n digitalbank-apps
```

### Test API Endpoints:

```powershell
# Test frontend
curl http://34.31.22.16

# Test auth API
curl http://34.31.22.16/api/auth/health
```

---

## Step 9: Set Up Persistent Environment Variables (Optional)

To avoid setting environment variables every time you open PowerShell:

### Create PowerShell Profile:

```powershell
# Check if profile exists
Test-Path $PROFILE

# If false, create it
New-Item -ItemType File -Path $PROFILE -Force

# Edit profile
notepad $PROFILE
```

### Add to Profile:

```powershell
# Digital Banking Environment Variables
$env:USE_GKE_GCLOUD_AUTH_PLUGIN = "True"
$env:GOOGLE_APPLICATION_CREDENTIALS = "$env:APPDATA\gcloud\legacy_credentials\your-email@gmail.com\adc.json"
$env:CLOUDSDK_PYTHON = "C:\Users\$env:USERNAME\AppData\Local\Programs\Python\Python312\python.exe"

# Add gcloud to PATH if not already there
$env:Path += ";$env:LOCALAPPDATA\Google\Cloud SDK\google-cloud-sdk\bin"

# Helpful aliases
Set-Alias k kubectl
Set-Alias tf terraform

Write-Host "Digital Banking environment loaded! ✅" -ForegroundColor Green
Write-Host "Cluster: digitalbank-gke" -ForegroundColor Cyan
Write-Host "Project: charged-thought-485008-q7" -ForegroundColor Cyan
```

Save and close. Next time you open PowerShell, these will be set automatically!

---

## Step 10: Verify Complete Setup

### Run the Complete Verification Script:

```powershell
# Save this as verify-setup.ps1

Write-Host "`n=== Digital Banking Setup Verification ===" -ForegroundColor Green

# Check Python
Write-Host "`n1. Checking Python..." -ForegroundColor Yellow
python --version

# Check gcloud
Write-Host "`n2. Checking gcloud..." -ForegroundColor Yellow
gcloud version | Select-String "Google Cloud SDK"

# Check current project
Write-Host "`n3. Checking GCP Project..." -ForegroundColor Yellow
gcloud config get-value project

# Check kubectl
Write-Host "`n4. Checking kubectl..." -ForegroundColor Yellow
kubectl version --client --short

# Check Terraform
Write-Host "`n5. Checking Terraform..." -ForegroundColor Yellow
terraform version | Select-String "Terraform v"

# Check cluster connection
Write-Host "`n6. Checking GKE Connection..." -ForegroundColor Yellow
$env:USE_GKE_GCLOUD_AUTH_PLUGIN = "True"
$nodeCount = (kubectl get nodes --no-headers 2>$null | Measure-Object).Count
if ($nodeCount -eq 9) {
    Write-Host "✅ Connected to cluster! $nodeCount nodes running." -ForegroundColor Green
} else {
    Write-Host "❌ Issue with cluster connection. Found $nodeCount nodes (expected 9)." -ForegroundColor Red
}

# Check Terraform state
Write-Host "`n7. Checking Terraform State..." -ForegroundColor Yellow
cd terraform
$resourceCount = (terraform state list 2>$null | Measure-Object).Count
if ($resourceCount -gt 30) {
    Write-Host "✅ Terraform state loaded! $resourceCount resources." -ForegroundColor Green
} else {
    Write-Host "❌ Terraform state issue. Found $resourceCount resources." -ForegroundColor Red
}

Write-Host "`n=== Setup Verification Complete ===" -ForegroundColor Green
```

### Run it:

```powershell
.\verify-setup.ps1
```

---

## Common Issues & Solutions

### Issue 1: "gcloud: command not found"

**Solution:**
```powershell
# Refresh PATH
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

# Or manually add gcloud to PATH
$env:Path += ";$env:LOCALAPPDATA\Google\Cloud SDK\google-cloud-sdk\bin"
```

### Issue 2: "Python not found" error from gcloud

**Solution:**
```powershell
# Set Python path
$env:CLOUDSDK_PYTHON = "C:\Users\$env:USERNAME\AppData\Local\Programs\Python\Python312\python.exe"

# Or reinstall Cloud SDK with:
& "C:\Users\$env:USERNAME\AppData\Local\Google\Cloud SDK\google-cloud-sdk\install.bat"
```

### Issue 3: kubectl can't connect to cluster

**Solution:**
```powershell
# Reconnect to cluster
gcloud container clusters get-credentials digitalbank-gke --region us-central1 --project charged-thought-485008-q7

# Set auth plugin
$env:USE_GKE_GCLOUD_AUTH_PLUGIN = "True"

# Test connection
kubectl get nodes
```

### Issue 4: Terraform "backend initialization failed"

**Solution:**
```powershell
# Set credentials
$env:GOOGLE_APPLICATION_CREDENTIALS = "$env:APPDATA\gcloud\legacy_credentials\your-email@gmail.com\adc.json"

# Re-initialize
cd terraform
terraform init -reconfigure
```

### Issue 5: "Unable to connect to the server: dial tcp [::1]:8080"

**This means kubectl is not configured properly.**

**Solution:**
```powershell
# Delete existing config
Remove-Item "$env:USERPROFILE\.kube\config" -ErrorAction SilentlyContinue

# Recreate .kube directory
New-Item -ItemType Directory -Force -Path "$env:USERPROFILE\.kube"

# Get credentials again
gcloud container clusters get-credentials digitalbank-gke --region us-central1 --project charged-thought-485008-q7

# Test
$env:USE_GKE_GCLOUD_AUTH_PLUGIN = "True"
kubectl get nodes
```

---

## Quick Reference - Common Commands

### Kubernetes (kubectl):

```powershell
# Get nodes
kubectl get nodes

# Get all pods
kubectl get pods --all-namespaces

# Get application pods
kubectl get pods -n digitalbank-apps

# Get pod details
kubectl describe pod <pod-name> -n digitalbank-apps

# View logs
kubectl logs <pod-name> -n digitalbank-apps -f

# Scale deployment
kubectl scale deployment auth-api --replicas=2 -n digitalbank-apps

# Restart deployment
kubectl rollout restart deployment/auth-api -n digitalbank-apps
```

### Google Cloud (gcloud):

```powershell
# List clusters
gcloud container clusters list --project charged-thought-485008-q7

# List databases
gcloud sql instances list --project charged-thought-485008-q7

# List compute instances
gcloud compute instances list --project charged-thought-485008-q7

# Get cluster info
gcloud container clusters describe digitalbank-gke --region us-central1

# SSH to a node (if needed)
gcloud compute ssh <node-name> --zone us-central1-a
```

### Terraform:

```powershell
# Navigate to terraform directory
cd terraform

# View current state
terraform state list

# Show specific resource
terraform state show google_container_cluster.primary

# Check what would change
terraform plan

# Apply changes
terraform apply

# View outputs
terraform output
```

---

## Next Steps

Now that you're connected, you can:

1. **Monitor your infrastructure:**
   - Grafana: http://136.111.5.250
   - Prometheus: http://34.71.18.248:9090
   - Kibana: http://34.44.185.11:5601

2. **Deploy changes:**
   - Edit code in your repository
   - Push to GitHub
   - Jenkins builds automatically
   - ArgoCD deploys automatically

3. **Manage infrastructure:**
   - Update Terraform files
   - Run `terraform plan` to preview
   - Run `terraform apply` to deploy

4. **Check application:**
   - Frontend: http://34.31.22.16
   - APIs: http://34.31.22.16/api/*

---

## Summary - What You Installed

✅ **Python 3.12** - Required by gcloud  
✅ **Google Cloud SDK** - Interact with GCP  
✅ **kubectl** - Manage Kubernetes  
✅ **Terraform** - Infrastructure as Code  
✅ **gke-gcloud-auth-plugin** - Authenticate kubectl with GKE  

## Summary - What You Connected To

✅ **GCP Project:** charged-thought-485008-q7  
✅ **GKE Cluster:** digitalbank-gke (9 nodes)  
✅ **Terraform State:** GCS backend (35 resources)  
✅ **Databases:** 3 Cloud SQL instances  
✅ **Applications:** 4 microservices running  

---

**🎉 You're all set! Your new system is now connected to the Digital Banking infrastructure.**

**Last Updated:** January 30, 2026
