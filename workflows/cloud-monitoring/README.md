# ☁️ AWS & Azure Node Utilization Monitor

Polls **AWS CloudWatch** and **Azure Monitor** every hour, detects CPU/memory pressure, and e-mails an L3 performance report with full HTML tables.

---

## 📐 Architecture

```
Every Hour (Cron)
     │
     ▼
Set Time Window (Code)
     │
     ├──► AWS: Get EC2 CPU via CloudWatch   ─┐
     ├──► AWS: Get EC2 Memory via CloudWatch ─┤
     ├──► Azure: Get VM CPU Metrics          ─┤── Merge ──► Analyse & Build Report ──► Any Issues?
     └──► Azure: Get VM Memory Metrics       ─┘                                          │
                                                                                    ┌────┴────┐
                                                                              Issues?     No Issues?
                                                                                │               │
                                                                        Send Performance   Send Healthy
                                                                            Alert          Report
```

---

## ⚙️ Environment Variables

Set these in **n8n → Settings → Variables** (or in your `.env` if self-hosted):

| Variable | Required | Description | Example |
|---|---|---|---|
| `AWS_REGION` | ✅ | AWS region for CloudWatch | `us-east-1` |
| `AZURE_SUBSCRIPTION_ID` | ✅ | Azure subscription UUID | `xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx` |
| `AZURE_BEARER_TOKEN` | ✅ | Azure AD access token (use managed identity or service principal) | `eyJ0eXAiOiJKV1QiLCJhbGci...` |
| `SMTP_FROM` | ✅ | Sender e-mail address | `monitoring@yourcompany.com` |
| `L3_TEAM_EMAIL` | ✅ | L3 team distribution e-mail | `l3-team@yourcompany.com` |
| `L3_CC_EMAIL` | ☑️ | Optional CC (manager / on-call) | `oncall@yourcompany.com` |
| `CPU_WARN_THRESHOLD` | ☑️ | CPU % warning level (default 70) | `70` |
| `CPU_CRIT_THRESHOLD` | ☑️ | CPU % critical level (default 90) | `90` |
| `MEM_WARN_THRESHOLD` | ☑️ | Memory % warning level (default 75) | `75` |
| `MEM_CRIT_THRESHOLD` | ☑️ | Memory % critical level (default 95) | `95` |

---

## 🔑 Credentials Setup

### 1 · `aws-monitoring` (HTTP Header Auth)

AWS CloudWatch uses SigV4 signing. For simplest n8n integration, use an **AWS Monitoring IAM role** with read-only CloudWatch access and call via a **Lambda proxy** or the AWS SDK HTTP endpoint with a pre-signed URL. Alternatively:

1. Create IAM policy:

```json
{
  "Version": "2012-10-17",
  "Statement": [{
    "Effect": "Allow",
    "Action": [
      "cloudwatch:GetMetricData",
      "cloudwatch:GetMetricStatistics",
      "cloudwatch:ListMetrics",
      "ec2:DescribeInstances"
    ],
    "Resource": "*"
  }]
}
```

2. Create IAM user, attach policy, generate Access Key + Secret.
3. In n8n: **Credentials → New → HTTP Header Auth**

| Field | Value |
|---|---|
| Name | `aws-monitoring` |
| Header Name | `Authorization` |
| Header Value | Use AWS SigV4 pre-signed header or replace HTTP node with n8n AWS node |

> 💡 **Tip:** For production, replace the HTTP Request nodes with **n8n-nodes-base.awsCloudWatch** nodes (if the community node is installed) to get automatic SigV4 signing.

---

### 2 · `azure-monitoring` (HTTP Header Auth)

1. Register an App in **Azure Active Directory**:

```bash
az ad sp create-for-rbac --name "n8n-monitoring" \
  --role "Monitoring Reader" \
  --scopes "/subscriptions/$AZURE_SUBSCRIPTION_ID"
```

2. Get a bearer token (automate via a preceding n8n HTTP node if needed):

```bash
curl -X POST \
  "https://login.microsoftonline.com/$TENANT_ID/oauth2/v2.0/token" \
  -d "grant_type=client_credentials&client_id=$CLIENT_ID&client_secret=$CLIENT_SECRET&scope=https://management.azure.com/.default"
```

3. In n8n: **Credentials → New → HTTP Header Auth**

| Field | Value |
|---|---|
| Name | `azure-monitoring` |
| Header Name | `Authorization` |
| Header Value | `Bearer <your-token>` |

---

### 3 · `smtp-l3-team` (SMTP)

In n8n: **Credentials → New → SMTP**

| Field | Value |
|---|---|
| Name | `smtp-l3-team` |
| Host | Your SMTP server (e.g., `smtp.gmail.com`) |
| Port | `465` (TLS) or `587` (STARTTLS) |
| User | SMTP username |
| Password | SMTP password / app password |

---

## 📥 Import into n8n

1. Open n8n UI → **Workflows → Import from File**
2. Select `workflow.json` from this folder
3. Click the **Cloud Monitoring** workflow name to open it
4. Go to **Credentials** and update all 3 credentials with real values
5. Set all required **Environment Variables** in Settings
6. Update the CloudWatch API URLs in the HTTP Request nodes to match your region:
   - `https://monitoring.{region}.amazonaws.com` → replace `{region}` with `$env.AWS_REGION`
7. Toggle the workflow **Active** (top-right)

---

## 🧪 Testing

- **Manual run**: Click ▶ Execute Workflow to trigger a one-shot run
- **Check outputs**: Click each node to inspect response data
- **Simulate an alert**: Temporarily lower `CPU_WARN_THRESHOLD` to `0` — all instances will appear as issues

---

## 📬 Sample Email Output

**Subject:** `[Cloud Monitor] 🟡 PERFORMANCE WARNING — Thu, 10 Jul 2025 10:00:00 GMT`

The HTML email contains:
- Overall status badge (🟢 / 🟡 / 🔴)
- Issues table with severity, instance name, metric, and value
- Full metrics table for all queried nodes (AWS + Azure)
- Auto-generated timestamp and threshold reference

---

## 🔧 Customisation

| Goal | What to Change |
|---|---|
| Add more AWS metrics (disk, network) | Add extra **HTTP Request** nodes + parse in Code node |
| Monitor ECS / EKS workloads | Change `MetricName` to `ECS/ContainerInsights/...` |
| Add Slack alerts | Insert **Slack** node after `Send Performance Alert` |
| Store history in database | Add **Postgres / MySQL** node after the Code node |
| Add PagerDuty escalation | Add **PagerDuty** node for CRITICAL branch |
| Use real AWS SigV4 | Replace HTTP nodes with `n8n-nodes-base.awsCloudWatch` |

---

## 🐛 Troubleshooting

| Symptom | Likely Cause | Fix |
|---|---|---|
| 403 on CloudWatch call | IAM permissions missing | Attach `CloudWatchReadOnlyAccess` policy |
| 401 on Azure call | Token expired | Automate token refresh with a pre-HTTP-node |
| Empty metric data | No CWAgent installed | Install CloudWatch Agent on EC2 instances |
| Email not delivered | SMTP config wrong | Test with `telnet smtp.host 465` |
