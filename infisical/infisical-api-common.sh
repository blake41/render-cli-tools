# Common functions for Infisical CLI scripts
# Source this file: source "$(dirname "$0")/infisical-common.sh"

CONFIG_DIR="$HOME/.config/infisical"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Load credentials: .env override > global config
load_credentials() {
    # Check .env in current directory first (override)
    if [[ -f ".env" ]]; then
        local env_id=$(grep -E "^INFISICAL_CLIENT_ID=" .env 2>/dev/null | cut -d= -f2- | tr -d '"' | tr -d "'")
        local env_secret=$(grep -E "^INFISICAL_CLIENT_SECRET=" .env 2>/dev/null | cut -d= -f2- | tr -d '"' | tr -d "'")
        if [[ -n "$env_id" && -n "$env_secret" ]]; then
            export INFISICAL_CLIENT_ID="$env_id"
            export INFISICAL_CLIENT_SECRET="$env_secret"
            return 0
        fi
    fi
    
    # Fall back to global config
    if [[ -f "$CONFIG_DIR/credentials" ]]; then
        source "$CONFIG_DIR/credentials"
        if [[ -n "$INFISICAL_CLIENT_ID" && -n "$INFISICAL_CLIENT_SECRET" ]]; then
            return 0
        fi
    fi
    
    echo -e "${RED}Error: Infisical credentials not found${NC}" >&2
    echo "Set INFISICAL_CLIENT_ID and INFISICAL_CLIENT_SECRET in:" >&2
    echo "  - .env (project override)" >&2
    echo "  - ~/.config/infisical/credentials (global)" >&2
    echo "" >&2
    echo "To set up, create a Machine Identity in Infisical:" >&2
    echo "  1. Go to Access Control > Machine Identities" >&2
    echo "  2. Create identity with Universal Auth" >&2
    echo "  3. Copy Client ID and Client Secret" >&2
    return 1
}

# Load API host (defaults to Infisical Cloud US)
load_api_host() {
    # Check .env first
    if [[ -f ".env" ]]; then
        local env_host=$(grep -E "^INFISICAL_API_HOST=" .env 2>/dev/null | cut -d= -f2- | tr -d '"' | tr -d "'")
        if [[ -n "$env_host" ]]; then
            echo "$env_host"
            return 0
        fi
    fi
    
    # Check global config
    if [[ -f "$CONFIG_DIR/api_host" ]]; then
        cat "$CONFIG_DIR/api_host"
        return 0
    fi
    
    # Default to US cloud
    echo "https://us.infisical.com"
}

# Get access token via Universal Auth
# Caches token in /tmp for 5 minutes
get_access_token() {
    local api_host
    api_host=$(load_api_host)
    local cache_file="/tmp/infisical_token_$(echo "$INFISICAL_CLIENT_ID" | md5sum | cut -d' ' -f1)"
    
    # Check cache (tokens valid for ~5 min)
    if [[ -f "$cache_file" ]]; then
        local cache_age=$(($(date +%s) - $(stat -f%m "$cache_file" 2>/dev/null || stat -c%Y "$cache_file" 2>/dev/null)))
        if [[ $cache_age -lt 240 ]]; then
            cat "$cache_file"
            return 0
        fi
    fi
    
    # Fetch new token
    local response
    response=$(curl -sS "$api_host/api/v1/auth/universal-auth/login" \
        -H "Content-Type: application/json" \
        -d "{\"clientId\": \"$INFISICAL_CLIENT_ID\", \"clientSecret\": \"$INFISICAL_CLIENT_SECRET\"}" 2>&1)
    
    local token
    token=$(echo "$response" | jq -r '.accessToken // empty')
    
    if [[ -z "$token" ]]; then
        echo -e "${RED}Failed to authenticate with Infisical${NC}" >&2
        echo "$response" | jq -r '.message // .' >&2
        return 1
    fi
    
    echo "$token" > "$cache_file"
    chmod 600 "$cache_file"
    echo "$token"
}

# API helper - handles authentication automatically
infisical_api() {
    local endpoint="$1"
    shift
    
    local api_host
    api_host=$(load_api_host)
    
    local token
    token=$(get_access_token) || return 1
    
    curl -sS "$api_host/api$endpoint" \
        -H "Authorization: Bearer $token" \
        -H "Accept: application/json" \
        -H "Content-Type: application/json" \
        "$@"
}

# Pretty print JSON with jq if available
pretty_json() {
    if command -v jq &> /dev/null; then
        jq "$@"
    else
        cat
    fi
}

# Ensure config directory exists
ensure_config_dir() {
    mkdir -p "$CONFIG_DIR"
}

