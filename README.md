# Developer Tools

Central location for reusable CLI tools and documentation.

## Structure

```
tools/
├── cli-over-mcp.md       # Pattern: replacing MCP with CLI scripts
├── render-config.md      # Render CLI setup docs
└── render/               # Render CLI scripts (reference copy)
```

## Installed Locations

| Component | Location |
|-----------|----------|
| Global scripts | `~/.local/bin/render-*` |
| Global config | `~/.config/render/` |
| Docs | This folder |

## Quick Reference

### Render CLI

```bash
# From any directory
render-services list
render-logs srv-xxxxx --level error --lines 50
render-workspace current

# Per-project override: add to .env
RENDER_WORKSPACE=tea-xxxxx
RENDER_API_KEY=rnd_xxxxx  # optional, overrides global
```

### Adding to a New Project

No setup needed! The global scripts read from `~/.config/render/` by default.

For project-specific workspace:
```bash
cd ~/your-project
echo "RENDER_WORKSPACE=tea-xxxxx" >> .env
```

## Documentation

- [cli-over-mcp.md](./cli-over-mcp.md) - Why and how to replace MCP with CLI scripts
- [render-config.md](./render-config.md) - Render CLI configuration
