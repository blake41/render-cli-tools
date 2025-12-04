# Common functions for Cloudflare CLI scripts
# Source this file: source "$(dirname "$0")/cf-common.sh"

CONFIG_DIR="$HOME/.config/cloudflare"

# Load account ID
load_account_id() {
    # Check .env in current directory first (override)
    if [[ -f ".env" ]]; then
        local env_id=$(grep -E "^CLOUDFLARE_ACCOUNT_ID=" .env 2>/dev/null | cut -d= -f2- | tr -d '"' | tr -d "'")
        if [[ -n "$env_id" ]]; then
            echo "$env_id"
            return 0
        fi
    fi
    
    # Fall back to global config
    if [[ -f "$CONFIG_DIR/account_id" ]]; then
        cat "$CONFIG_DIR/account_id"
        return 0
    fi
    
    # Try wrangler
    wrangler whoami 2>/dev/null | grep -oE '[a-f0-9]{32}' | head -1
}

# Load API token (for direct API calls)
load_api_token() {
    # Check .env in current directory first
    if [[ -f ".env" ]]; then
        local env_token=$(grep -E "^CLOUDFLARE_API_TOKEN=" .env 2>/dev/null | cut -d= -f2- | tr -d '"' | tr -d "'")
        if [[ -n "$env_token" ]]; then
            export CLOUDFLARE_API_TOKEN="$env_token"
            return 0
        fi
    fi
    
    # Fall back to global config
    if [[ -f "$CONFIG_DIR/api_token" ]]; then
        export CLOUDFLARE_API_TOKEN=$(cat "$CONFIG_DIR/api_token")
        return 0
    fi
    
    return 1
}

# API helper (requires api_token)
cf_api() {
    local endpoint="$1"
    shift
    
    if [[ -z "${CLOUDFLARE_API_TOKEN:-}" ]]; then
        echo "Error: CLOUDFLARE_API_TOKEN not set" >&2
        return 1
    fi
    
    curl -sS "https://api.cloudflare.com/client/v4$endpoint" \
        -H "Authorization: Bearer $CLOUDFLARE_API_TOKEN" \
        -H "Content-Type: application/json" \
        "$@"
}
