# Phase 4: Workflow Development (Core Engineering)

This is where you build real-world automation. Master workflows that power businesses.

**Time to complete:** 4-5 hours  
**Prerequisites:** Phases 1-3 complete, n8n running locally

## What You'll Learn

- ETL (Extract, Transform, Load) patterns
- Conditional logic and branching
- Looping and batch processing
- Error handling and fallback strategies
- Retries and exponential backoff
- Workflow composition and sub-workflows
- Performance optimization

## Core Concepts

### ETL Workflow Pattern

**Extract:** Fetch data from a source (API, database, file)  
**Transform:** Modify, enrich, normalize the data  
**Load:** Send to destination (database, file, service)

```
Extract (HTTP Request)
    ↓ raw data
Transform (Set / Code node)
    ↓ normalized data
Load (PostgreSQL / Slack / Webhook)
    ↓ success/failure
```

### Conditional Logic (IF / Switch)

**IF node:** Branch on a boolean condition

```
IF (amount > 1000)
  ├─ YES → Send approval request to manager
  └─ NO  → Auto-approve
```

**Switch node:** Branch on multiple conditions

```
SWITCH (status)
  ├─ "pending"   → Send reminder email
  ├─ "approved"  → Update database
  ├─ "rejected"  → Notify requester
  └─ default     → Log error
```

### Looping & Batch Processing

**Loop:** Process items one-by-one

```
Split In Batches → Loop
  [Item 1] → Fetch details → Update DB
  [Item 2] → Fetch details → Update DB
  [Item 3] → Fetch details → Update DB
```

**Batch:** Process multiple items in parallel

```
HTTP Request (fetch 100 users)
  ↓
Split In Batches (10 items per batch)
  ↓
[Batch 1] [Batch 2] [Batch 3] [Batch 4] (parallel)
  ↓ (merge)
All processed
```

### Error Handling

**Default behavior:** If a node fails, the entire workflow fails.

**Better:** Design for resilience.

```
Try
  → HTTP Request (external API)
Catch
  → Log error
  → Send Slack alert
  → Mark as retry-able
Finally
  → Update database with status
```

### Retry Strategies

**Exponential Backoff:** Wait longer between retries

```
Attempt 1: Immediate
Attempt 2: Wait 2 seconds
Attempt 3: Wait 4 seconds
Attempt 4: Wait 8 seconds
Attempt 5: Fail permanently
```

## Hands-on: Build 3 Real Workflows

### Lab 1: ETL - User Data Pipeline (40 minutes)

**Scenario:** Fetch users from a public API, transform, load to Slack

**Workflow:**

```
[Webhook Trigger: POST /import-users]
  ↓
[HTTP Request: Fetch https://jsonplaceholder.typicode.com/users]
  ↓
[Set/Transform: Normalize fields]
  - Extract: name, email, company
  - Add timestamp
  ↓
[Loop: For each user]
  → [Set: Format for Slack]
  → [Slack: Send message]
  ↓
[Respond to Webhook: {status: "success", count: 10}]
```

**Step-by-step:**

1. Create new workflow, start with **Webhook**
2. Add **HTTP Request** node:
   - URL: `https://jsonplaceholder.typicode.com/users`
   - Method: GET
3. Add **Set** node:
   - Mode: "Specify all"
   - Add fields: `name`, `email`, `company`
4. Add **Item Lists** → **Split In Batches** (for loop):
   - Batch size: 5 (process 5 users at a time)
5. Inside loop, add **Slack** node:
   - Message: `New user: {{$json.name}} ({{$json.email}})`
6. Click Test Workflow

**Success criteria:** Slack receives 10 messages (one per user)

---

### Lab 2: API Aggregator - Multi-Source Health Check (30 minutes)

**Scenario:** Monitor 3 services in parallel, send alert if any fail

**Workflow:**

```
[Cron Trigger: Every 5 minutes]
  ↓
[Parallel Requests]
  → HTTP: Service A
  → HTTP: Service B
  → HTTP: Service C
  ↓
[Merge Results]
  ↓
[Conditional: Any failed?]
  ├─ YES → [Slack: Alert ops]
  └─ NO  → [Slack: All healthy]
```

**Step-by-step:**

1. New workflow, **Cron** trigger: `*/5 * * * *`
2. Add 3 **HTTP Request** nodes (parallel):
   ```
   Service A: https://httpbin.org/status/200
   Service B: https://httpbin.org/status/200
   Service C: https://httpbin.org/status/500 (will fail)
   ```
3. Add **Merge** node to consolidate results
4. Add **IF** node:
   - Condition: Any service returned error status
5. Add **Slack** node (true branch):
   - `Alert: Service C is down!`
6. Test

**Key concept:** Using parallel nodes for concurrent API calls

---

### Lab 3: Intelligent Alert System with Retries (50 minutes)

**Scenario:** Webhook receives alert data → enrich → send to Slack with retry logic

**Workflow:**

```
[Webhook Trigger]
  ↓
[Fetch Alert Details via API]
  (with retry logic)
  ↓
[Conditional: Priority level]
  ├─ HIGH → [Send to @channel] + [Create Jira ticket]
  ├─ MED  → [Send to #alerts]
  └─ LOW  → [Log only]
  ↓
[Respond to Webhook]
```

**Step-by-step:**

1. New workflow, **Webhook** trigger
2. Add **HTTP Request** node:
   - URL: `https://api.example.com/alerts/{{$json.alert_id}}`
   - Add error handling: Enable "Continue on fail"
3. Add **IF** node after HTTP:
   - Condition: HTTP request succeeded?
   - No: Add **Wait** node (2 seconds) → Loop back to HTTP (retry)
   - Yes: Continue
4. Add **Switch** node:
   - Input: `$json.priority`
   - Cases: "HIGH", "MEDIUM", "LOW"
5. For each case, add **Slack** node with different messages
6. Test with different priority values

**Key concepts:** 
- Continue on failure (graceful error handling)
- Retry loops
- Conditional branching
- Different downstream actions

## Workflow Best Practices

1. **Keep workflows focused:** One workflow = one business process
2. **Use descriptive names:** Not "Workflow 1", but "Customer Sign-up ETL"
3. **Add comments:** Document complex logic
4. **Test edge cases:** What if API returns empty array? What if field is null?
5. **Error handling:** Don't ignore failures
6. **Performance:** Use Split In Batches for large datasets (avoid timeouts)
7. **Logging:** Use Set node to log key values for debugging

## Common Pitfalls & Solutions

| Problem | Solution |
| --- | --- |
| Workflow times out | Use Split In Batches for large datasets |
| API rate limits | Add Wait node between requests |
| Missing fields cause errors | Use conditional: `if ($json.field !== null)` |
| Credentials expired | Set up token refresh logic |
| Data lost on failure | Log to database before processing |

## Success Criteria

✅ Build an ETL workflow with 3+ nodes  
✅ Use conditional branching (IF/Switch)  
✅ Implement error handling  
✅ Process multiple items in a loop  
✅ Test with real APIs  

## Next Steps

Excellent! You now understand workflow architecture. Move to **Phase 5: Advanced Integrations** to work with complex APIs, file processing, and pagination.
