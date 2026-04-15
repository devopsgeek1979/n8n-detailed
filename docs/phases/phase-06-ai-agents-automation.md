# Phase 6: AI Agents & Automation Systems

This is where automation becomes intelligent. Build agents powered by LLMs that make decisions and take actions.

**Time to complete:** 4 hours  
**Prerequisites:** Phases 1-5 complete, OpenAI API key (or similar LLM provider)

## What You'll Learn

- How AI agents work: perception → reasoning → action
- Integrating OpenAI, Claude, or local LLMs
- Prompt engineering for n8n workflows
- Stateful vs stateless agent patterns
- Memory handling and context management
- Function calling (tool usage) in agents
- Building production-grade agents with guardrails

## Core Concepts

### What is an AI Agent?

An agent is a loop:

```
┌─────────────────────────────────────────┐
│ 1. Perception                           │
│    ↓ Observe state (user message, data) │
├─────────────────────────────────────────┤
│ 2. Reasoning                            │
│    ↓ Call LLM with prompt & context     │
├─────────────────────────────────────────┤
│ 3. Action                               │
│    ↓ Execute decision (API call, etc)   │
├─────────────────────────────────────────┤
│ 4. Observation                          │
│    ↓ See result of action               │
│    Loop → back to 1                     │
└─────────────────────────────────────────┘
```

### LLM Integration in n8n

n8n has built-in nodes for OpenAI, Anthropic, HuggingFace, and local models.

**Basic flow:**

```
[Webhook: User input]
  ↓
[Set: Build prompt]
  Message: "Analyze this: {{$json.text}}"
  ↓
[OpenAI: Call GPT-4]
  Prompt: "{{$json.message}}"
  Temperature: 0.7
  ↓
[Parse: Extract response]
  ↓
[Action: Based on response]
  ├─ Category: "bug" → Create Jira ticket
  ├─ Category: "feature" → Add to product board
  └─ Category: "question" → Reply in email
```

### Prompt Engineering for Workflows

Writing effective prompts is an art and science.

**Good prompt structure:**

```
You are a customer support agent for [Company].

Your role:
- Analyze support tickets
- Categorize by priority (high/medium/low)
- Suggest a response

Respond in JSON format:
{
  "category": "string",
  "priority": "high|medium|low",
  "suggested_response": "string",
  "confidence": 0.0-1.0
}

Ticket: {{$json.ticket_text}}
```

**Key principles:**

1. **Role/Context:** "You are a..."
2. **Task:** Clear instruction
3. **Format:** Specify output format (JSON, CSV, etc.)
4. **Examples:** Few-shot learning (give examples)
5. **Constraints:** What NOT to do
6. **System role:** Use system vs user messages correctly

### Stateful vs Stateless

**Stateless Agent:**
- No memory between requests
- Fast, simple, good for one-off tasks
- Example: "Classify this email"

```
[Webhook] → [LLM] → [Action]
(no context carried forward)
```

**Stateful Agent:**
- Remembers previous interactions
- Can have conversations
- Good for chatbots, multi-turn interactions
- More complex, requires memory storage

```
[Webhook] → [Fetch memory] → [LLM with context] → [Action] → [Store memory]
```

### Memory Handling

**Types of memory:**

1. **Conversation history:** Past messages in a chat
2. **User context:** Who is the user, preferences
3. **Session state:** Current task progress
4. **Knowledge base:** Persistent facts

**Implementation patterns:**

```
[Webhook: User message]
  ↓
[PostgreSQL: Fetch last 5 messages]
  ↓
[Set: Format conversation history]
  messages: [
    {role: "assistant", content: "Hello!"},
    {role: "user", content: "What's my balance?"}
  ]
  ↓
[OpenAI: Call with conversation history]
  ↓
[PostgreSQL: Store new message]
  ↓
[Webhook: Return response]
```

### Function Calling (Tool Usage)

Tell the LLM what tools it can use. The LLM decides when to use them.

**Example tools:**

```json
{
  "name": "fetch_user_balance",
  "description": "Get account balance for a user",
  "parameters": {
    "user_id": "string"
  }
}
```

**Flow:**

```
User: "What's my balance?"
  ↓
LLM: "I need to fetch the balance. Using tool: fetch_user_balance({user_id: '123'})"
  ↓
n8n: Call the tool (HTTP Request to API)
  ↓
LLM: "Your balance is $500"
  ↓
User: Sees response
```

## Hands-on: Build 3 AI Agents

### Lab 1: Simple Content Classifier (20 minutes)

**Goal:** An agent that reads text and classifies it

**Workflow:**

```
[Webhook: POST /classify with {text: "..."}]
  ↓
[Set: Build prompt]
  ↓
[OpenAI: Call GPT-4]
  ↓
[Set: Parse response]
  ↓
[Respond to Webhook: {category, confidence}]
```

**Setup:**

1. Create new workflow, **Webhook** trigger
2. Add **Set** node:
   ```
   prompt = "Classify this text as: happy, neutral, or angry. Text: {{$json.text}}"
   ```
3. Add **OpenAI** node:
   - Model: gpt-4 or gpt-3.5-turbo
   - Temperature: 0.2 (low = deterministic)
   - Prompt: `{{$json.prompt}}`
4. Add **Set** node:
   ```
   response = {{$json.text}}
   category = extract first word (happy/neutral/angry)
   ```
5. Add **Respond to Webhook** node

**Test:**

```bash
curl -X POST http://localhost/webhook/classify \
  -H "Content-Type: application/json" \
  -d '{"text": "I love this product!"}'
```

---

### Lab 2: Customer Support Ticket Triage (40 minutes)

**Goal:** Triage support tickets by priority and route to right team

**Workflow:**

```
[Webhook: New Jira ticket]
  ↓
[Set: Extract ticket details]
  ↓
[OpenAI: Analyze ticket]
  - Priority: high/medium/low
  - Category: bug/feature/question
  - Suggested assignment: Team A/B/C
  ↓
[Conditional: Priority level]
  ├─ HIGH → [Slack: Alert on-call engineer]
  ├─ MEDIUM → [Slack: Notify team lead]
  └─ LOW → [Slack: Post to #backlog]
  ↓
[Jira: Update ticket with priority & assignee]
```

**Setup:**

1. Create workflow, **Webhook** trigger
2. Add **Set** node (build prompt):
   ```
   You are a support triage agent.
   Analyze this support ticket and respond in JSON:
   
   {
     "priority": "high|medium|low",
     "category": "bug|feature|question",
     "team": "backend|frontend|devops",
     "confidence": 0.0-1.0,
     "reasoning": "brief explanation"
   }
   
   Ticket:
   Title: {{$json.title}}
   Description: {{$json.description}}
   ```
3. Add **OpenAI** node (call LLM)
4. Add **IF** node → check priority
5. Add **Slack** nodes for each branch
6. Add **Jira** node to update ticket

**Test with a sample ticket:**

```json
{
  "title": "Login button broken on mobile",
  "description": "Users cannot log in from iPhone Safari. 500 error on submit."
}
```

---

### Lab 3: DevOps Alert Analyzer with Memory (60 minutes)

**Goal:** Agent that analyzes monitoring alerts, remembers context, and takes actions

**Workflow:**

```
[Webhook: Alert from monitoring system]
  ↓
[PostgreSQL: Fetch last 10 alerts for this metric]
  ↓
[Set: Format conversation history]
  ↓
[OpenAI: Analyze with context]
  - Is this a new issue or a repeat?
  - Suggest remediation
  - Set urgency
  ↓
[Conditional: Urgency]
  ├─ CRITICAL → [Page on-call]
  ├─ HIGH → [Slack alert + create incident]
  └─ LOW → [Log for analysis]
  ↓
[PostgreSQL: Store this alert + resolution]
  ↓
[Webhook: Return status]
```

**Setup:**

1. New workflow, **Webhook** trigger
2. Add **PostgreSQL** node (fetch alert history):
   ```sql
   SELECT timestamp, metric, value, action_taken
   FROM alerts
   WHERE metric = '{{$json.metric}}'
   ORDER BY timestamp DESC
   LIMIT 10
   ```
3. Add **Set** node (build context for LLM):
   ```
   context = "Previous alerts: {{$json[0]}}"
   current_alert = "Metric: {{$json.metric}}, Value: {{$json.value}}"
   ```
4. Add **OpenAI** node:
   ```
   You are a DevOps incident responder.
   
   Context (previous incidents):
   {{$json.context}}
   
   Current Alert:
   {{$json.current_alert}}
   
   Provide in JSON:
   {
     "is_repeat": boolean,
     "urgency": "critical|high|medium|low",
     "probable_cause": "string",
     "suggested_action": "string"
   }
   ```
5. Add **IF** node to branch on urgency
6. Add **Slack** for urgent alerts
7. Add **PostgreSQL** to store the incident

**Key concepts:**
- Maintaining state (alert history)
- Context-aware decision making
- Escalation logic

## Production Guardrails

For production agents, add safety checks:

```
[LLM Decision]
  ↓
[Conditional: Is decision within policy?]
  ├─ YES → Execute
  ├─ NO → [Slack: Alert human]
        → [Wait for approval]
        → Execute only after approval
```

**Examples of guardrails:**
- Don't delete anything without approval
- Don't change production config without review
- Escalate high-stakes decisions to humans
- Log all agent actions for audit

## Success Criteria

✅ Call OpenAI/LLM from n8n  
✅ Build a prompt that produces structured output  
✅ Route decisions based on LLM response  
✅ Implement memory/state (optional)  
✅ Add safety guardrails for critical actions  

## Next Steps

You're now building intelligent automation! Move to **Phase 7: Administration & Operations** to learn how to scale and monitor these agents.
