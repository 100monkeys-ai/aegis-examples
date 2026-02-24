# Email Summarizer Agent

Connects to Gmail and generates daily email summaries.

## Features

- Secure Gmail access via the `mcp:gmail` tool server
- AI-powered summarization (LLM routing handled by the orchestrator)
- Persistent memory for learning preferences (Cortex)

## Usage

```bash
aegis agent deploy ./agents/email-summarizer/agent.yaml
aegis execute --agent email-summarizer --input '{"criteria": "Summarize all unread emails from today"}' --watch
```

## Configuration

Set the following secrets in OpenBao (resolved by the orchestrator at runtime):

- `gmail-oauth`: Gmail OAuth2 credentials (injected into the `mcp:gmail` tool server)

## Permissions

- Network: `imap.gmail.com`, `smtp.gmail.com` (agent container only; LLM traffic goes through the orchestrator)
- Filesystem: Read `/data/inputs`, Write `/data/outputs`
- Resources: 512MB RAM, 300s execution time
