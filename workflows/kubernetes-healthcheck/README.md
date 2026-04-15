# Kubernetes / OpenShift Health Check Workflow

## What It Does

- Runs **every 6 hours** (fully configurable)
- Fetches all **Nodes**, **Pods** (failed/pending), **Deployments**, and **Namespaces** from the Kubernetes API
- Builds a rich **HTML email report** with tables for node status, failed pods, and deployment health
- Routes to:
  - **ALERT email** (with CC) if unhealthy nodes or failed pods are found
  - **OK email** if everything is healthy

## Required Environment Variables

Set these in n8n → Settings → Environment Variables or in your `.env`:

```env
K8S_API_URL=https://your-k8s-api-server:6443
SMTP_FROM=n8n-alerts@yourcompany.com
L3_TEAM_EMAIL=l3-team@yourcompany.com
L3_CC_EMAIL=l3-lead@yourcompany.com
```

## Required Credentials in n8n

1. **`k8s-api-token`** — HTTP Header Auth
   - Header name: `Authorization`
   - Header value: `Bearer <your-service-account-token>`

2. **`smtp-l3-team`** — SMTP
   - Your SMTP host, port, username, password

## Create Kubernetes Service Account (copy-paste)

```bash
kubectl create serviceaccount n8n-monitor -n default
kubectl create clusterrolebinding n8n-monitor-binding \
  --clusterrole=view \
  --serviceaccount=default:n8n-monitor

# Get token (Kubernetes 1.24+)
kubectl create token n8n-monitor --duration=8760h
```

## Import Steps

1. Open n8n → **Workflows → Import from File**
2. Select `workflow.json`
3. Set credentials and env vars above
4. Click **Activate**

## Sample Report Output

The email includes:

- Cluster endpoint and timestamp
- Overall status badge (🟢 ALL SYSTEMS HEALTHY / 🔴 ACTION REQUIRED)
- Node table (name, role, status, CPU, memory, OS)
- Failed/Pending Pods table (namespace, name, phase, reason, restart count)
- Deployments table (namespace, name, desired/ready replicas, health)

## Extending to OpenShift

For OpenShift, replace `K8S_API_URL` with your OpenShift API server URL.  
Use an OpenShift service account token (same steps above, using `oc` instead of `kubectl`).
