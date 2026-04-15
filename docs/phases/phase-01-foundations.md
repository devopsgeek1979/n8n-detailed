# Phase 1: Foundations (Core Concepts)

Welcome to n8n! In this phase, you'll learn how n8n thinks and how to build your first workflows.

**Time to complete:** 2-3 hours  
**Prerequisites:** None (but familiarity with JSON and APIs helps)

## What You'll Learn

- How n8n automates workflows and orchestrates systems
- The difference between event-driven and scheduled automation
- How data flows through nodes as JSON
- How to use triggers, actions, and conditional logic
- How to express dynamic values with `{{expressions}}`

## Core Concepts Explained

### n8n: Automation vs Orchestration

**Automation** = Performing repetitive tasks automatically
- Example: "Send an email every time a new customer signs up"

**Orchestration** = Coordinating multiple systems and workflows
- Example: "When customer signs up → Create Salesforce lead → Send welcome email → Update data warehouse → Slack notification"

n8n does both: you can automate simple tasks OR orchestrate complex, multi-system processes.

### Event-Driven vs Scheduled Workflows

**Event-Driven:** Triggered by external events (webhooks, API calls, message queues)
- Example: Customer submits a form → immediately process
- Pros: Real-time, low latency, event-reactive
- Use case: Chat bots, data ingestion, API integrations

**Scheduled (Cron):** Triggered on a fixed schedule
- Example: Every morning at 8 AM, fetch yesterday's sales data
- Pros: Predictable, bulk processing, batch jobs
- Use case: Daily reports, data syncing, cleanup tasks

### Nodes, Workflows, and Executions

**Node:** A single operation (e.g., "Fetch data from API," "Send email," "Transform JSON")

**Workflow:** A graph of connected nodes that work together

**Execution:** A single run-through of a workflow. Think: "I triggered the workflow once, and this is what happened."

### Triggers vs Actions

**Trigger Node:** Starts a workflow
- Types: Cron (schedule), Webhook (HTTP), Manual, Interval, etc.
- A workflow must have exactly ONE trigger

**Action Node:** Performs work within the workflow
- Types: HTTP Request, Send Email, Update Database, Transform, etc.
- A workflow can have many action nodes

### Data Flow: JSON Everywhere

n8n works with JSON. Every node receives JSON input and outputs JSON.

```
Trigger (Cron)
    ↓ outputs: {timestamp: "2025-04-15T10:00:00Z"}
[Set Node]
    ↓ outputs: {timestamp: "2025-04-15T10:00:00Z", greeting: "Good morning!"}
[Slack Node]
    ↓ sends to Slack
```

### Expressions and Variables

Dynamic values using `{{expression}}` syntax:

```
{{$json.field}}        # Access incoming JSON data
{{$json.user.name}}    # Nested JSON access
{{$now.toISOString()}} # Current timestamp
{{$json.count + 1}}    # Math operations
```

Example: You fetch a user from API, then send an email with:
```
Hello {{$json.firstName}}, welcome to our service!
```

### Authentication Basics

n8n supports multiple auth methods:

- **API Key:** Simple token-based (e.g., Authorization: Bearer YOUR_TOKEN)
- **OAuth2:** Delegated authentication (e.g., "Sign in with Google")
- **Basic Auth:** Username + password (HTTP Basic)
- **Custom Headers:** Any custom authentication scheme

You'll store credentials securely in n8n vault.

## Hands-on Labs

### Lab 1: Your First Scheduled Workflow (10 minutes)

**Goal:** Build a workflow that prints "Hello, World!" every 5 minutes

**Steps:**

1. Open n8n at http://localhost
2. Click "New Workflow"
3. Add a **Cron** trigger:
   - Trigger: Cron
   - Cron expression: `*/5 * * * *` (every 5 minutes)
4. Add a **Set** node:
   - Click the + button
   - Search for "Set"
   - Add a property: `message` = `Hello, World!`
5. Click **Activate** (top right)
6. Wait 5 minutes, check execution history (Executions tab)

**What you learned:**
- How to create and activate a workflow
- How Cron triggers work
- How to add data to a workflow

---

### Lab 2: Webhook-Triggered Data Ingestion (15 minutes)

**Goal:** Build a webhook that accepts JSON and logs it

**Setup:**

1. Create a new workflow
2. Replace Cron with **Webhook** trigger:
   - Click trigger, search for "Webhook"
   - Method: POST
   - Path: `/customer-signup`
3. Add a **Set** node:
   - Add a property: `received_at` = `{{$now.toISOString()}}`
4. Add a **Respond to Webhook** node (not mandatory, but good practice):
   - Status code: 200
   - Response body: `{status: "success"}`
5. Click **Activate**

**Testing the webhook:**

```bash
curl -X POST http://localhost/webhook/customer-signup \
  -H "Content-Type: application/json" \
  -d '{
    "name": "John Doe",
    "email": "john@example.com",
    "signup_time": "2025-04-15T10:00:00Z"
  }'
```

**What you learned:**
- How webhooks work
- How to receive external data
- How to use expressions like `{{$now.toISOString()}}`

---

### Lab 3: API → Transform → Output (20 minutes)

**Goal:** Fetch a public API, transform the data, send to Slack

**Setup:**

1. Create a new workflow, start with **Manual** trigger
2. Add an **HTTP Request** node:
   - Method: GET
   - URL: `https://api.github.com/users/torvalds` (Linus Torvalds' GitHub profile)
   - (No auth needed for public API)
3. Add a **Set** node (transform the data):
   - Add properties:
     - `name` = `{{$json.name}}`
     - `company` = `{{$json.company}}`
     - `public_repos` = `{{$json.public_repos}}`
4. Add a **Slack** node (or substitute with email/webhook):
   - Text: `GitHub User: {{$json.name}} ({{$json.public_repos}} public repos)`
5. Click Test Workflow (bottom left)

**What you learned:**
- How to fetch external APIs
- How to extract and transform JSON
- How to send data downstream to other services

**Challenge:** Modify the workflow to fetch multiple users in parallel

---

## Understanding Data Flow

Here's a complete example workflow with data transformations:

```
┌─────────────────────────────────────────────────────────┐
│ Webhook: POST /orders                                   │
│ Input: {orderId: 123, customerId: 456, amount: 100}   │
└────────────────┬────────────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────────────┐
│ HTTP Request: Fetch customer details from API          │
│ Output: {id: 456, name: "Alice", email: "..."}         │
└────────────────┬────────────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────────────┐
│ Set/Transform: Enrich the data                         │
│ {{$json}} + {timestamp, order_amount, user_name, ...} │
└────────────────┬────────────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────────────┐
│ Conditional: Is amount > $500?                          │
│ ├─ YES → Send to Slack (urgent)                        │
│ └─ NO → Log to database                                │
└─────────────────────────────────────────────────────────┘
```

## Common Expressions Cheat Sheet

| Expression | Example | Output |
| --- | --- | --- |
| Access JSON field | `{{$json.name}}` | "Alice" |
| Nested access | `{{$json.user.email}}` | "alice@ex.com" |
| Current timestamp | `{{$now.toISOString()}}` | "2025-04-15T10:..." |
| String interpolation | `"Hello {{$json.name}}"` | "Hello Alice" |
| Math | `{{$json.price * 1.1}}` | 110 (10% markup) |
| Array length | `{{$json.items.length}}` | 5 |
| Conditional ternary | `{{$json.status === 'paid' ? 'Confirmed' : 'Pending'}}` | "Confirmed" |
| Environment variable | `{{$env.DATABASE_URL}}` | Connection string |

## Quiz: Test Your Understanding

1. **What's the difference between a trigger and an action node?**
   - Answer: A trigger starts the workflow; actions are operations within it.

2. **How do you access nested JSON like `{user: {name: "Alice"}}`?**
   - Answer: `{{$json.user.name}}`

3. **When would you use Cron vs Webhook?**
   - Answer: Cron for scheduled tasks; Webhook for real-time event reactions.

4. **What does `{{$now.toISOString()}}` return?**
   - Answer: Current timestamp in ISO format (e.g., "2025-04-15T10:30:00Z")

## Success Criteria

Before moving to Phase 2, ensure you can:

✅ Create a workflow with a Cron trigger
✅ Create a workflow with a Webhook trigger
✅ Fetch data from a public API
✅ Transform JSON using expressions
✅ Test a workflow and view execution history
✅ Understand the flow of data between nodes
✅ Use variables like `{{$json.field}}` and `{{$now}}`

## Next Steps

Ready? Move on to **Phase 2: Installation & Environment Setup** to deploy n8n properly.

If you get stuck, check the [n8n Community](https://community.n8n.io/) or revisit this section.
