# Security Hardening Checklist

## Identity and Access

- [ ] Enable n8n user management
- [ ] Restrict admin access by IP or VPN
- [ ] Use strong passwords and SSO where available

## Secrets and Encryption

- [ ] Set strong `N8N_ENCRYPTION_KEY`
- [ ] Store secrets in vault/secret manager
- [ ] Do not commit `.env` with sensitive values

## Network and Webhooks

- [ ] Force HTTPS
- [ ] Add webhook authentication/signature validation
- [ ] Apply WAF/rate-limits for public endpoints

## Runtime Security

- [ ] Keep n8n image updated
- [ ] Limit container privileges
- [ ] Scan images for vulnerabilities

## Monitoring and Audit

- [ ] Centralize logs
- [ ] Alert on failed executions and auth anomalies
- [ ] Keep incident response runbooks updated
