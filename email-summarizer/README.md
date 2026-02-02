# Email Summarizer Agent

Connects to Gmail and generates daily email summaries using GPT-4.

## Features

- Secure Gmail access via MCP
- AI-powered summarization
- Persistent memory for learning preferences

## Usage

```bash
aegis run agent.yaml
```

## Configuration

Set the following secrets in your AEGIS dashboard:

- `openai-key`: Your OpenAI API key
- `gmail-oauth`: Gmail OAuth2 credentials

## Permissions

- Network: `api.openai.com`, `imap.gmail.com`
- Filesystem: Read `/data/inputs`, Write `/data/outputs`
- Resources: 512MB RAM, 300s execution time
