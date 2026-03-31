# Intent Executor Discovery Agent

Resolves a natural language intent and target language into a deployable
code-writing agent by querying the ADR-075 Discovery Service.

## What it does

1. Calls `aegis.agent.search` with the intent and language as query terms
2. Reuses an existing agent if `similarity_score >= 0.85`
3. Calls `aegis.agent.generate` to produce a new agent only when no match meets
   the threshold

This is Step 1 of the ADR-087 Intent-to-Execution pipeline, executed as part of
the `builtin-intent-to-execution` workflow.

## Output

Returns a JSON object:

```json
{
  "agent_name": "python-sum-agent",
  "created": false
}
```

| Field | Type | Description |
| --- | --- | --- |
| `agent_name` | string | Name of the agent to invoke for code generation |
| `created` | boolean | `true` if a new agent was generated, `false` if reused |

## Deploy and run

```bash
# Deploy the agent
aegis agent deploy ./agents/intent-executor-discovery-agent/agent.yaml

# Run a standalone discovery task
aegis task execute intent-executor-discovery-agent \
  --input '{"intent": "sum two numbers and print the result",
    "language": "python"}' \
  --follow
```

## Configuration

| Field | Value | Notes |
| --- | --- | --- |
| `max_iterations` | 3 | Retries if JSON schema validation fails |
| `execution.mode` | `one-shot` | No refinement loop |
| `timeout` | 60s | Search + optional generation completes well within this |

## Tools

| Tool | Purpose |
| --- | --- |
| `mcp:aegis.agent.search` | Queries the ADR-075 Discovery Service |
| `mcp:aegis.agent.generate` | Generates a new agent when no match is found |
