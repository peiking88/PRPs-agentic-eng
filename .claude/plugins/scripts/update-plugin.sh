#!/bin/bash
# Codebuddy Plugin Updater
# Updates installed plugins to newer versions
#
# Usage: update-plugin.sh <plugin-name> [--version X.Y.Z] [--force] [--backup]
#
# Exit codes:
#   0 - Success
#   1 - No update needed
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
TARGET_VERSION=""
FORCE=false
BACKUP=true

while [[ $# -gt 0 ]]; do
    case $1 in
        --version)
            TARGET_VERSION="$2"
            shift 2
            ;;
        --force)
            FORCE=true
            shift
            ;;
        --no-backup)
            BACKUP=false
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

if [ -z "$PLUGIN_NAME" ]; then
    echo -e "${RED}Error: Plugin name required${NC}"
    echo "Usage: update-plugin.sh <plugin-name> [--version X.Y.Z] [--force] [--no-backup]"
    exit 2
fi

CLAUDE_DIR=".claude"
PLUGINS_DIR="$CLAUDE_DIR/plugins"
SKILLS_DIR="$CLAUDE_DIR/skills"
LOCKFILE="$PLUGINS_DIR/plugin-lock.json"
PLUGIN_DIR="$SKILLS_DIR/$PLUGIN_NAME"

# Check plugin is installed
if [ ! -d "$PLUGIN_DIR" ]; then
    echo -e "${RED}Error: Plugin '$PLUGIN_NAME' not installed${NC}"
    exit 2
fi

if [ ! -f "$LOCKFILE" ]; then
    echo -e "${RED}Error: Lockfile not found${NC}"
    exit 2
fi

# Check for jq
if ! command -v jq &> /dev/null; then
    echo -e "${RED}Error: jq required${NC}"
    exit 2
fi

# Get current version and source
CURRENT_VERSION=$(jq -r ".plugins[\"$PLUGIN_NAME\"].version // empty" "$LOCKFILE")
SOURCE=$(jq -r ".plugins[\"$PLUGIN_NAME\"].source // empty" "$LOCKFILE")

if [ -z "$CURRENT_VERSION" ] || [ -z "$SOURCE" ]; then
    echo -e "${RED}Error: Plugin info not found in lockfile${NC}"
    exit 2
fi

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Plugin Updater${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""
echo -e "Plugin: ${BLUE}$PLUGIN_NAME${NC}"
echo -e "Current: $CURRENT_VERSION"
echo -e "Source: $SOURCE"
echo ""

# Get available versions
get_available_versions() {
    local url="$1"
    git ls-remote --tags "$url" 2>/dev/null | grep -oP 'refs/tags/v\K[0-9]+\.[0-9]+\.[0-9]+' | sort -Vr
}

# Get latest version
get_latest_version() {
    local url="$1"
    get_available_versions "$url" | head -1
}

# Determine target version
if [ -z "$TARGET_VERSION" ]; then
    TARGET_VERSION=$(get_latest_version "$SOURCE")
    
    if [ -z "$TARGET_VERSION" ]; then
        echo -e "${YELLOW}Warning: Could not fetch latest version${NC}"
        echo -e "Check network connectivity and repository access"
        exit 2
    fi
fi

# Compare versions
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

CMP=$(compare_versions "$CURRENT_VERSION" "$TARGET_VERSION")

case "$CMP" in
    equal)
        echo -e "${GREEN}✅ Already at version $TARGET_VERSION${NC}"
        exit 0
        ;;
    newer)
        echo -e "${YELLOW}⚠️ Current version ($CURRENT_VERSION) is newer than target ($TARGET_VERSION)${NC}"
        if [ "$FORCE" != true ]; then
            echo -e "Use --force to downgrade"
            exit 1
        fi
        ;;
    older)
        # Determine update type
        CURRENT_MAJOR=$(echo "$CURRENT_VERSION" | cut -d. -f1)
        LATEST_MAJOR=$(echo "$TARGET_VERSION" | cut -d. -f2)
        
        if [ "${TARGET_VERSION%%.*}" -gt "${CURRENT_VERSION%%.*}" ]; then
            echo -e "${YELLOW}⚠️ Major version update${NC}"
            echo -e "  Breaking changes may occur"
        else
            echo -e "${GREEN}📦 Update available: $CURRENT_VERSION → $TARGET_VERSION${NC}"
        fi
        ;;
esac

# Confirm update
if [ "$FORCE" != true ]; then
    echo ""
    echo -e "Proceed with update? [y/N] "
    read -r CONFIRM
    
    if [[ ! "$CONFIRM" =~ ^[Yy]$ ]]; then
        echo -e "${YELLOW}Update cancelled${NC}"
        exit 0
    fi
fi

# Backup current version
BACKUP_DIR=""
if [ "$BACKUP" = true ]; then
    BACKUP_DIR="$PLUGIN_DIR.bak.$(date +%Y%m%d-%H%M%S)"
    echo ""
    echo -e "${BLUE}Backing up current version...${NC}"
    cp -r "$PLUGIN_DIR" "$BACKUP_DIR"
    echo -e "  ${GREEN}✓${NC} Backup: $BACKUP_DIR"
fi

# Download new version
echo ""
echo -e "${BLUE}Downloading version $TARGET_VERSION...${NC}"
TEMP_DIR=$(mktemp -d)

if git clone --depth 1 --branch "v$TARGET_VERSION" "$SOURCE" "$TEMP_DIR" 2>&1; then
    echo -e "  ${GREEN}✓${NC} Downloaded"
else
    echo -e "  ${RED}✗${NC} Download failed"
    rm -rf "$TEMP_DIR"
    [ -n "$BACKUP_DIR" ] && rm -rf "$BACKUP_DIR"
    exit 2
fi

# Validate new version
echo ""
echo -e "${BLUE}Validating new version...${NC}"

VALIDATOR="$PLUGINS_DIR/validate-plugin.sh"
if [ -f "$VALIDATOR" ]; then
    if ! "$VALIDATOR" "$TEMP_DIR"; then
        echo -e "${RED}✗ Validation failed${NC}"
        rm -rf "$TEMP_DIR"
        [ -n "$BACKUP_DIR" ] && rm -rf "$BACKUP_DIR"
        exit 2
    fi
    echo -e "  ${GREEN}✓${NC} Validation passed"
fi

# Apply update
echo ""
echo -e "${BLUE}Applying update...${NC}"

# Remove old version
rm -rf "$PLUGIN_DIR"

# Install new version
mkdir -p "$PLUGIN_DIR"
cp -r "$TEMP_DIR/"* "$PLUGIN_DIR/"

echo -e "  ${GREEN}✓${NC} Updated"

# Update lockfile
INSTALL_DATE=$(date -Iseconds)
jq --arg name "$PLUGIN_NAME" \
   --arg version "$TARGET_VERSION" \
   --arg date "$INSTALL_DATE" \
   --arg prev "$CURRENT_VERSION" \
   '.plugins[$name].version = $version |
    .plugins[$name].updated = $date |
    .plugins[$name].previousVersion = $prev' \
   "$LOCKFILE" > "${LOCKFILE}.tmp" && mv "${LOCKFILE}.tmp" "$LOCKFILE"

echo -e "  ${GREEN}✓${NC} Lockfile updated"

# Cleanup
rm -rf "$TEMP_DIR"

# Summary
echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}✅ Update Complete${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo -e "Plugin: ${BLUE}$PLUGIN_NAME${NC}"
echo -e "Version: ${CURRENT_VERSION} → ${TARGET_VERSION}"
echo -e "Location: $PLUGIN_DIR"

if [ -n "$BACKUP_DIR" ]; then
    echo ""
    echo -e "Backup: $BACKUP_DIR"
    echo -e "Remove with: rm -rf $BACKUP_DIR"
fi

echo ""
echo -e "Restart Codebuddy to load the updated plugin"

exit 0
