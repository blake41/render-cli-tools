# Common functions for Render CLI scripts
# Source this file: source "$(dirname "$0")/render-common.sh"

CONFIG_DIR="$HOME/.config/render"

# Load API key: .env override > global config
load_api_key() {
    # Check .env in current directory first (override)
    if [[ -f ".env" ]]; then
        local env_key=$(grep -E "^RENDER_API_KEY=" .env 2>/dev/null | cut -d= -f2- | tr -d '"' | tr -d "'")
        if [[ -n "$env_key" ]]; then
            export RENDER_API_KEY="$env_key"
            return 0
        fi
    fi
    
    # Fall back to global config
    if [[ -f "$CONFIG_DIR/api_key" ]]; then
        export RENDER_API_KEY=$(cat "$CONFIG_DIR/api_key")
        return 0
    fi
    
    echo "Error: RENDER_API_KEY not found" >&2
    echo "Set it in .env or ~/.config/render/api_key" >&2
    return 1
}

# Load workspace: .env override > local .render-workspace > global config
load_workspace() {
    # Check .env in current directory
    if [[ -f ".env" ]]; then
        local env_ws=$(grep -E "^RENDER_WORKSPACE=" .env 2>/dev/null | cut -d= -f2- | tr -d '"' | tr -d "'")
        if [[ -n "$env_ws" ]]; then
            echo "$env_ws"
            return 0
        fi
    fi
    
    # Check local .render-workspace
    if [[ -f ".render-workspace" ]]; then
        cat ".render-workspace"
        return 0
    fi
    
    # Fall back to global config
    if [[ -f "$CONFIG_DIR/workspace" ]]; then
        cat "$CONFIG_DIR/workspace"
        return 0
    fi
    
    return 1
}

# API helper
render_api() {
    local endpoint="$1"
    shift
    curl -sS "https://api.render.com/v1$endpoint" \
        -H "Authorization: Bearer $RENDER_API_KEY" \
        -H "Accept: application/json" \
        "$@"
}
