# 🤖 Production-Ready n8n Workflows

Four real-world, production-grade automation workflows — import directly into n8n and start using immediately.

---

## 📂 Workflow Catalogue

| # | Folder | Workflow | Audience | Difficulty |
|---|--------|----------|----------|------------|
| 1 | [`kubernetes-healthcheck/`](kubernetes-healthcheck/) | Kubernetes / OpenShift Health Check + L3 Email Report | DevOps / SRE | ⭐⭐ Intermediate |
| 2 | [`cloud-monitoring/`](cloud-monitoring/) | AWS / Azure Node Utilization Monitor + L3 Alert | Cloud / Platform Eng | ⭐⭐⭐ Advanced |
| 3 | [`social-campaign/`](social-campaign/) | AI-Powered Social Media Campaign Creator | Marketing / Automation | ⭐⭐ Intermediate |
| 4 | [`job-hunting/`](job-hunting/) | Remote Job Hunter — Auto Apply 100 Jobs/Day + Excel Report | Individual / Career | ⭐⭐⭐ Advanced |

---

## ⚡ How to Import a Workflow

1. Open your n8n instance (`http://localhost:5678` or your domain)
2. Navigate to **Workflows → Import from File**
3. Select the `.json` file from the relevant folder
4. Click **Import**
5. Update credentials (SMTP, Kubernetes API token, cloud API keys, etc.)
6. Click **Activate**

---

## 🔑 Required Credentials Per Workflow

### Workflow 1 – Kubernetes Health Check

| Credential | Where to set in n8n |
|---|---|
| Kubernetes API Bearer Token | `Header Auth` credential — name it `k8s-api-token` |
| SMTP Server (for email) | `SMTP` credential — name it `smtp-l3-team` |

### Workflow 2 – Cloud Monitoring

| Credential | Where to set in n8n |
|---|---|
| AWS Access Key + Secret | `AWS` credential — name it `aws-monitoring` |
| Azure Service Principal | `HTTP Header Auth` — name it `azure-monitoring` |
| SMTP Server | `SMTP` credential — name it `smtp-l3-team` |

### Workflow 3 – Social Campaign

| Credential | Where to set in n8n |
|---|---|
| OpenAI API Key | `OpenAI` credential — name it `openai-campaigns` |
| Twitter / X Bearer Token | `Twitter OAuth2` — name it `twitter-brand` |
| LinkedIn OAuth2 | `LinkedIn OAuth2` — name it `linkedin-brand` |
| Google Sheets OAuth2 | `Google Sheets OAuth2` — name it `gsheets-campaigns` |

### Workflow 4 – Job Hunting

| Credential | Where to set in n8n |
|---|---|
| Naukri.com session cookie | `HTTP Header Auth` — name it `naukri-session` |
| LinkedIn session cookie | `HTTP Header Auth` — name it `linkedin-session` |
| Indeed API / session | `HTTP Header Auth` — name it `indeed-session` |
| Monster session cookie | `HTTP Header Auth` — name it `monster-session` |
| Google Sheets OAuth2 | `Google Sheets OAuth2` — name it `gsheets-jobs` |

---

## 🧪 Validation

Each folder contains:

- `workflow.json` — importable n8n workflow
- `README.md` — setup instructions, env variables, and sample output

---

## 🎓 Difficulty Guide

- ⭐ **Beginner** — Basic nodes, minimal credentials, great for learning
- ⭐⭐ **Intermediate** — REST API calls, conditional logic, external credentials
- ⭐⭐⭐ **Advanced** — AI agents, multi-source data, loops, parallel execution, Excel/Sheets output
