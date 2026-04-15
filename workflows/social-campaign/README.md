# 🤖 AI-Powered Social Campaign Creator

Send a campaign brief via webhook → GPT-4o writes platform-optimised copy → posts simultaneously to **Twitter/X**, **LinkedIn**, and **Facebook** → logs every campaign to **Google Sheets**.

---

## 📐 Architecture

```
POST /webhook/social-campaign
           │
           ▼
     Validate Brief
           │
           ▼
  OpenAI: Generate Posts (GPT-4o)
           │
           ▼
     Parse AI Output
           │
     ┌─────┼─────┐
     ▼     ▼     ▼
Twitter LinkedIn Facebook
     │     │     │
     └──── Merge ────┘
                │
          Build Log Row
                │
        Log to Google Sheets
                │
          Respond: Success
```

---

## ⚙️ Environment Variables

| Variable | Required | Description |
|---|---|---|
| `TWITTER_BEARER_TOKEN` | ✅ | Twitter API v2 bearer token |
| `LINKEDIN_ACCESS_TOKEN` | ✅ | LinkedIn OAuth access token |
| `LINKEDIN_AUTHOR_ID` | ✅ | LinkedIn person/organization URN (without `urn:li:person:`) |
| `FACEBOOK_PAGE_ID` | ✅ | Facebook Page ID |
| `FACEBOOK_PAGE_ACCESS_TOKEN` | ✅ | Facebook Page access token |
| `GSHEETS_CAMPAIGNS_ID` | ✅ | Google Sheets spreadsheet ID (from the URL) |

---

## 🔑 Credentials Setup

### 1 · `openai-campaigns` (OpenAI API)

1. Go to [platform.openai.com/api-keys](https://platform.openai.com/api-keys)
2. Create a new secret key
3. In n8n: **Credentials → New → OpenAI API**

| Field | Value |
|---|---|
| Name | `openai-campaigns` |
| API Key | `sk-...` |

---

### 2 · `twitter-brand` (HTTP Header Auth)

1. Create a Twitter Developer App at [developer.twitter.com](https://developer.twitter.com)
2. Enable **OAuth 2.0** and request `tweet.write` scope
3. Generate a Bearer Token with write permissions (User Context token — OAuth 2.0 PKCE)
4. In n8n: **Credentials → New → HTTP Header Auth**

| Field | Value |
|---|---|
| Name | `twitter-brand` |
| Header Name | `Authorization` |
| Header Value | `Bearer <your-token>` |

---

### 3 · `linkedin-brand` (HTTP Header Auth)

1. Create a LinkedIn App at [developer.linkedin.com](https://developer.linkedin.com)
2. Request `ugcPost` + `w_member_social` permissions
3. Complete OAuth 2.0 flow to obtain access token
4. In n8n: **Credentials → New → HTTP Header Auth**

| Field | Value |
|---|---|
| Name | `linkedin-brand` |
| Header Name | `Authorization` |
| Header Value | `Bearer <your-token>` |

---

### 4 · `facebook-brand` (HTTP Header Auth)

1. Create a Facebook App at [developers.facebook.com](https://developers.facebook.com)
2. Add the **Pages API** product
3. Generate a long-lived Page Access Token
4. In n8n: **Credentials → New → HTTP Header Auth** (or pass token via env var directly)

| Field | Value |
|---|---|
| Name | `facebook-brand` |
| Header Name | `Content-Type` |
| Header Value | `application/json` |

> ⚠️ The Facebook access token is passed via `$env.FACEBOOK_PAGE_ACCESS_TOKEN` in the request body for this workflow.

---

### 5 · `gsheets-campaigns` (Google Sheets OAuth2)

1. In n8n: **Credentials → New → Google Sheets OAuth2 API**
2. Follow the OAuth flow to authorise your Google account
3. Name it `gsheets-campaigns`
4. Create a Google Sheet named **Campaign Log** with these headers in row 1:

```
Timestamp | Brand | Brief Summary | Tone | Twitter Post ID | Twitter Text | LinkedIn Post ID | LinkedIn Text | Facebook Post ID | Facebook Text | Status
```

---

## 📥 Import into n8n

1. **Workflows → Import from File** → select `workflow.json`
2. Update all credentials
3. Set all environment variables
4. Activate the workflow (the webhook URL will be shown on the Webhook node)
5. Copy the webhook URL

---

## 🚀 Usage — Trigger a Campaign

Send a `POST` request to the webhook URL:

```bash
curl -X POST https://your-n8n.com/webhook/social-campaign \
  -H "Content-Type: application/json" \
  -d '{
    "brand": "TechNova",
    "brief": "We are launching TechNova AI Assistant — the first fully offline AI for enterprise. It runs on-prem with no data leaving your network.",
    "tone": "exciting",
    "hashtags": "AI enterprise privacy",
    "cta": "Book a demo at technova.ai/demo"
  }'
```

### Request Schema

| Field | Type | Required | Description |
|---|---|---|---|
| `brand` | string | ✅ | Brand or product name |
| `brief` | string | ✅ | Campaign description (1-3 sentences) |
| `tone` | string | ☑️ | Tone: `professional`, `casual`, `exciting`, `empathetic` |
| `hashtags` | string | ☑️ | Space-separated hashtag words (without `#`) |
| `cta` | string | ☑️ | Call to action text |

---

## 📊 Google Sheets Log

Each run appends a row to the **Campaign Log** sheet:

| Column | Description |
|---|---|
| Timestamp | ISO8601 execution time |
| Brand | Brand name from request |
| Brief Summary | First 100 chars of brief |
| Tone | Tone used |
| Twitter Post ID | Tweet ID from Twitter API |
| Twitter Text | Tweet content |
| LinkedIn Post ID | LinkedIn UGC post ID |
| LinkedIn Text | First 120 chars |
| Facebook Post ID | Facebook post ID |
| Facebook Text | First 120 chars |
| Status | Always `PUBLISHED` on success |

---

## 🔧 Customisation

| Goal | Change |
|---|---|
| Add Instagram | Add HTTP Request node to `graph.facebook.com/{ig-user-id}/media` |
| Schedule campaigns | Replace Webhook trigger with Schedule trigger |
| Multi-language posts | Add language field to brief, update OpenAI prompt |
| Image generation | Add DALL-E node before social posting nodes |
| Slack notification | Add Slack node after `Build Log Row` |
| Error handling | Add Error Trigger workflow to catch failures |

---

## 🐛 Troubleshooting

| Symptom | Cause | Fix |
|---|---|---|
| `Missing required fields` error | Request body missing `brand` or `brief` | Check JSON body in request |
| `Failed to parse OpenAI JSON` | GPT returned unexpected format | Retry; raise `temperature` slightly |
| `401` on Twitter | Token expired or wrong scope | Regenerate with `tweet.write` scope |
| `403` on LinkedIn | Missing `ugcPost` permission | Re-authorise LinkedIn app |
| `190` error from Facebook | Expired page token | Refresh long-lived token |
| Sheet not updating | Wrong sheet ID or name | Verify `GSHEETS_CAMPAIGNS_ID` and sheet tab name |
