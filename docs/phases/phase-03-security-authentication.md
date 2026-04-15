# Phase 3: Security & Authentication

Security is non-negotiable in production. This phase teaches you how to secure n8n for enterprise use.

**Time to complete:** 2 hours  
**Prerequisites:** Phase 2 (Docker Compose setup)

## What You'll Learn

- The role of `N8N_ENCRYPTION_KEY` and secrets management
- How credentials are stored and encrypted
- OAuth2 setup and workflows
- Webhook security: HMAC signatures, IP allowlists
- User management and access control
- Network hardening patterns

## Core Security Concepts

### Encryption Key (N8N_ENCRYPTION_KEY)

This is THE most critical security control.

**What it does:** Encrypts all credentials in n8n's database

**Why it matters:** Without this key, all your API tokens, passwords, and secrets are stored unencrypted

**How to generate:**

```bash
openssl rand -base64 32
# Output: abc123xyz...== (copy this value)

# Then set as environment variable
export N8N_ENCRYPTION_KEY='abc123xyz...=='
```

**Important:** 
- Keep this secret (like a database password)
- Store it in your secret manager (Vault, Kubernetes Secrets, etc.)
- Never commit to Git
- Losing it = losing access to all credentials (catastrophic!)

**Rotation:** Changing the key is complex and requires re-encrypting all credentials. Plan carefully before changing.

### Credential Storage & Vault

When you connect an API (e.g., Slack, GitHub, Salesforce), n8n:

1. Encrypts your credentials using `N8N_ENCRYPTION_KEY`
2. Stores them in the database (encrypted)
3. Decrypts only when needed, in memory
4. Never logs or exposes credentials

**Credentials are tied to the user who created them.** Other users can't see the plaintext value.

**Best practices:**
- Use separate credentials for dev/staging/prod
- Rotate API keys regularly
- Audit which workflows use which credentials
- Delete unused credentials

### OAuth2 Integration

n8n supports OAuth2 for services like Google, GitHub, Slack, etc.

**Flow:**
1. User clicks "Authenticate with Google"
2. Redirected to Google login
3. User grants permission to n8n
4. Google sends access token to n8n
5. n8n encrypts and stores the token
6. Workflows use the token to act on behalf of the user

**Advantages:**
- User never shares password with n8n
- Revocable permissions (user can revoke in Google settings)
- Time-limited tokens (auto-refresh)

**Setup Example: Google OAuth**

In n8n UI:
1. Go to Credentials
2. Create new credential: "Google" type
3. Click "Link Google account"
4. Approve permissions
5. n8n receives and encrypts token

**Important:** For Gmail, Google Drive, etc., you'll need a Google OAuth app (Developer Console).

### Webhook Security

Webhooks are public endpoints that external services call. Secure them!

**Risk:** Malicious actor sends fake webhook request

**Defense 1: HMAC Signature Validation**

External service (e.g., GitHub) signs the request with a secret key.

```
Header: X-Hub-Signature-256: sha256=abc123...
```

n8n verifies the signature matches. If it doesn't, reject the request.

**In n8n, enable webhook authentication:**
```
Webhook trigger → "Authentication" → "HMAC-SHA256"
```

Copy the webhook signing secret to GitHub/service settings.

**Defense 2: IP Allowlist**

Only accept webhook requests from known IPs.

Example: Only GitHub's webhook servers can call your webhook.

```
Webhook trigger → Advanced settings → "IP Range" → "140.82.112.0/20"
```

**Defense 3: Custom Headers**

Require a custom header (like an API key) in every request:

```bash
# External service must send:
curl -X POST https://n8n.example.com/webhook/github \
  -H "X-Custom-Token: secret123" \
  -d '{...payload...}'
```

In n8n:
```
Webhook trigger → "Authentication" → "Header Auth"
Set required header: "X-Custom-Token"
```

### User Management & Access Control

For teams, control who can access what.

**Types of users:**

1. **Admin:** Full access, can modify settings, credentials, users
2. **Editor:** Can create and edit workflows, use shared credentials
3. **Member:** View-only or limited workflows

**Best practice:**
- Create specific credentials for each workflow (not shared admin creds)
- Use least privilege: editors don't need admin access
- Audit user access regularly
- Disable inactive accounts

### Environment-Based Security

Use different credentials for dev, staging, and production:

```
Dev: 
  - Testing APIs with read-only access
  - Slack channel: #dev-notifications

Staging:
  - Pre-prod APIs with limited quotas
  - Slack channel: #staging-notifications

Prod:
  - Real APIs with full access
  - Slack channel: #prod-alerts + ops team
```

Store different credential sets in n8n (tagged by environment).

## Hands-on Labs

### Lab 1: Generate & Set Encryption Key

**Goal:** Create a strong encryption key and restart n8n with it

```bash
# Generate key
NEW_KEY=$(openssl rand -base64 32)
echo "Your encryption key: $NEW_KEY"

# Update .env
echo "N8N_ENCRYPTION_KEY=$NEW_KEY" >> .env

# Restart n8n
docker compose restart n8n

# Verify
docker logs n8n | grep -i encrypt
```

### Lab 2: Set Up OAuth2 (Google)

**Prerequisites:** Google Developer Account

**Steps:**

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project
3. Enable "Gmail API" and "Google Drive API"
4. Create OAuth 2.0 credentials (type: Web application)
   - Authorized redirect URL: `https://n8n.example.com/rest/oauth2/callback`
5. Copy Client ID and Client Secret
6. In n8n: Create new credential → Google → Paste credentials
7. Authorize and test

### Lab 3: Secure a Webhook with HMAC

**Goal:** Create a webhook that validates request signatures

**Steps:**

1. Create a new workflow with **Webhook** trigger
2. Enable "Authentication" → "HMAC-SHA256"
3. Copy the "Webhook Signing Secret"
4. Send a test request:

```bash
WEBHOOK_URL='https://n8n.example.com/webhook/test'
SECRET='your-signing-secret'
PAYLOAD='{"message":"hello"}'
SIGNATURE=$(echo -n "$PAYLOAD" | openssl dgst -sha256 -hmac "$SECRET" -hex | cut -d' ' -f2)

curl -X POST "$WEBHOOK_URL" \
  -H "X-Hub-Signature-256: sha256=$SIGNATURE" \
  -H "Content-Type: application/json" \
  -d "$PAYLOAD"
```

## Security Checklist

Before going to production:

- [ ] `N8N_ENCRYPTION_KEY` is set and strong
- [ ] Credentials are stored in n8n vault, not hardcoded
- [ ] Webhooks use HMAC signature validation
- [ ] Admin password is strong and unique
- [ ] User access is least-privilege
- [ ] Reverse proxy forces HTTPS
- [ ] Firewall restricts inbound access
- [ ] Audit logs are enabled and monitored
- [ ] Backup includes encryption key separately
- [ ] Incident response plan documented

## Success Criteria

✅ Understand encryption key importance  
✅ Create and manage OAuth2 credentials  
✅ Secure webhooks with HMAC signatures  
✅ Set up basic user access control  
✅ Know credential storage model

## Next Steps

You now have a secure n8n instance! Move to **Phase 4: Workflow Development** to build real automation.
