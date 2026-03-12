#!/bin/bash
# Codebuddy Plugin Configuration Validator
# Validates plugin configuration against configSchema
#
# Usage: validate-config.sh <plugin-name> [config-file]
#
# Exit codes:
#   0 - Valid
#   1 - Invalid or error

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

PLUGIN_NAME="${1:-}"
CONFIG_FILE="${2:-}"
CLAUDE_DIR=".claude"
PLUGINS_DIR="$CLAUDE_DIR/plugins"
SKILLS_DIR="$CLAUDE_DIR/skills"

if [ -z "$PLUGIN_NAME" ]; then
    echo -e "${RED}Error: Plugin name required${NC}"
    echo "Usage: validate-config.sh <plugin-name> [config-file]"
    exit 1
fi

# Find plugin directory
PLUGIN_DIR=""
if [ -d "$SKILLS_DIR/$PLUGIN_NAME" ]; then
    PLUGIN_DIR="$SKILLS_DIR/$PLUGIN_NAME"
elif [ -d "$PLUGINS_DIR/$PLUGIN_NAME" ]; then
    PLUGIN_DIR="$PLUGINS_DIR/$PLUGIN_NAME"
else
    echo -e "${RED}Error: Plugin '$PLUGIN_NAME' not found${NC}"
    exit 1
fi

# Find config file
if [ -z "$CONFIG_FILE" ]; then
    CONFIG_FILE="$PLUGINS_DIR/$PLUGIN_NAME.config.md"
fi

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Plugin Configuration Validator${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo "Plugin: $PLUGIN_NAME"
echo "Config: $CONFIG_FILE"
echo ""

# Check if config file exists
if [ ! -f "$CONFIG_FILE" ]; then
    echo -e "${YELLOW}Warning: Config file does not exist${NC}"
    echo -e "  Using default configuration"
    exit 0
fi

# Check if plugin.json exists
PLUGIN_JSON="$PLUGIN_DIR/plugin.json"
if [ ! -f "$PLUGIN_JSON" ]; then
    echo -e "${YELLOW}Warning: plugin.json not found, cannot validate schema${NC}"
    exit 0
fi

# Check for jq
if ! command -v jq &> /dev/null; then
    echo -e "${YELLOW}Warning: jq not installed, skipping schema validation${NC}"
    echo -e "  Install jq: apt install jq"
    exit 0
fi

# Extract configSchema
SCHEMA=$(jq -c '.configSchema // {}' "$PLUGIN_JSON" 2>/dev/null)

if [ "$SCHEMA" = "{}" ] || [ "$SCHEMA" = "null" ]; then
    echo -e "${GREEN}✓ No configSchema defined, config is valid${NC}"
    exit 0
fi

echo -e "${BLUE}Validating against schema...${NC}"
echo ""

ERRORS=0

# Parse config file (simple markdown key-value extraction)
# Format: "### key\n- **Value**: value"
while IFS= read -r line; do
    if [[ "$line" =~ ^###\ (.+)$ ]]; then
        KEY="${BASH_REMATCH[1]}"
    elif [[ "$line" =~ \*\*Value\*\*:\ (.+)$ ]] && [ -n "$KEY" ]; then
        VALUE="${BASH_REMATCH[1]}"
        
        # Get schema for this key
        KEY_SCHEMA=$(echo "$SCHEMA" | jq -c ".[\"$KEY\"] // empty" 2>/dev/null)
        
        if [ -n "$KEY_SCHEMA" ] && [ "$KEY_SCHEMA" != "null" ]; then
            KEY_TYPE=$(echo "$KEY_SCHEMA" | jq -r '.type // "string"')
            KEY_MIN=$(echo "$KEY_SCHEMA" | jq -r '.minimum // empty')
            KEY_MAX=$(echo "$KEY_SCHEMA" | jq -r '.maximum // empty')
            KEY_ENUM=$(echo "$KEY_SCHEMA" | jq -r '.enum // empty')
            KEY_DEFAULT=$(echo "$KEY_SCHEMA" | jq -r '.default // empty')
            
            # Validate type
            VALID=true
            case "$KEY_TYPE" in
                string)
                    # Always valid for string
                    ;;
                integer)
                    if ! [[ "$VALUE" =~ ^[0-9]+$ ]]; then
                        echo -e "${RED}✗ $KEY: Expected integer, got '$VALUE'${NC}"
                        VALID=false
                        ERRORS=$((ERRORS + 1))
                    else
                        # Check min/max
                        if [ -n "$KEY_MIN" ] && [ "$VALUE" -lt "$KEY_MIN" ]; then
                            echo -e "${RED}✗ $KEY: Value $VALUE is below minimum $KEY_MIN${NC}"
                            VALID=false
                            ERRORS=$((ERRORS + 1))
                        fi
                        if [ -n "$KEY_MAX" ] && [ "$VALUE" -gt "$KEY_MAX" ]; then
                            echo -e "${RED}✗ $KEY: Value $VALUE exceeds maximum $KEY_MAX${NC}"
                            VALID=false
                            ERRORS=$((ERRORS + 1))
                        fi
                    fi
                    ;;
                boolean)
                    if ! [[ "$VALUE" =~ ^(true|false)$ ]]; then
                        echo -e "${RED}✗ $KEY: Expected boolean (true/false), got '$VALUE'${NC}"
                        VALID=false
                        ERRORS=$((ERRORS + 1))
                    fi
                    ;;
                array)
                    # Simple array check
                    ;;
            esac
            
            if [ "$VALID" = true ]; then
                echo -e "${GREEN}✓ $KEY: $VALUE (${KEY_TYPE})${NC}"
            fi
        fi
        
        KEY=""
    fi
done < "$CONFIG_FILE"

# Check for required fields not in config
REQUIRED_KEYS=$(echo "$SCHEMA" | jq -r 'keys[]' 2>/dev/null || true)
for REQ_KEY in $REQUIRED_KEYS; do
    if ! grep -q "### $REQ_KEY" "$CONFIG_FILE" 2>/dev/null; then
        KEY_DEFAULT=$(echo "$SCHEMA" | jq -r ".[\"$REQ_KEY\"].default // empty" 2>/dev/null)
        if [ -n "$KEY_DEFAULT" ]; then
            echo -e "${YELLOW}○ $REQ_KEY: Using default ($KEY_DEFAULT)${NC}"
        fi
    fi
done

echo ""
echo -e "${GREEN}========================================${NC}"

if [ $ERRORS -eq 0 ]; then
    echo -e "${GREEN}✅ Configuration is valid${NC}"
    exit 0
else
    echo -e "${RED}❌ Configuration has $ERRORS error(s)${NC}"
    exit 1
fi
