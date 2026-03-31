# Intent Result Formatter Agent

Converts raw execution stdout into a single natural language sentence.

This is the final step of the ADR-087 Intent-to-Execution pipeline. It receives
the user's original intent and the raw `stdout` from the code execution container,
then returns a concise, human-readable answer — no code, no markdown, just the
result stated plainly.

## Example

**Input:**

```json
{
  "intent": "sum two numbers and print the result",
  "stdout": "Result: 12"
}
```

**Output:**

```text
The sum of 5 and 7 is 12.
```

## Deploy and run

```bash
# Deploy the agent
aegis agent deploy ./agents/intent-result-formatter-agent/agent.yaml

# Run a standalone formatting task
aegis task execute intent-result-formatter-agent \
  --input '{"intent": "sum two numbers and print the result",
    "stdout": "Result: 12"}' \
  --follow
```

## Configuration

| Field | Value | Notes |
| --- | --- | --- |
| `max_iterations` | 1 | Executes once — no refinement loop |
| `execution.mode` | `one-shot` | Single pass, deterministic formatting |
| `timeout` | 30s | Formatting is fast; 30s is generous headroom |

## Integration

This agent is invoked automatically as the last stage of `builtin-intent-to-execution`.
It can also be used standalone to reformat any raw stdout into a natural language
sentence for display in the Zaru client.
