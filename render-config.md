# Render CLI Config

Global configuration for Render CLI scripts.

## Files

- `api_key` - Your Render API key (get from https://dashboard.render.com/u/settings/api-keys)
- `workspace` - Default workspace/owner ID

## Setup

```bash
echo "rnd_your_key_here" > ~/.config/render/api_key
echo "tea-xxxxx" > ~/.config/render/workspace
chmod 600 ~/.config/render/api_key
```

## Override

Set `RENDER_API_KEY` in a project's `.env` to override the global key.
