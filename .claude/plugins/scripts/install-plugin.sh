#!/bin/bash
# Codebuddy Plugin Installer
# Installs plugins from registry, git URL, or local path
#
# Usage: install-plugin.sh <plugin-name | git-url | local-path> [--version X.Y.Z] [--dry-run]
#
# Exit codes:
#   0 - Success
#   1 - Error
#   2 - Plugin already installed (use --force to reinstall)

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Default paths
CLAUDE_DIR=".claude"
PLUGINS_DIR="$CLAUDE_DIR/plugins"
SKILLS_DIR="$CLAUDE_DIR/skills"
REGISTRY_FILE="$PLUGINS_DIR/registry.json"
LOCKFILE="$PLUGINS_DIR/plugin-lock.json"
VALIDATOR="$PLUGINS_DIR/validate-plugin.sh"

# Parse arguments
PLUGIN_SOURCE=""
PLUGIN_VERSION=""
DRY_RUN=false
FORCE=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --version)
            PLUGIN_VERSION="$2"
            shift 2
            ;;
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        --force)
            FORCE=true
            shift
            ;;
        -*)
            echo -e "${RED}Unknown option: $1${NC}"
            exit 1
            ;;
        *)
            PLUGIN_SOURCE="$1"
            shift
            ;;
    esac
done

if [ -z "$PLUGIN_SOURCE" ]; then
    echo -e "${RED}Error: Plugin name, URL, or path required${NC}"
    echo "Usage: install-plugin.sh <plugin-name | git-url | local-path> [--version X.Y.Z] [--dry-run] [--force]"
    exit 1
fi

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Codebuddy Plugin Installer${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# ==========================================
# Step 1: Determine source type
# ==========================================
SOURCE_TYPE=""
PLUGIN_NAME=""

if [[ "$PLUGIN_SOURCE" =~ ^https?:// ]]; then
    SOURCE_TYPE="git"
    PLUGIN_NAME=$(basename "$PLUGIN_SOURCE" .git)
    echo -e "${YELLOW}Source: Git repository${NC}"
    echo -e "  URL: $PLUGIN_SOURCE"
elif [[ "$PLUGIN_SOURCE" =~ ^git@ ]]; then
    SOURCE_TYPE="git"
    PLUGIN_NAME=$(basename "$PLUGIN_SOURCE" .git)
    echo -e "${YELLOW}Source: Git repository (SSH)${NC}"
    echo -e "  URL: $PLUGIN_SOURCE"
elif [ -d "$PLUGIN_SOURCE" ]; then
    SOURCE_TYPE="local"
    PLUGIN_NAME=$(basename "$PLUGIN_SOURCE")
    echo -e "${YELLOW}Source: Local directory${NC}"
    echo -e "  Path: $PLUGIN_SOURCE"
elif [ -f "$REGISTRY_FILE" ] && grep -q "\"$PLUGIN_SOURCE\"" "$REGISTRY_FILE"; then
    SOURCE_TYPE="registry"
    PLUGIN_NAME="$PLUGIN_SOURCE"
    echo -e "${YELLOW}Source: Plugin registry${NC}"
    echo -e "  Name: $PLUGIN_NAME"
else
    echo -e "${RED}Error: Unknown plugin source: $PLUGIN_SOURCE${NC}"
    echo "  Try: plugin name from registry, git URL, or local directory"
    exit 1
fi

echo ""

# ==========================================
# Step 2: Check if already installed
# ==========================================
if [ -d "$SKILLS_DIR/$PLUGIN_NAME" ]; then
    if [ "$FORCE" = true ]; then
        echo -e "${YELLOW}Plugin already installed, --force specified, will reinstall${NC}"
    else
        # Check version in lockfile
        if [ -f "$LOCKFILE" ] && command -v jq &> /dev/null; then
            INSTALLED_VERSION=$(jq -r ".plugins[\"$PLUGIN_NAME\"].version // empty" "$LOCKFILE" 2>/dev/null)
            if [ -n "$INSTALLED_VERSION" ]; then
                echo -e "${YELLOW}Plugin '$PLUGIN_NAME' v$INSTALLED_VERSION is already installed${NC}"
                echo -e "  Use --force to reinstall or --version to install specific version"
                exit 2
            fi
        fi
        echo -e "${YELLOW}Plugin '$PLUGIN_NAME' appears to be installed${NC}"
        echo -e "  Use --force to reinstall"
        exit 2
    fi
fi

# ==========================================
# Step 3: Get plugin info (for registry)
# ==========================================
if [ "$SOURCE_TYPE" = "registry" ]; then
    if command -v jq &> /dev/null; then
        REGISTRY_URL=$(jq -r ".plugins[\"$PLUGIN_NAME\"].repository // empty" "$REGISTRY_FILE" 2>/dev/null)
        REGISTRY_VERSION=$(jq -r ".plugins[\"$PLUGIN_NAME\"].version // empty" "$REGISTRY_FILE" 2>/dev/null)
        
        if [ -z "$REGISTRY_URL" ]; then
            echo -e "${RED}Error: Plugin '$PLUGIN_NAME' not found in registry${NC}"
            exit 1
        fi
        
        PLUGIN_SOURCE="$REGISTRY_URL"
        if [ -z "$PLUGIN_VERSION" ] && [ -n "$REGISTRY_VERSION" ]; then
            PLUGIN_VERSION="$REGISTRY_VERSION"
        fi
        SOURCE_TYPE="git"
        
        echo -e "${GREEN}Found in registry:${NC}"
        echo -e "  Repository: $PLUGIN_SOURCE"
        [ -n "$PLUGIN_VERSION" ] && echo -e "  Version: $PLUGIN_VERSION"
        echo ""
    else
        echo -e "${RED}Error: jq required for registry lookups${NC}"
        echo "  Install jq: apt install jq"
        exit 1
    fi
fi

# ==========================================
# Step 4: Fetch plugin (dry-run check)
# ==========================================
TEMP_DIR=""

if [ "$DRY_RUN" = true ]; then
    echo -e "${BLUE}[DRY RUN] Would fetch plugin from: $PLUGIN_SOURCE${NC}"
    TEMP_DIR="/tmp/plugin-dry-run-$PLUGIN_NAME"
    mkdir -p "$TEMP_DIR"
else
    TEMP_DIR=$(mktemp -d)
fi

if [ "$SOURCE_TYPE" = "git" ]; then
    echo -e "${BLUE}Fetching plugin from git...${NC}"
    
    if [ "$DRY_RUN" = true ]; then
        echo -e "  ${YELLOW}[DRY RUN] git clone ${PLUGIN_SOURCE}${PLUGIN_VERSION:+ --branch v$PLUGIN_VERSION} $TEMP_DIR${NC}"
    else
        if [ -n "$PLUGIN_VERSION" ]; then
            git clone --depth 1 --branch "v$PLUGIN_VERSION" "$PLUGIN_SOURCE" "$TEMP_DIR" 2>&1 || {
                echo -e "${YELLOW}Warning: Tag v$PLUGIN_VERSION not found, cloning default branch${NC}"
                git clone --depth 1 "$PLUGIN_SOURCE" "$TEMP_DIR" 2>&1
            }
        else
            git clone --depth 1 "$PLUGIN_SOURCE" "$TEMP_DIR" 2>&1
        fi
    fi
elif [ "$SOURCE_TYPE" = "local" ]; then
    echo -e "${BLUE}Copying plugin from local path...${NC}"
    
    if [ "$DRY_RUN" = true ]; then
        echo -e "  ${YELLOW}[DRY RUN] cp -r $PLUGIN_SOURCE $TEMP_DIR${NC}"
    else
        cp -r "$PLUGIN_SOURCE/"* "$TEMP_DIR/"
    fi
fi

echo ""

# ==========================================
# Step 5: Validate plugin format
# ==========================================
echo -e "${BLUE}Validating plugin format...${NC}"

if [ "$DRY_RUN" = true ]; then
    echo -e "  ${YELLOW}[DRY RUN] Would run: $VALIDATOR $TEMP_DIR${NC}"
else
    if [ -f "$VALIDATOR" ]; then
        if ! "$VALIDATOR" "$TEMP_DIR"; then
            echo ""
            echo -e "${RED}Error: Plugin validation failed${NC}"
            rm -rf "$TEMP_DIR"
            exit 1
        fi
    else
        echo -e "${YELLOW}Warning: Validator not found, skipping validation${NC}"
        # Basic checks
        if [ ! -f "$TEMP_DIR/SKILL.md" ]; then
            echo -e "${RED}Error: SKILL.md not found in plugin${NC}"
            rm -rf "$TEMP_DIR"
            exit 1
        fi
        if [ ! -f "$TEMP_DIR/plugin.json" ]; then
            echo -e "${RED}Error: plugin.json not found in plugin${NC}"
            rm -rf "$TEMP_DIR"
            exit 1
        fi
    fi
fi

echo ""

# ==========================================
# Step 6: Read plugin metadata
# ==========================================
PLUGIN_META_NAME="$PLUGIN_NAME"
PLUGIN_META_VERSION="1.0.0"
PLUGIN_META_DESC=""
PLUGIN_DEPS="{}"

if [ -f "$TEMP_DIR/plugin.json" ] && command -v jq &> /dev/null; then
    PLUGIN_META_NAME=$(jq -r '.name // "'"$PLUGIN_NAME"'"' "$TEMP_DIR/plugin.json")
    PLUGIN_META_VERSION=$(jq -r '.version // "1.0.0"' "$TEMP_DIR/plugin.json")
    PLUGIN_META_DESC=$(jq -r '.description // ""' "$TEMP_DIR/plugin.json")
    PLUGIN_DEPS=$(jq -c '.dependencies // {}' "$TEMP_DIR/plugin.json")
fi

echo -e "${GREEN}Plugin metadata:${NC}"
echo -e "  Name: $PLUGIN_META_NAME"
echo -e "  Version: $PLUGIN_META_VERSION"
[ -n "$PLUGIN_META_DESC" ] && echo -e "  Description: ${PLUGIN_META_DESC:0:60}..."
echo ""

# ==========================================
# Step 7: Check dependencies
# ==========================================
if [ "$PLUGIN_DEPS" != "{}" ] && [ "$PLUGIN_DEPS" != "null" ]; then
    echo -e "${BLUE}Checking dependencies...${NC}"
    
    # Parse dependencies
    DEP_NAMES=$(echo "$PLUGIN_DEPS" | jq -r 'keys[]' 2>/dev/null || true)
    
    for DEP in $DEP_NAMES; do
        DEP_VERSION=$(echo "$PLUGIN_DEPS" | jq -r ".[\"$DEP\"]" 2>/dev/null)
        
        if [ -d "$SKILLS_DIR/$DEP" ]; then
            echo -e "  ${GREEN}✓${NC} $DEP (installed)"
        else
            echo -e "  ${YELLOW}⚠${NC} $DEP $DEP_VERSION (missing)"
            echo -e "    ${YELLOW}Run: install-plugin.sh $DEP${NC}"
            
            if [ "$DRY_RUN" = false ]; then
                echo -e "${YELLOW}Would you like to install this dependency? [y/N]${NC}"
                # In non-interactive mode, skip
            fi
        fi
    done
    echo ""
fi

# ==========================================
# Step 8: Install plugin
# ==========================================
if [ "$DRY_RUN" = true ]; then
    echo -e "${BLUE}[DRY RUN] Would install to: $SKILLS_DIR/$PLUGIN_META_NAME${NC}"
    echo -e "${BLUE}[DRY RUN] Would update lockfile: $LOCKFILE${NC}"
else
    echo -e "${BLUE}Installing plugin...${NC}"
    
    # Create target directory
    mkdir -p "$SKILLS_DIR/$PLUGIN_META_NAME"
    
    # Copy plugin files
    cp -r "$TEMP_DIR/"* "$SKILLS_DIR/$PLUGIN_META_NAME/"
    
    echo -e "  ${GREEN}✓${NC} Installed to: $SKILLS_DIR/$PLUGIN_META_NAME"
    
    # Create default config
    CONFIG_FILE="$PLUGINS_DIR/$PLUGIN_META_NAME.config.md"
    if [ ! -f "$CONFIG_FILE" ]; then
        cat > "$CONFIG_FILE" << EOF
# $PLUGIN_META_NAME Configuration

## Installed
- Version: $PLUGIN_META_VERSION
- Date: $(date -Iseconds)
- Source: $PLUGIN_SOURCE

## Settings
<!-- Customize plugin settings here -->

EOF
        echo -e "  ${GREEN}✓${NC} Created config: $CONFIG_FILE"
    fi
    
    # Update lockfile
    if command -v jq &> /dev/null; then
        LOCK_CONTENT=$(cat "$LOCKFILE" 2>/dev/null || echo '{"version":"1.0.0","plugins":{}}')
        
        # Add plugin to lockfile
        echo "$LOCK_CONTENT" | jq --arg name "$PLUGIN_META_NAME" \
            --arg version "$PLUGIN_META_VERSION" \
            --arg source "$PLUGIN_SOURCE" \
            --arg date "$(date -Iseconds)" \
            --argjson deps "$PLUGIN_DEPS" \
            '.plugins[$name] = {
                "version": $version,
                "source": $source,
                "installed": $date,
                "dependencies": $deps
            }' > "$LOCKFILE"
        
        echo -e "  ${GREEN}✓${NC} Updated lockfile"
    fi
fi

# ==========================================
# Step 9: Cleanup
# ==========================================
if [ "$DRY_RUN" = false ] && [ -d "$TEMP_DIR" ]; then
    rm -rf "$TEMP_DIR"
fi

# ==========================================
# Summary
# ==========================================
echo ""
echo -e "${GREEN}========================================${NC}"
if [ "$DRY_RUN" = true ]; then
    echo -e "${GREEN}[DRY RUN] Installation plan complete${NC}"
else
    echo -e "${GREEN}✅ Plugin installed successfully!${NC}"
fi
echo -e "${GREEN}========================================${NC}"
echo ""
echo -e "Plugin: ${BLUE}$PLUGIN_META_NAME${NC} v$PLUGIN_META_VERSION"
echo -e "Location: $SKILLS_DIR/$PLUGIN_META_NAME"
echo ""
echo -e "Next steps:"
echo -e "  1. Restart Codebuddy to load the plugin"
echo -e "  2. Configure: $PLUGINS_DIR/$PLUGIN_META_NAME.config.md"
echo -e "  3. Validate: $VALIDATOR $SKILLS_DIR/$PLUGIN_META_NAME"

exit 0
