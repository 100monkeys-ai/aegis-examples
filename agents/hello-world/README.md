# Hello World Agent

The introductory AEGIS agent. Writes a Python function, tests it, and iteratively refines it until all tests pass.

This is the agent used in the [Getting Started guide](https://docs.aegis.ai/docs/getting-started).

## What it demonstrates

- The **100monkeys iterative refinement loop** — the agent writes code, runs tests, and if they fail the AEGIS runtime applies LLM-driven refinement and tries again
- **Tool usage** — `fs.write` (write files), `cmd.run` (execute commands), `fs.read` (read output)
- **Gradient validation** — a semantic judge scores the output (0.0–1.0) instead of a binary pass/fail

## Deploy and run

```bash
# Prerequisites: AEGIS binary installed, local stack running (see deploy/)

# Deploy the agent
aegis agent deploy ./agents/hello-world/agent.yaml

# Run an execution
aegis task execute \
  hello-world \
  --input '{"task": "Write a Python function that returns the Fibonacci sequence up to n."}' \
  --follow
```

Expected output:

```markdown
[Execution ...] Started
[Iteration 1] Running...
[Iteration 1] Tool call: fs.write /workspace/solution.py
[Iteration 1] Tool call: fs.write /workspace/test_solution.py
[Iteration 1] Tool call: cmd.run python /workspace/test_solution.py
[Iteration 1] Validation: score=0.92 confidence=0.88 → Success
[Execution ...] Completed in 1 iteration (12.4s)
```

## Configuration

See `agent.yaml` for the full manifest. Key settings:

| Field | Value | Notes |
| --- | --- | --- |
| `max_iterations` | 5 | Refinement attempts before giving up |
| `validation.threshold` | 0.85 | Minimum score to consider the task complete |
| `memory` | false | Cortex memory disabled for simplicity |
| `timeout` | 120s | Per-execution wall-clock limit |

## What's next

- [Writing Your First Agent](https://docs.aegis.ai/docs/guides/writing-agents) — build a custom agent from scratch
- [The Execution Loop](https://docs.aegis.ai/docs/concepts/execution) — understand how iterations and refinement work
- [Agent Manifest Reference](https://docs.aegis.ai/docs/reference/agent-manifest) — every field explained
