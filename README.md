# AEGIS Examples

Example agents demonstrating the capabilities of the AEGIS runtime.

[![License](https://img.shields.io/badge/license-BSL%201.1-blue.svg)](LICENSE)

## Overview

This repository contains ready-to-run example agents that showcase:

- MCP tool integration
- Security policy configuration
- Memory system (Cortex) usage
- Best practices for agent development

## Examples

### 1. Email Summarizer

**Location**: [`email-summarizer/`](email-summarizer/)

Connects to Gmail and generates AI-powered email summaries.

**Features**:

- Gmail MCP integration
- OpenAI GPT-4 summarization
- Persistent memory for learning user preferences

**Run**:

```bash
aegis run email-summarizer/agent.yaml
```

### 2. Web Researcher

**Location**: [`web-researcher/`](web-researcher/)

Performs deep research on any topic by searching, reading, and synthesizing information.

**Features**:

- Web search via MCP
- Multi-source article reading
- Comprehensive report generation

**Run**:

```bash
aegis run web-researcher/agent.yaml
```

### 3. Code Reviewer

**Location**: [`code-reviewer/`](code-reviewer/)

Reviews pull requests for security issues, code quality, and best practices.

**Features**:

- GitHub MCP integration
- Security vulnerability detection
- Best practice recommendations

**Run**:

```bash
aegis run code-reviewer/agent.yaml
```

## Getting Started

### Prerequisites

- AEGIS CLI installed (`cargo install --git https://github.com/aent-ai/aegis-orchestrator`)
- Python 3.11+ (for Python-based agents)
- API keys for services (OpenAI, GitHub, etc.)

### Running an Example

1. **Clone this repository**:

   ```bash
   git clone https://github.com/aent-ai/aegis-examples
   cd aegis-examples
   ```

2. **Set up secrets**:

   ```bash
   # Add to your AEGIS dashboard or use environment variables
   export OPENAI_API_KEY="sk-..."
   ```

3. **Run an agent**:

   ```bash
   aegis run email-summarizer/agent.yaml
   ```

### Creating Your Own Agent

1. **Create a directory**:

   ```bash
   mkdir my-agent
   cd my-agent
   ```

2. **Create `agent.yaml`**:

   ```yaml
   version: "1.0"
   agent:
     name: "my-agent"
     runtime: "python:3.11"
     memory: true

   permissions:
     network:
       allow:
         - "api.openai.com"
     fs:
       read: ["/data/inputs"]
       write: ["/data/outputs"]

   tools:
     - "mcp:filesystem"

   env:
     OPENAI_API_KEY: "secret:openai-key"
   ```

3. **Create `main.py`**:

   ```python
   import os
   from openai import OpenAI

   client = OpenAI(api_key=os.environ["OPENAI_API_KEY"])

   def main():
       response = client.chat.completions.create(
           model="gpt-4",
           messages=[{"role": "user", "content": "Hello!"}],
       )
       print(response.choices[0].message.content)

   if __name__ == "__main__":
       main()
   ```

4. **Run**:

   ```bash
   aegis run agent.yaml
   ```

## Agent Manifest Reference

### Required Fields

```yaml
version: "1.0"           # Manifest version
agent:
  name: "agent-name"     # Unique identifier
  runtime: "python:3.11" # Container image
  memory: true           # Enable persistent memory
```

### Permissions

```yaml
permissions:
  network:
    allow:               # Allowed domains/IPs
      - "api.openai.com"
  fs:
    read: ["/data"]      # Readable paths
    write: ["/data/out"] # Writable paths
  execution_time: 300s   # Max execution time
  memory: 512MB          # Memory limit
  cpu_quota: 0.5         # CPU quota (0.5 = 50%)
```

### Tools

MCP tools available to the agent:

```yaml
tools:
  - "mcp:gmail"          # Gmail integration
  - "mcp:github"         # GitHub API
  - "mcp:browser"        # Web browsing
  - "mcp:filesystem"     # File access
  - "mcp:search"         # Web search
```

### Environment Variables

```yaml
env:
  OPENAI_API_KEY: "secret:openai-key"  # Reference secret
  DEBUG: "true"                         # Plain value
```

## Security Best Practices

1. **Minimal Permissions**: Only request necessary network/filesystem access
2. **Use Secrets**: Never hardcode API keys; use `secret:` references
3. **Resource Limits**: Set appropriate CPU and memory limits
4. **Tool Scoping**: Only include required MCP tools

## Schema Validation

All manifests are validated against [`schemas/agent-manifest.schema.json`](schemas/agent-manifest.schema.json).

## Contributing

We welcome new examples! Please:

1. Follow the existing structure
2. Include a README in your example directory
3. Test locally before submitting
4. Add appropriate comments

## License

Business Source License 1.1. See [LICENSE](LICENSE) for details.

## Related Repositories

- [aegis-orchestrator](https://github.com/aent-ai/aegis-orchestrator) - Core runtime
- [aegis-sdk-python](https://github.com/aent-ai/aegis-sdk-python) - Python SDK
- [aegis-sdk-typescript](https://github.com/aent-ai/aegis-sdk-typescript) - TypeScript SDK
- [aegis-control-plane](https://github.com/aent-ai/aegis-control-plane) - Web dashboard

---

**Learn by example. Build with confidence.**
