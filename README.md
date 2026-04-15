# 🚀 n8n DevOps: The Complete Production Guide

From Zero to Enterprise Automation in 11 Phases

Welcome! This is a comprehensive, hands-on learning and implementation guide for n8n—the open-source workflow automation platform that transforms how teams orchestrate business processes, integrate systems, and build intelligent automation.

Whether you're automating repetitive tasks, building ETL pipelines, connecting APIs, or designing AI-powered agents, this repository provides the knowledge, patterns, and production-ready examples you need.

## What You'll Build

By the end of this journey, you will have:

- ✅ A secure, production-grade n8n deployment (Docker Compose → Kubernetes)
- ✅ Real workflows spanning ETL, integrations, alerting, and data transformation
- ✅ AI agents for chatbots, ticket resolution, and DevOps alert automation
- ✅ Queue-based scaling with workers for high-throughput processing
- ✅ High-availability architecture ready for enterprise workloads
- ✅ CI/CD pipelines for reproducible workflow deployment
- ✅ Monitoring, backup, and incident response playbooks

## Who This Is For

### DevOps Engineers & Platform Teams

- Learn how to deploy, scale, and operate n8n like a professional SRE
- Understand queue mode, workers, Redis, PostgreSQL tuning
- Master Kubernetes + Helm for HA deployments

### Backend & Integration Engineers

- Master API integrations, data transformation, and webhook patterns
- Build complex ETL and data pipeline workflows
- Integrate internal and external systems seamlessly

### Enterprise Automation Teams

- Implement business process automation with governance
- Design AI agents and intelligent automation systems
- Build reusable, testable workflow libraries

### DevOps Leaders & Architects

- Reference architecture for automation platforms
- Security hardening and compliance checklist
- Scaling patterns and best practices

---

## 📚 The 11-Phase Learning Path

Each phase builds on the previous one, progressing from foundational concepts to enterprise-ready production systems.

| Phase | Focus | You'll Learn | Time | Click to Open |
| --- | --- | --- | --- | --- |
| **1** | Foundations | n8n concepts, triggers, data flows, expressions | 2-3h | [Phase 1 Doc](docs/phases/phase-01-foundations.md) |
| **2** | Install & Setup | Docker, Docker Compose, PostgreSQL, NGINX | 1-2h | [Phase 2 Doc](docs/phases/phase-02-installation-environment.md) |
| **3** | Security | Encryption, OAuth, webhook security, auth patterns | 2h | [Phase 3 Doc](docs/phases/phase-03-security-authentication.md) |
| **4** | Core Workflows | ETL, conditionals, loops, error handling | 4-5h | [Phase 4 Doc](docs/phases/phase-04-workflow-development.md) |
| **5** | Advanced Integrations | APIs, pagination, file processing, code nodes | 3-4h | [Phase 5 Doc](docs/phases/phase-05-advanced-nodes-integrations.md) |
| **6** | AI Agents | LLMs, agent patterns, memory, function calling | 4h | [Phase 6 Doc](docs/phases/phase-06-ai-agents-automation.md) |
| **7** | Administration | Queue mode, workers, logs, backup strategies | 3h | [Phase 7 Doc](docs/phases/phase-07-administration-operations.md) |
| **8** | Scaling & HA | Kubernetes, Helm, multi-worker, load balancing | 3-4h | [Phase 8 Doc](docs/phases/phase-08-scaling-high-availability.md) |
| **9** | Troubleshooting | Debugging, real-world failure scenarios | 2h | [Phase 9 Doc](docs/phases/phase-09-troubleshooting-debugging.md) |
| **10** | Custom Nodes | TypeScript, custom integrations, packaging | 4h | [Phase 10 Doc](docs/phases/phase-10-custom-development.md) |
| **11** | Testing & CI/CD | Git workflows, GitHub Actions, IaC (Terraform) | 3h | [Phase 11 Doc](docs/phases/phase-11-testing-cicd.md) |

**Total estimated time: 30-35 hours** (Adjust based on your background and pace)

👉 **Start Here:** [End-to-End Guide](docs/END_TO_END_GUIDE.md) for a complete milestone roadmap, or jump to [All Phase Docs](docs/phases/) for individual phase deep-dives.

### 🔥 Quick Learning Links (Click by Goal)

- **Beginner Path:** [Phase 1 - Foundations](docs/phases/phase-01-foundations.md) → [Phase 2 - Installation & Environment](docs/phases/phase-02-installation-environment.md) → [Phase 3 - Security & Authentication](docs/phases/phase-03-security-authentication.md)
- **Workflow Builder Path:** [Phase 4 - Workflow Development](docs/phases/phase-04-workflow-development.md) → [Phase 5 - Advanced Nodes & Integrations](docs/phases/phase-05-advanced-nodes-integrations.md)
- **AI Automation Path:** [Phase 6 - AI Agents & Automation](docs/phases/phase-06-ai-agents-automation.md)
- **DevOps / SRE Path:** [Phase 7 - Administration & Operations](docs/phases/phase-07-administration-operations.md) → [Phase 8 - Scaling & HA](docs/phases/phase-08-scaling-high-availability.md) → [Phase 11 - Testing & CI/CD](docs/phases/phase-11-testing-cicd.md)
- **Troubleshooting Path:** [Phase 9 - Troubleshooting & Debugging](docs/phases/phase-09-troubleshooting-debugging.md)
- **Custom Extension Path:** [Phase 10 - Custom Development](docs/phases/phase-10-custom-development.md)
- **Full highlighted index with descriptions:** [Docs Highlighted Index](docs/HIGHLIGHTED_DOCS_INDEX.md)

---

## 🏗️ Repository Structure

```text
.
├── README.md                           # You are here
├── docs
│   ├── END_TO_END_GUIDE.md            # Execution roadmap & milestones
│   ├── deployment
│   │   ├── docker-compose-postgres-nginx.md  # Production baseline
│   │   └── kubernetes-helm.md               # Enterprise HA setup
│   ├── operations-runbook.md          # Daily ops, backup, incident response
│   ├── phases
│   │   ├── phase-01-foundations.md
│   │   ├── phase-02-installation-environment.md
│   │   ├── phase-03-security-authentication.md
│   │   ├── phase-04-workflow-development.md
│   │   ├── phase-05-advanced-nodes-integrations.md
│   │   ├── phase-06-ai-agents-automation.md
│   │   ├── phase-07-administration-operations.md
│   │   ├── phase-08-scaling-high-availability.md
│   │   ├── phase-09-troubleshooting-debugging.md
│   │   ├── phase-10-custom-development.md
│   │   └── phase-11-testing-cicd.md
│   └── security-hardening-checklist.md  # Security controls & validation
└── examples
    ├── ci
    │   └── github-actions/deploy.yml          # GitHub Actions CI/CD
    ├── docker-compose
    │   ├── .env.example                       # Configuration template
    │   ├── docker-compose.yml                 # n8n + PostgreSQL + NGINX
    │   └── nginx.conf                         # Reverse proxy config
    ├── kubernetes
    │   └── values-ha.yaml                     # Helm chart values (HA)
    └── terraform
        └── main.tf                            # Kubernetes provisioning
```

---

## 🚀 Quick Start (5 Minutes)

Get n8n running locally in one command:

### Step 1: Clone & configure

```bash
cd /Users/shashi/Downloads/n8n-devops
cp examples/docker-compose/.env.example .env

# Edit .env to change credentials (optional, defaults work for local development)
# vim .env
```

### Step 2: Start the stack

```bash
docker compose -f examples/docker-compose/docker-compose.yml --env-file .env up -d
```

**What just started:**

- **n8n** ([http://localhost](http://localhost)) — the workflow editor
- **PostgreSQL** — durable metadata store
- **NGINX** — reverse proxy (production pattern)

### Step 3: Access n8n

Open [http://localhost](http://localhost) in your browser.

**Default credentials** (from `.env.example`):

- Username: `admin`
- Password: `change-me`

### Step 4: First workflow (2 minutes)

1. Create a new workflow
2. Add a **Cron** trigger (every 5 minutes)
3. Add a **Set** node with `{message: "Hello, n8n!"}`
4. Activate and wait for the next execution

**Congrats!** You just built your first automated workflow. 🎉

### Health check

```bash
# Verify all services are running
docker compose -f examples/docker-compose/docker-compose.yml --env-file .env ps

# View logs
docker compose -f examples/docker-compose/docker-compose.yml --env-file .env logs -f n8n
```

### Stop everything

```bash
docker compose -f examples/docker-compose/docker-compose.yml --env-file .env down
```

---

## 💻 Installation Methods (Detailed Guides)

Choose your platform and installation method:

### macOS

- 🐳 **Docker Desktop** (recommended) — Get started in 15 minutes
- 🍻 **Homebrew + npm** — For developers who prefer local tools
- 📦 **Binary** — No dependencies approach
- 🐧 **WSL2 + Docker** — Linux-like environment on Mac

👉 **Full guide:** [macOS Installation Guide](docs/INSTALL_macOS.md)

### Linux (Ubuntu, Debian, CentOS, RHEL)

- 🐳 **Docker Compose** (recommended) — Production-grade with database
- 📦 **npm** — Global or project-specific installation
- 🔧 **Systemd Service** — Run as background service
- 📥 **Binary** — Standalone executable

👉 **Full guide:** [Linux Installation Guide](docs/INSTALL_Linux.md)

### Windows (10, 11, Server)

- 🐳 **Docker Desktop + WSL2** (recommended) — Best performance on modern Windows
- 🐳 **Docker Desktop** — Works on Windows Home
- 📦 **npm** — Node.js installation
- 🐧 **WSL2 + npm** — Ubuntu environment within Windows

👉 **Full guide:** [Windows Installation Guide](docs/INSTALL_Windows.md)

### Installation Decision Tree

| Your Situation | Recommended Method | Guide |
| --- | --- | --- |
| I want the easiest setup, production-ready | Docker Compose | [macOS](docs/INSTALL_macOS.md), [Linux](docs/INSTALL_Linux.md) |
| I'm a developer, want to modify code | npm | [macOS](docs/INSTALL_macOS.md), [Linux](docs/INSTALL_Linux.md), [Windows](docs/INSTALL_Windows.md) |
| I don't have Docker | npm or Binary | [macOS](docs/INSTALL_macOS.md), [Linux](docs/INSTALL_Linux.md), [Windows](docs/INSTALL_Windows.md) |
| I'm on Windows with WSL2 | Docker Desktop + WSL2 | [Windows Guide](docs/INSTALL_Windows.md) |
| I'm on Windows Home (no WSL2) | Docker Desktop or npm | [Windows Guide](docs/INSTALL_Windows.md) |
| I need enterprise HA deployment | Kubernetes + Helm | [Kubernetes + Helm Guide](docs/deployment/kubernetes-helm.md) |
| I want Infrastructure as Code | Terraform | [Terraform Example](examples/terraform/main.tf) |

### System Requirements Summary

| Platform | Min RAM | Min Disk | Notes |
| --- | --- | --- | --- |
| macOS (Intel) | 4 GB | 10 GB | Docker Desktop 4.0+ |
| macOS (Apple Silicon) | 6 GB | 10 GB | Native M1/M2/M3 support |
| Linux (Ubuntu/Debian) | 4 GB | 10 GB | Docker or npm |
| Linux (RHEL/CentOS) | 4 GB | 10 GB | Docker or npm |
| Windows 10/11 | 6 GB | 10 GB | WSL2 or Docker Desktop |
| Production (any) | 8-16 GB | 50+ GB | Database + persistent storage |

👉 **Comprehensive installation guide with all methods:** [Installation Master Guide](docs/INSTALLATION.md)

---

## 📖 Real-World Use Cases

### 1. **ETL Data Pipeline** (Phase 4)

**Scenario:** Sync customer data from Salesforce → PostgreSQL → Data Warehouse

```text
[Trigger: Webhook] → [API: Fetch Salesforce] → [Transform: Normalize schema]
  → [Load: PostgreSQL] → [Alert: Slack on error]
```

**You'll learn:** Data transformation, error handling, API pagination, alerting

### 2. **API Aggregation & Monitoring** (Phase 5)

**Scenario:** Monitor 5 microservices health → consolidate status → alert on failure

```text
[Trigger: Cron every 5 min] → [HTTP Requests in parallel] → [Merge responses]
  → [Check health status] → [Send Slack alert if unhealthy]
```

**You'll learn:** Parallel execution, HTTP advanced patterns, conditional branching

### 3. **AI-Powered Ticket Triage** (Phase 6)

**Scenario:** New Jira tickets → AI analyzes → auto-assigns priority & assignee

```text
[Trigger: Jira webhook] → [Extract ticket details] → [Call OpenAI API]
  → [Parse AI response] → [Update Jira with priority & assignee]
```

**You'll learn:** AI integrations, prompt engineering, stateful workflows

### 4. **Multi-Source Data Ingestion at Scale** (Phases 7-8)

**Scenario:** Ingest logs from 10+ sources, transform, and index in Elasticsearch

```text
[Multiple webhooks] → [Queue: Redis] → [Workers: 5 parallel processors]
  → [Batch: Split into chunks] → [Elasticsearch: Index] → [PostgreSQL: Track]
```

**You'll learn:** Queue mode, worker architecture, batch processing, high throughput

---

## 🎯 How to Use This Repository

### For Beginners

1. **Start with Phase 1-3** ([Phase 1 Foundations](docs/phases/phase-01-foundations.md))
2. Deploy local stack (Quick Start above)
3. Build the 3 hands-on workflows in Phase 1
4. Move to Phase 2 and 3 for security

**Time estimate:** 1 week (part-time)

### For Intermediate Users

1. **Skip Phase 1-2**, review Phase 3 security
2. Jump to **Phase 4-6** for real workflow building
3. Start with the ETL and AI agent examples above
4. Deploy to Docker Compose for staging

**Time estimate:** 1-2 weeks (part-time)

### For DevOps/SRE Teams

1. **Focus on Phase 2, 7-11**
2. Study deployment docs: [Docker Compose + PostgreSQL + NGINX](docs/deployment/docker-compose-postgres-nginx.md) and [Kubernetes + Helm](docs/deployment/kubernetes-helm.md)
3. Work through queue mode setup (Phase 7)
4. Implement monitoring and backups (Phase 7-9)
5. Terraform + CI/CD pipeline (Phase 11)

**Time estimate:** 2-3 weeks

### For Enterprise Teams

1. Complete **all phases** as a team
2. Use this as your internal n8n standards document
3. Adapt examples for your infrastructure
4. Establish governance and approval workflows

**Time estimate:** 4-6 weeks

---

## 🔒 Security By Default

All examples follow security best practices:

- ✅ **Encryption**: Environment-based encryption keys (never hardcoded)
- ✅ **Database**: PostgreSQL with separate user credentials
- ✅ **Network**: NGINX reverse proxy with proper headers
- ✅ **Secrets**: Credential storage in n8n vault
- ✅ **Webhooks**: HMAC signature validation support
- ✅ **OAuth**: Built-in OAuth2 provider integrations

See [Security Hardening Checklist](docs/security-hardening-checklist.md) for a complete checklist.

---

## 📈 Production Deployment Paths

### Option 1: Docker Compose (Small to Medium)

**Best for:** Teams, startups, single-region deployments

```bash
# Uses: PostgreSQL, NGINX, persistent volumes
# Scaling: 1 instance + 1 database
docker compose -f examples/docker-compose/docker-compose.yml --env-file .env up -d
```

**Upgrade path:** Easily move to Kubernetes later

### Option 2: Kubernetes + Helm (Enterprise)

**Best for:** High availability, multi-region, complex deployments

```bash
# Uses: Helm, Redis queue, PostgreSQL, Ingress
# Scaling: Multiple workers, managed DB
helm upgrade --install n8n n8n/n8n -f examples/kubernetes/values-ha.yaml
```

See [Kubernetes + Helm Deployment Guide](docs/deployment/kubernetes-helm.md) for detailed setup.

### Option 3: Infrastructure as Code (Terraform)

**Best for:** GitOps, reproducible infrastructure, team collaboration

```bash
# Provisions: Kubernetes cluster + n8n Helm release
terraform apply -f examples/terraform/main.tf
```

---

## 📚 Documentation Navigation

| Document | Best For |
| --- | --- |
| [End-to-End Guide](docs/END_TO_END_GUIDE.md) | Milestone roadmap & sequencing |
| [Highlighted Docs Index](docs/HIGHLIGHTED_DOCS_INDEX.md) | Clickable curated list by audience and goal |
| [All Phase Deep-Dives](docs/phases/) | Phase-specific deep-dives |
| [Docker Compose Deployment](docs/deployment/docker-compose-postgres-nginx.md) | Local & staging setup |
| [Kubernetes + Helm Deployment](docs/deployment/kubernetes-helm.md) | Production HA architecture |
| [Operations Runbook](docs/operations-runbook.md) | Daily operations & incident response |
| [Security Hardening Checklist](docs/security-hardening-checklist.md) | Security controls validation |
| [Examples Folder](examples/) | Copy-paste ready code & configs |

---

## 🎓 Learning Outcomes By Phase

After completing each phase, you'll be able to:

**Phase 1 (Foundations):** Explain n8n concepts, build your first workflow
**Phase 2 (Install & Setup):** Deploy n8n in Docker with database persistence
**Phase 3 (Security):** Configure encryption, OAuth, and webhook security
**Phase 4 (Workflows):** Build ETL, alerting, and data transformation workflows
**Phase 5 (Advanced Integrations):** Integrate complex APIs, process files, pagination
**Phase 6 (AI Agents):** Build autonomous agents with LLMs
**Phase 7 (Administration):** Set up queue mode, workers, backup strategies
**Phase 8 (Scaling):** Deploy Kubernetes HA architecture with Helm
**Phase 9 (Troubleshooting):** Debug failures and resolve incidents
**Phase 10 (Custom Nodes):** Build custom integrations for proprietary APIs
**Phase 11 (Testing & CI/CD):** Version workflows in Git, automate deployment

---

## ❓ FAQ

**Q: Do I need to know Docker/Kubernetes beforehand?**
A: No, but it helps. Phase 2 covers Docker basics; Phase 8 explains Kubernetes.

**Q: Can I deploy n8n without Docker?**
A: Yes, but Docker deployment is recommended. See Phase 2 for alternatives (npm, binary).

**Q: Is this suitable for production workloads?**
A: Yes. All examples follow production best practices. Start with Docker Compose; scale to Kubernetes.

**Q: Can I use this with my own APIs?**
A: Absolutely. Phase 5 focuses on custom API integrations.

**Q: How do I get help if I'm stuck?**
A: Check [Operations Runbook](docs/operations-runbook.md) and [Phase 9 Troubleshooting](docs/phases/phase-09-troubleshooting-debugging.md). Consult n8n docs and community.

---

## 🤝 Contributing & Feedback

Found an issue or improvement? PRs welcome! This guide is meant to evolve with community feedback.

---

## 📄 License & Attribution

This repository is a comprehensive guide for n8n (open-source). n8n is licensed under the Sustainable Use License. Refer to [n8n GitHub](https://github.com/n8n-io/n8n) for details.

---

## 🎯 Next Steps

1. ✅ Clone this repo
2. ✅ Run Quick Start above
3. ✅ Open [End-to-End Guide](docs/END_TO_END_GUIDE.md) for full roadmap
4. ✅ Start Phase 1: [Foundations](docs/phases/phase-01-foundations.md)
5. ✅ Share with your team!

**Happy Automating!** 🚀
