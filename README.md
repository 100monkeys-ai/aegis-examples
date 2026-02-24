# AEGIS Examples

Example agents and the local development stack for the AEGIS runtime.

[![License](https://img.shields.io/badge/license-AGPL--3.0-blue.svg)](LICENSE)

## Deploy the local stack

All Docker Compose files and configuration needed to run AEGIS locally are in [`deploy/`](deploy/).

```bash
git clone https://github.com/100monkeys-ai/aegis-examples.git
cd aegis-examples

# Configure environment (edit if needed)
cp deploy/.env.example deploy/.env

# Start all services (Postgres, SeaweedFS, Temporal, Keycloak, Ollama, Cortex)
docker compose -f deploy/docker-compose.yml up -d

# Install the AEGIS binary
curl -fsSL https://github.com/100monkeys-ai/aegis-orchestrator/releases/latest/download/aegis-linux-x86_64.tar.gz \
  | tar -xz -C /usr/local/bin

# Deploy and run the hello-world example
aegis agent deploy ./agents/hello-world/agent.yaml
aegis execute --agent hello-world \
  --input '{"task": "Write a Python function that returns the Fibonacci sequence up to n."}' \
  --watch
```

See [deploy/README.md](deploy/README.md) for full details and the [Getting Started guide](https://docs.aegis.ai/docs/getting-started) for a step-by-step walkthrough.

---

## Overview

This repository contains ready-to-run example agents that showcase:

- MCP tool integration
- Security policy configuration
- Memory system (Cortex) usage
- Best practices for agent development
- The complete local deployment stack

## Examples

### 0. Hello World

**Location**: [`agents/hello-world/`](agents/hello-world/)

The introductory agent. Writes a Python function, tests it, and iteratively refines it until all tests pass. Used in the [Getting Started guide](https://docs.aegis.ai/docs/getting-started).

**Features**:

- Iterative refinement loop (100monkeys algorithm)
- `fs.write` and `cmd.run` tool usage
- Gradient validation (0.0–1.0 quality score)

**Run**:

```bash
aegis agent deploy ./agents/hello-world/agent.yaml
aegis execute --agent hello-world \
  --input '{"task": "Write a Python function that returns the Fibonacci sequence up to n."}' \
  --watch
```

---

### 1. Email Summarizer

**Location**: [`agents/email-summarizer/`](agents/email-summarizer/)

Connects to Gmail and generates AI-powered email summaries.

**Features**:

- Gmail MCP integration
- OpenAI GPT-4 summarization
- Persistent memory for learning user preferences

**Run**:

```bash
aegis run agents/email-summarizer/agent.yaml
```

### 2. Web Researcher

**Location**: [`agents/web-researcher/`](agents/web-researcher/)

Performs deep research on any topic by searching, reading, and synthesizing information.

**Features**:

- Web search via MCP
- Multi-source article reading
- Comprehensive report generation

**Run**:

```bash
aegis run agents/web-researcher/agent.yaml
```

### 3. Code Reviewer

**Location**: [`agents/code-reviewer/`](agents/code-reviewer/)

Reviews pull requests for security issues, code quality, and best practices.

**Features**:

- GitHub MCP integration
- Security vulnerability detection
- Best practice recommendations

**Run**:

```bash
aegis run agents/code-reviewer/agent.yaml
```

## Workflow Examples

Multi-agent pipelines are defined in [`agents/workflows/`](agents/workflows/). Each file is a complete, deployable Workflow Manifest.

| File | Pattern | Description |
| --- | --- | --- |
| [`100monkeys-classic.yaml`](agents/workflows/100monkeys-classic.yaml) | Iterative refinement | Generate → execute → judge-validate → refine loop using the Blackboard for iteration state. |
| [`the-forge.yaml`](agents/workflows/the-forge.yaml) | Constitutional pipeline | Full RequirementsAI → ArchitectAI → TesterAI → CoderAI → parallel audit → human gate → deploy lifecycle. |
| [`stateful-pipeline.yaml`](agents/workflows/stateful-pipeline.yaml) | Blackboard accumulation | Three-state example showing all three Blackboard population methods: `spec.context` seeding, automatic state-output writes, and explicit `update_blackboard` System states. **Start here if you're learning the Blackboard.** |
| [`echo-workflow.yaml`](agents/workflows/echo-workflow.yaml) | Minimal | Two-state echo workflow demonstrating `{{workflow.context.KEY}}` access. |
| [`agent-workflow.yaml`](agents/workflows/agent-workflow.yaml) | Minimal | Two-state workflow with a System state reading an Agent output. |
| [`human-approval.yaml`](agents/workflows/human-approval.yaml) | Human-in-the-loop | Three-state workflow with a Human gate and `signal` resumption. |
| [`multi-judge.yaml`](agents/workflows/multi-judge.yaml) | Parallel validation | `ParallelAgents` state with weighted-average consensus. |
| [`multi-judge-majority.yaml`](agents/workflows/multi-judge-majority.yaml) | Parallel validation | `ParallelAgents` with majority-vote consensus strategy. |
| [`multi-judge-unanimous.yaml`](agents/workflows/multi-judge-unanimous.yaml) | Parallel validation | `ParallelAgents` with unanimous-approval gate. |
| [`multi-judge-best-of-n.yaml`](agents/workflows/multi-judge-best-of-n.yaml) | Parallel validation | `ParallelAgents` with best-of-N consensus — for grading and ranking tasks. |

Deploy and run a workflow:

```bash
# Deploy
aegis workflow deploy ./agents/workflows/stateful-pipeline.yaml

# Start with input
aegis workflow start stateful-pipeline --input '{"task": "quantum entanglement", "max_words": 150}'

# Monitor
aegis workflow status <execution-id> --watch
```

See the [Workflow Manifest Reference](https://docs.aegis.ai/docs/reference/workflow-manifest) and the [Building Workflows guide](https://docs.aegis.ai/docs/guides/building-workflows) for full documentation.

---

## Getting Started

### Prerequisites

- **Docker** 24.0+ and **Docker Compose** v2.20+ — for the local backing-service stack
- **AEGIS binary** — download from the [GitHub Releases page](https://github.com/100monkeys-ai/aegis-orchestrator/releases)
- **Python 3.11+** — for Python-based agents
- API keys for the services you want to use (OpenAI, GitHub, etc.)

### Running an Example

1. **Clone this repository and start the local stack**:

   ```bash
   git clone https://github.com/100monkeys-ai/aegis-examples
   cd aegis-examples
   cp deploy/.env.example deploy/.env
   docker compose -f deploy/docker-compose.yml up -d
   ```

2. **Install the AEGIS binary**:

   ```bash
   curl -fsSL https://github.com/100monkeys-ai/aegis-orchestrator/releases/latest/download/aegis-linux-x86_64.tar.gz \
     | tar -xz -C /usr/local/bin
   ```

3. **Deploy and run an agent**:

   ```bash
   # Start with the hello-world example — no API keys required with local Ollama
   aegis agent deploy ./agents/hello-world/agent.yaml
   aegis execute --agent hello-world \
     --input '{"task": "Write a Python function that returns the Fibonacci sequence up to n."}' \
     --watch
   ```

### Creating Your Own Agent

AEGIS agents are **manifest-only** — there is no agent-side Python script. The orchestrator drives the LLM using the `task.instruction` you provide, and the LLM accomplishes the task through tool calls (`fs.write`, `cmd.run`, `mcp:*`, etc.). You declare *what* the agent can do; the runtime figures out *how*.

1. **Create a directory**:

   ```bash
   mkdir my-agent
   cd my-agent
   ```

2. **Create `agent.yaml`**:

   ```yaml
   apiVersion: 100monkeys.ai/v1
   kind: Agent

   metadata:
     name: "my-agent"
     version: "1.0.0"
     description: "Brief description of what this agent does"

   spec:
     runtime:
       language: "python"
       version: "3.11"
       isolation: "inherit"

     task:
       instruction: |
         Describe the agent\'s behaviour here as a clear, natural-language
         instruction. The orchestrator uses this as the system prompt for the
         iterative LLM loop. Be specific about inputs, outputs, and quality
         criteria.

     execution:
       mode: "iterative"
       max_iterations: 5
       memory: false

       validation:
         semantic:
           enabled: true
           threshold: 0.85
           prompt: |
             Assess whether the agent successfully completed the task.

     security:
       network:
         mode: "allow"
         allowlist: []  # Add external domains only if your tools need them
       filesystem:
         read: ["/workspace"]
         write: ["/workspace"]
       resources:
         cpu: 500
         memory: "512Mi"
         timeout: "120s"

     tools:
       - "fs.write"
       - "fs.read"
       - "cmd.run"
   ```

3. **Deploy and run**:

   ```bash
   aegis agent deploy ./my-agent/agent.yaml
   aegis execute --agent my-agent --input '{"task": "Your task here"}' --watch
   ```

## Agent Manifest Reference

AEGIS manifests follow a Kubernetes-style `apiVersion/kind/metadata/spec` schema. There is **no agent-side script** — the orchestrator drives the LLM using `spec.task.instruction`.

### Metadata

```yaml
apiVersion: 100monkeys.ai/v1
kind: Agent
metadata:
  name: "agent-name"     # Unique identifier, used as --agent value
  version: "1.0.0"
  description: "What this agent does"
  labels:
    role: "worker"       # worker | judge | critic | router
    category: "demo"
```

### Runtime

```yaml
spec:
  runtime:
    language: "python"   # Execution environment
    version: "3.11"
    isolation: "inherit" # inherit (Docker) | microvm (Firecracker)
```

### Task

```yaml
  task:
    instruction: |
      Natural-language description of the agent's goal.
      The orchestrator uses this as the system prompt for the LLM.
      Be specific: describe inputs, expected outputs, and quality bar.
    prompt_template: |
      {{instruction}}
      User: {{input}}
```

### Execution

```yaml
  execution:
    mode: "iterative"    # iterative = 100monkeys refinement loop
    max_iterations: 5
    memory: false        # true = enable Cortex persistent memory

    validation:
      semantic:
        enabled: true
        threshold: 0.85  # 0.0–1.0; score below this triggers refinement
        prompt: |
          Assess whether the agent successfully completed the task.
```

### Security

```yaml
  security:
    network:
      mode: "allow"
      allowlist:
        # List only domains your MCP tool servers need to reach.
        # Do NOT add api.openai.com or any LLM endpoint here —
        # the orchestrator handles all LLM routing.
        - "api.github.com"
    filesystem:
      read: ["/workspace"]
      write: ["/workspace"]
    resources:
      cpu: 500           # millicores (500 = 0.5 core)
      memory: "512Mi"
      timeout: "120s"
```

### Tools

```yaml
  tools:
    - "fs.write"         # Write files in the agent container
    - "fs.read"          # Read files in the agent container
    - "cmd.run"          # Execute shell commands in the container
    - "mcp:gmail"        # Gmail integration (tool server on orchestrator host)
    - "mcp:github"       # GitHub API
    - "mcp:browser"      # Web browsing
    - "mcp:search"       # Web search
```

### Secrets (for MCP tool servers)

```yaml
  # Secrets listed here are resolved from OpenBao by the orchestrator and
  # injected into MCP tool server processes on the orchestrator host.
  # They are NOT exposed inside the agent container.
  env:
    GITHUB_TOKEN: "secret:github-token"
    GMAIL_CREDENTIALS: "secret:gmail-oauth"
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

GNU Affero General Public License v3.0 (AGPL-3.0). See [LICENSE](LICENSE) for details.

---

**Learn by example. Build with confidence.**
