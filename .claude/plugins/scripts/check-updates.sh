#!/bin/bash
# Codebuddy Plugin Version Checker
# Checks for available updates for installed plugins
#
# Usage: check-updates.sh [plugin-name] [--json]
#
# Exit codes:
#   0 - No updates available
#   1 - Updates available
#   2 - Error

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Parse arguments
PLUGIN_NAME=""
JSON_OUTPUT=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --json)
            JSON_OUTPUT=true
            shift
            ;;
        -*)
            echo -e "${RED}Unknown option: $1${NC}" >&2
            exit 2
            ;;
        *)
            PLUGIN_NAME="$1"
            shift
            ;;
    esac
done

CLAUDE_DIR=".claude"
PLUGINS_DIR="$CLAUDE_DIR/plugins"
LOCKFILE="$PLUGINS_DIR/plugin-lock.json"

# Check lockfile exists
if [ ! -f "$LOCKFILE" ]; then
    echo -e "${YELLOW}No plugins installed${NC}"
    exit 0
fi

# Check for jq
if ! command -v jq &> /dev/null; then
    echo -e "${RED}Error: jq required${NC}" >&2
    exit 2
fi

# Get installed plugins
if [ -n "$PLUGIN_NAME" ]; then
    PLUGINS=("$PLUGIN_NAME")
else
    PLUGINS=($(jq -r '.plugins | keys[]' "$LOCKFILE" 2>/dev/null))
fi

if [ ${#PLUGINS[@]} -eq 0 ]; then
    echo -e "${YELLOW}No plugins found${NC}"
    exit 0
fi

# Function to get latest version from git remote
get_latest_version() {
    local url="$1"
    local latest=""
    
    # Fetch tags from remote
    if TAGS=$(git ls-remote --tags "$url" 2>/dev/null); then
        # Parse versions and find latest
        latest=$(echo "$TAGS" | grep -oP 'refs/tags/v\K[0-9]+\.[0-9]+\.[0-9]+' | sort -V | tail -1)
    fi
    
    echo "$latest"
}

# Function to compare versions
compare_versions() {
    local v1="$1"
    local v2="$2"
    
    if [ "$v1" = "$v2" ]; then
        echo "equal"
    elif [ "$(printf '%s\n%s' "$v1" "$v2" | sort -V | head -1)" = "$v1" ]; then
        echo "older"
    else
        echo "newer"
    fi
}

# Check updates
UPDATES_AVAILABLE=0
RESULTS="[]"

for PLUGIN in "${PLUGINS[@]}"; do
    CURRENT=$(jq -r ".plugins[\"$PLUGIN\"].version // empty" "$LOCKFILE" 2>/dev/null)
    SOURCE=$(jq -r ".plugins[\"$PLUGIN\"].source // empty" "$LOCKFILE" 2>/dev/null)
    
    if [ -z "$CURRENT" ] || [ -z "$SOURCE" ]; then
        continue
    fi
    
    # Get latest version
    LATEST=$(get_latest_version "$SOURCE")
    
    if [ -z "$LATEST" ]; then
        LATEST="$CURRENT"
        STATUS="unknown"
        UPDATE_TYPE="none"
    else
        CMP=$(compare_versions "$CURRENT" "$LATEST")
        
        case "$CMP" in
            equal)
                STATUS="uptodate"
                UPDATE_TYPE="none"
                ;;
            older)
                STATUS="update"
                # Determine update type
                CURRENT_MAJOR=$(echo "$CURRENT" | cut -d. -f1)
                CURRENT_MINOR=$(echo "$CURRENT" | cut -d. -f2)
                LATEST_MAJOR=$(echo "$LATEST" | cut -d. -f1)
                LATEST_MINOR=$(echo "$LATEST" | cut -d. -f2)
                
                if [ "$LATEST_MAJOR" -gt "$CURRENT_MAJOR" ]; then
                    UPDATE_TYPE="major"
                elif [ "$LATEST_MINOR" -gt "$CURRENT_MINOR" ]; then
                    UPDATE_TYPE="minor"
                else
                    UPDATE_TYPE="patch"
                fi
                UPDATES_AVAILABLE=1
                ;;
            newer)
                STATUS="newer"
                UPDATE_TYPE="none"
                ;;
        esac
    fi
    
    # Add to results
    RESULTS=$(echo "$RESULTS" | jq --arg name "$PLUGIN" \
        --arg current "$CURRENT" \
        --arg latest "$LATEST" \
        --arg status "$STATUS" \
        --arg type "$UPDATE_TYPE" \
        '. + [{
            name: $name,
            current: $current,
            latest: $latest,
            status: $status,
            updateType: $type,
            updateAvailable: ($status == "update")
        }]')
done

# Output
if [ "$JSON_OUTPUT" = true ]; then
    CHECKED=$(date -Iseconds)
    echo "{}" | jq --arg checked "$CHECKED" \
        --argjson updates $UPDATES_AVAILABLE \
        --argjson plugins "$RESULTS" \
        '{checked: $checked, updatesAvailable: $updates, plugins: $plugins}'
else
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}Plugin Update Check${NC}"
    echo -e "${BLUE}========================================${NC}"
    echo ""
    
    if [ ${#PLUGINS[@]} -eq 1 ]; then
        # Single plugin - detailed view
        PLUGIN_DATA=$(echo "$RESULTS" | jq '.[0]')
        NAME=$(echo "$PLUGIN_DATA" | jq -r '.name')
        CURRENT=$(echo "$PLUGIN_DATA" | jq -r '.current')
        LATEST=$(echo "$PLUGIN_DATA" | jq -r '.latest')
        STATUS=$(echo "$PLUGIN_DATA" | jq -r '.status')
        TYPE=$(echo "$PLUGIN_DATA" | jq -r '.updateType')
        
        echo -e "Plugin: ${BLUE}$NAME${NC}"
        echo -e "Current: $CURRENT"
        echo -e "Latest: $LATEST"
        echo ""
        
        case "$STATUS" in
            uptodate)
                echo -e "${GREEN}✅ Up to date${NC}"
                ;;
            update)
                case "$TYPE" in
                    major)
                        echo -e "${RED}⚠️ Major update available${NC}"
                        echo -e "  ${YELLOW}Breaking changes may occur${NC}"
                        ;;
                    minor)
                        echo -e "${YELLOW}📦 Minor update available${NC}"
                        ;;
                    patch)
                        echo -e "${GREEN}📦 Patch update available${NC}"
                        ;;
                esac
                echo ""
                echo -e "Run: ${BLUE}/update-plugin $NAME${NC}"
                ;;
            newer)
                echo -e "${YELLOW}⚠️ Local version newer than remote${NC}"
                ;;
            unknown)
                echo -e "${YELLOW}⚠️ Could not check remote version${NC}"
                ;;
        esac
    else
        # Multiple plugins - table view
        echo -e "| Plugin | Current | Latest | Status |"
        echo -e "|--------|---------|--------|--------|"
        
        echo "$RESULTS" | jq -r '.[] | "\(.name)|\(.current)|\(.latest)|\(.status)"' | while IFS='|' read -r name current latest status; do
            case "$status" in
                uptodate) ICON="✅" ;;
                update) ICON="📦" ;;
                newer) ICON="⚠️" ;;
                unknown) ICON="❓" ;;
                *) ICON="❓" ;;
            esac
            echo -e "| $name | $current | $latest | $ICON |"
        done
        
        echo ""
        if [ $UPDATES_AVAILABLE -eq 1 ]; then
            echo -e "${YELLOW}Updates available for some plugins${NC}"
            echo -e "Run: ${BLUE}/update-plugin <name>${NC}"
        else
            echo -e "${GREEN}All plugins up to date${NC}"
        fi
    fi
fi

exit $UPDATES_AVAILABLE
