# Developer Tools

Central location for reusable CLI tools and documentation.

## Structure

```
tools/
├── cli-over-mcp.md       # Pattern: replacing MCP with CLI scripts
├── render-config.md      # Render CLI setup docs
├── render/               # Render CLI scripts (reference copy)
├── cloudflare/           # Cloudflare CLI scripts (reference copy)
├── github/               # GitHub Actions CLI scripts
├── infisical/            # Infisical API scripts
├── salesforce/           # Salesforce SOQL query scripts
└── linear/               # Linear issue tracking CLI
```

## Installed Locations

| Component | Location |
|-----------|----------|
| Render scripts | `~/.local/bin/render-*` |
| Render config | `~/.config/render/` |
| Cloudflare scripts | `~/.local/bin/cf-*` |
| Cloudflare config | `~/.config/cloudflare/` |
| GitHub scripts | `~/.local/bin/gh-actions` |
| GitHub config | Uses `gh` CLI auth |
| Salesforce scripts | `~/.local/bin/sf-query` |
| Salesforce config | Uses `sf` CLI auth |
| Linear scripts | `~/.local/bin/linear-cli` |
| Linear config | `~/.config/linear/api-key` |
| Docs | This folder |

## Quick Reference

### GitHub Actions CLI

```bash
gh-actions runs                          # List recent workflow runs
gh-actions runs --status failure         # Filter by status
gh-actions runs --branch main            # Filter by branch
gh-actions logs <run-id>                 # Get full logs for a run
gh-actions logs <run-id> --failed        # Only failed steps
gh-actions failures                      # Recent failures with summaries
gh-actions failures --since 7d           # Last week's failures
gh-actions rerun <run-id>                # Re-run a workflow
gh-actions rerun <run-id> --failed       # Re-run only failed jobs
```

### Render CLI

```bash
render-services list
render-logs srv-xxxxx --level error --lines 50
render-workspace current
```

### Cloudflare CLI

```bash
cf-workers list                     # List workers
cf-workers deployments <name>       # Recent deployments
cf-logs <worker-name>               # Stream real-time logs (Ctrl+C to stop)
cf-logs <worker-name> --status 500  # Filter by HTTP status
```

Note: Cloudflare logs are real-time streaming only. Historical logs require Logpush (paid).

### Salesforce CLI

```bash
sf-query prod "SELECT Id, Name FROM Account LIMIT 10"
sf-query prod "SELECT Id, Name, StageName, Amount FROM Opportunity WHERE IsClosed = false"
sf-query prod "SELECT COUNT() FROM Contact"
sf-query prod describe Account              # Show object fields
sf-query sandbox "SELECT Id FROM Lead"      # Query sandbox
```

Note: SOQL is read-only by design. This tool cannot modify any Salesforce data.

### Linear CLI

```bash
linear-cli me                              # Current user info
linear-cli teams                           # List all teams
linear-cli projects                        # List all projects
linear-cli issues --mine --limit 10        # My issues
linear-cli issues --status "In Progress"   # Filter by status
linear-cli issue GTM-3424                  # Get specific issue
linear-cli search "authentication bug"     # Search issues
```

Note: This tool is read-only. To create/update issues, use the Linear UI or API directly.

### Per-Project Override

Add to `.env`:
```bash
# Render
RENDER_WORKSPACE=tea-xxxxx
RENDER_API_KEY=rnd_xxxxx

# Cloudflare
CLOUDFLARE_ACCOUNT_ID=xxxxx
CLOUDFLARE_API_TOKEN=xxxxx

# GitHub - uses gh CLI auth (run `gh auth login` if needed)
```

## Documentation

- [cli-over-mcp.md](./cli-over-mcp.md) - Why and how to replace MCP with CLI scripts
- [render-config.md](./render-config.md) - Render CLI configuration
