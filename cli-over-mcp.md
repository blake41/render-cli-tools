# CLI Scripts Over MCP: A Pattern for Efficient Agent Tool Use

## The Problem with MCP

From [Mario Zechner's post](https://mariozechner.at/posts/2025-11-02-what-if-you-dont-need-mcp/) and [Anthropic's advanced tool use](https://www.anthropic.com/engineering/advanced-tool-use):

| Issue | Impact |
|-------|--------|
| **Token bloat** | MCP tool definitions consume 13-55k+ tokens *before* any work begins |
| **Not composable** | Results must flow through agent context; can't pipe to files or chain commands |
| **Hard to extend** | Modifying an MCP server requires understanding its codebase |
| **Environment gaps** | Agent may not have access to CLIs/auth the user has configured |

Anthropic's research shows that a typical 5-server MCP setup (GitHub, Slack, Sentry, Grafana, Splunk) consumes ~55k tokens just for tool definitions. Add more servers and you're approaching 100k+ token overhead.

## The Solution: Simple CLI Scripts + README

**Core insight**: Models already know how to write code and use Bash. Instead of paying for tool definitions in every session, leverage that existing knowledge with simple scripts the agent can call.

**Token comparison**:
- Browser MCP servers: 13,000-18,000 tokens
- Zechner's CLI README: 225 tokens
- Our Render scripts README: ~300 tokens

**Benefits**:
1. **Composable** - Pipe output to files, grep, or other commands
2. **Easy to extend** - Add a new script in minutes
3. **Portable** - Works on any machine with the repo cloned
4. **Tailored** - Only include operations you actually use
5. **Self-documenting** - Each script has `--help`, README teaches usage

## The Pattern

```
scripts/<service>/
├── README.md          # Agent reads this once per session (~200-300 tokens)
├── <action>.sh        # Simple bash scripts wrapping API calls
└── ...
```

### Key Characteristics

1. **Self-contained auth** - Scripts source `.env` for API keys
2. **Workspace/project state** - Stored in a dotfile (e.g., `.render-workspace`)
3. **Self-documenting** - Each script supports `--help`
4. **Composable output** - Clean text that can be piped, grepped, saved
5. **Quick reference in README** - Service IDs, URLs, common commands

### Script Template

```bash
#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Load .env if it exists
if [[ -f "$PROJECT_ROOT/.env" ]]; then
    set -a
    source "$PROJECT_ROOT/.env"
    set +a
fi

# Validate required env vars
if [[ -z "${API_KEY:-}" ]]; then
    echo "Error: API_KEY not set" >&2
    exit 1
fi

# Your API calls here using curl + jq
curl -sS "https://api.example.com/endpoint" \
    -H "Authorization: Bearer $API_KEY" \
    -H "Accept: application/json" | jq '.'
```

### README Template

```markdown
# <Service> CLI Scripts

Minimal scripts for interacting with <Service>. Read this file when you need to work with <Service>.

## Quick Reference

| Resource | ID | URL |
|----------|----|----|
| my-service | `srv-xxxxx` | https://example.com |

## Setup

Set `<SERVICE>_API_KEY` in your `.env` file.

## Scripts

### List Resources
\`\`\`bash
./scripts/<service>/list.sh
\`\`\`

### Get Logs
\`\`\`bash
./scripts/<service>/logs.sh <resource-id> --lines 50
\`\`\`
```

## Implementation Checklist

When replacing an MCP with CLI scripts:

- [ ] **Identify actual usage** - What 3-5 operations do you actually use?
- [ ] **Create `scripts/<service>/` directory**
- [ ] **Write minimal bash scripts** using `curl` + `jq`:
  - Source `.env` for API keys
  - Read workspace/project state from a dotfile
  - Output clean, parseable text
- [ ] **Write a README** with:
  - Quick reference table (IDs, URLs)
  - Setup instructions (env vars needed)
  - Command examples for each script
- [ ] **Gitignore state files** (`.render-workspace`, etc.)
- [ ] **Make scripts executable** (`chmod +x scripts/<service>/*.sh`)

## When to Use This Pattern

**Good fit**:
- You use 3-10 operations from a service regularly
- The service has a REST API
- You want composable, scriptable access
- Token efficiency matters in agent workflows

**Not worth it**:
- You rarely use the service
- You need dozens of complex operations
- The MCP is already lightweight (<1k tokens)

## Example: Render Scripts

We created CLI scripts for Render to replace the MCP:

```
scripts/render/
├── README.md        # Quick reference + usage docs
├── workspace.sh     # list | select | current
├── services.sh      # list | get
└── logs.sh          # <service-id> [--lines N] [--level error] [--type app]
```

Typical workflow:
```bash
# First time: select workspace
./scripts/render/workspace.sh list
./scripts/render/workspace.sh select tea-xxxxx

# Debug: check logs
./scripts/render/logs.sh srv-xxxxx --level error --lines 50
```

## References

- [What if you don't need MCP at all?](https://mariozechner.at/posts/2025-11-02-what-if-you-dont-need-mcp/) - Mario Zechner
- [MCPorter](https://github.com/steipete/mcporter) - Generate CLIs from MCP servers
- [Advanced tool use on Claude Developer Platform](https://www.anthropic.com/engineering/advanced-tool-use) - Anthropic
