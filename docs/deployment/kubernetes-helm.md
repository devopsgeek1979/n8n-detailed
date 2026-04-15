# Kubernetes + Helm Deployment (HA Baseline)

This document explains a production HA setup for n8n using Helm.

## Components

- n8n main deployment
- n8n worker deployments
- Redis for queue mode
- PostgreSQL (managed recommended)
- Ingress controller + TLS

## Helm values

Use `examples/kubernetes/values-ha.yaml` as a starting point.

## Deployment flow

```bash
helm repo add n8n https://helm.n8n.io
helm repo update
helm upgrade --install n8n n8n/n8n -f examples/kubernetes/values-ha.yaml -n n8n --create-namespace
```

## Validation

```bash
kubectl get pods -n n8n
kubectl get ingress -n n8n
kubectl logs -n n8n deploy/n8n
```

## HA notes

- Run at least 2 workers for fault tolerance
- Use managed PostgreSQL with backups and replication
- Use Redis persistence if self-hosted
