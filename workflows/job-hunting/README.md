# 💼 Remote Job Hunter — Auto-Apply 100 Jobs/Day

Runs every morning at 08:00 → searches **LinkedIn**, **Indeed**, **Naukri**, and **Monster** for remote jobs → deduplicates → auto-applies up to 100 jobs/day → logs every application to **Google Sheets** → e-mails you a full HTML report.

---

## 📐 Architecture

```
Daily at 8 AM (Cron)
        │
        ▼
 Init Search Config
        │
  ┌─────┼─────┬──────┐
  ▼     ▼     ▼      ▼
LinkedIn Indeed Naukri Monster
  │     │     │      │
  └──── Merge All Job Results ────┘
                   │
         Normalise & Deduplicate
                   │
              Auto Apply  ◄── per-job loop
                   │
          Log to Google Sheets
                   │
         Build Daily Summary
                   │
          Email Daily Report
```

---

## ⚙️ Environment Variables

| Variable | Required | Description | Example |
|---|---|---|---|
| `JOB_KEYWORDS` | ✅ | Search keywords | `DevOps Engineer` |
| `JOB_LOCATION` | ✅ | Target location | `Remote` |
| `MAX_DAILY_APPLY` | ☑️ | Max applications/day (default 100) | `100` |
| `SMTP_FROM` | ✅ | Sender email | `jobbot@yourmail.com` |
| `JOB_REPORT_EMAIL` | ✅ | Where to send the daily report | `you@yourmail.com` |
| `GSHEETS_JOBS_ID` | ✅ | Google Sheet ID for job log | `1BxiMVs0XRA5nFMd...` |

---

## 🔑 Credentials Setup

### 1 · `linkedin-session` (HTTP Header Auth)

LinkedIn Jobs guest search does not require authentication for the public search endpoint. For Easy Apply (clicking Apply), you need OAuth:

1. Create a LinkedIn App at [developer.linkedin.com](https://developer.linkedin.com)
2. Request `r_liteprofile`, `w_member_social`, `r_emailaddress` permissions
3. Complete OAuth 2.0 PKCE flow
4. In n8n: **Credentials → New → HTTP Header Auth**

| Field | Value |
|---|---|
| Name | `linkedin-session` |
| Header Name | `Authorization` |
| Header Value | `Bearer <oauth-token>` |

---

### 2 · `indeed-session` (HTTP Header Auth)

Indeed's public search API is accessible without a key for basic scraping. For the Publisher API:

1. Register at [ads.indeed.com/jobroll/xmlfeed](https://ads.indeed.com/jobroll/xmlfeed)
2. Get your Publisher ID
3. Append `&publisher=<YOUR_ID>` to the API URL in the workflow node

| Field | Value |
|---|---|
| Name | `indeed-session` |
| Header Name | `User-Agent` |
| Header Value | `n8n-jobbot/1.0` |

---

### 3 · `naukri-session` (HTTP Header Auth)

Naukri provides a public job search API (no auth required for basic search):

| Field | Value |
|---|---|
| Name | `naukri-session` |
| Header Name | `appid` |
| Header Value | `109` |

For authenticated 1-click apply, you need a Naukri account session cookie:

| Field | Value |
|---|---|
| Header Name | `Cookie` |
| Header Value | `nauk_at=<your-session-cookie>` |

---

### 4 · `monster-session` (HTTP Header Auth)

Monster public search (no auth for basic scraping):

| Field | Value |
|---|---|
| Name | `monster-session` |
| Header Name | `User-Agent` |
| Header Value | `n8n-jobbot/1.0` |

---

### 5 · `smtp-l3-team` (SMTP)

Reused from other workflows. In n8n: **Credentials → New → SMTP**

| Field | Value |
|---|---|
| Name | `smtp-l3-team` |
| Host | Your SMTP host |
| Port | `465` or `587` |
| User | SMTP username |
| Password | SMTP password |

---

### 6 · `gsheets-jobs` (Google Sheets OAuth2)

1. In n8n: **Credentials → New → Google Sheets OAuth2 API**
2. Authorise your Google account
3. Name it `gsheets-jobs`
4. Create a Google Sheet with a tab named **Job Applications** and these headers:

```
Date | Applied At | Portal | Job Title | Company | Location | Salary | Job URL | Job ID | Keywords | Status | Notes
```

---

## 📥 Import into n8n

1. **Workflows → Import from File** → select `workflow.json`
2. Update all 6 credentials
3. Set all environment variables
4. Activate the workflow — it will run automatically every day at 08:00

---

## 🚀 Manual Test Run

1. Open the workflow
2. Click **Execute Workflow** (top right)
3. Watch each node complete in sequence
4. Check your Google Sheet — rows should appear
5. Check your inbox — daily report email should arrive

---

## 📊 Google Sheets Schema

Each row in **Job Applications** contains:

| Column | Description |
|---|---|
| Date | Search date (YYYY-MM-DD) |
| Applied At | Exact timestamp of application |
| Portal | LinkedIn / Indeed / Naukri / Monster |
| Job Title | Position title |
| Company | Employer name |
| Location | Job location (usually Remote) |
| Salary | Salary range (if available) |
| Job URL | Direct link to job posting |
| Job ID | Platform-specific job ID |
| Keywords | Search keywords used |
| Status | APPLIED_EASY_APPLY / APPLIED_INSTANT_APPLY / APPLIED_1CLICK / MANUAL_REQUIRED |
| Notes | Additional notes from apply step |

---

## 📬 Daily Report Email

**Subject:** `[Job Hunter] 87 Applications Submitted — 2025-07-10`

The HTML email contains:
- Total applications count
- Breakdown by portal (LinkedIn, Indeed, Naukri, Monster)
- Breakdown by status
- Table of top 20 applications with links

---

## ⚠️ Important Notes

### Auto-Apply Limitations

| Portal | Auto-Apply Support | Method |
|---|---|---|
| LinkedIn | ✅ Easy Apply | API + profile data |
| Indeed | ✅ Instant Apply | API redirect |
| Naukri | ✅ 1-Click Apply | API with session cookie |
| Monster | ❌ No API apply | `MANUAL_REQUIRED` flagged |

### Rate Limiting
- Each portal may rate-limit requests; the workflow uses 1 request per portal per day
- If you hit 429 errors, increase the cron interval or add delays between nodes

### Terms of Service
- Review each portal's TOS before enabling auto-apply in production
- Some platforms restrict automated submissions — use responsibly

---

## 🔧 Customisation

| Goal | Change |
|---|---|
| Filter by experience level | Add `experienceLevel` to keywords or URL params |
| Filter by salary range | Add filtering in `Normalise & Deduplicate` Code node |
| Add more portals | Duplicate an HTTP Request node, parse in Code node |
| Export to Excel | Replace Google Sheets node with a `spreadsheetFile` node |
| Add cover letter | Inject OpenAI-generated cover letter in Auto Apply node |
| Notify on Slack | Add Slack node after `Email Daily Report` |

---

## 🐛 Troubleshooting

| Symptom | Cause | Fix |
|---|---|---|
| 0 jobs returned | Portal API changed | Inspect raw response in HTTP node; update URL params |
| Duplicate rows in sheet | jobId parsing differs | Add more dedup fields in Code node |
| Email not received | SMTP config | Test SMTP credentials separately |
| 403 from LinkedIn | Session expired | Re-authorise OAuth token |
| Sheet not updating | Wrong ID or tab name | Verify `GSHEETS_JOBS_ID` and sheet tab name |
