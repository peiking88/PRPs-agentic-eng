#!/bin/bash
# Codebuddy Plugin Configuration Reader
# Reads configuration value with defaults and overrides
#
# Usage: get-config.sh <plugin-name> [key]
#
# Output: Config value (or JSON object if no key specified)

set -e

PLUGIN_NAME="${1:-}"
KEY="${2:-}"
CLAUDE_DIR=".claude"
PLUGINS_DIR="$CLAUDE_DIR/plugins"
SKILLS_DIR="$CLAUDE_DIR/skills"

if [ -z "$PLUGIN_NAME" ]; then
    echo "Error: Plugin name required" >&2
    echo "Usage: get-config.sh <plugin-name> [key]" >&2
    exit 1
fi

# Find plugin directory
PLUGIN_DIR=""
if [ -d "$SKILLS_DIR/$PLUGIN_NAME" ]; then
    PLUGIN_DIR="$SKILLS_DIR/$PLUGIN_NAME"
elif [ -d "$PLUGINS_DIR/$PLUGIN_NAME" ]; then
    PLUGIN_DIR="$PLUGINS_DIR/$PLUGIN_NAME"
else
    echo "Error: Plugin '$PLUGIN_NAME' not found" >&2
    exit 1
fi

# Default config file
CONFIG_FILE="$PLUGINS_DIR/$PLUGIN_NAME.config.md"
PLUGIN_JSON="$PLUGIN_DIR/plugin.json"

# Initialize config object
CONFIG="{}"

# Load defaults from plugin.json
if [ -f "$PLUGIN_JSON" ] && command -v jq &> /dev/null; then
    DEFAULTS=$(jq -c '.configSchema | to_entries | map({(.key): .value.default}) | add // {}' "$PLUGIN_JSON" 2>/dev/null || echo "{}")
    if [ "$DEFAULTS" != "null" ] && [ "$DEFAULTS" != "" ]; then
        CONFIG="$DEFAULTS"
    fi
fi

# Load overrides from config file
if [ -f "$CONFIG_FILE" ]; then
    KEY_TEMP=""
    while IFS= read -r line; do
        if [[ "$line" =~ ^###\ (.+)$ ]]; then
            KEY_TEMP="${BASH_REMATCH[1]}"
        elif [[ "$line" =~ \*\*Value\*\*:\ (.+)$ ]] && [ -n "$KEY_TEMP" ]; then
            VALUE="${BASH_REMATCH[1]}"
            
            # Add to config JSON
            if command -v jq &> /dev/null; then
                # Determine if value is number or string
                if [[ "$VALUE" =~ ^[0-9]+$ ]]; then
                    CONFIG=$(echo "$CONFIG" | jq --arg k "$KEY_TEMP" --argjson v "$VALUE" '.[$k] = $v')
                elif [[ "$VALUE" =~ ^(true|false)$ ]]; then
                    CONFIG=$(echo "$CONFIG" | jq --arg k "$KEY_TEMP" --argjson v "$VALUE" '.[$k] = $v')
                else
                    CONFIG=$(echo "$CONFIG" | jq --arg k "$KEY_TEMP" --arg v "$VALUE" '.[$k] = $v')
                fi
            fi
            
            KEY_TEMP=""
        fi
    done < "$CONFIG_FILE"
fi

# Output
if [ -z "$KEY" ]; then
    # Output all config as JSON
    echo "$CONFIG"
else
    # Output specific key
    if command -v jq &> /dev/null; then
        VALUE=$(echo "$CONFIG" | jq -r ".[\"$KEY\"] // empty" 2>/dev/null)
        if [ -n "$VALUE" ] && [ "$VALUE" != "null" ]; then
            echo "$VALUE"
        else
            echo "Error: Key '$KEY' not found in config" >&2
            exit 1
        fi
    else
        echo "Error: jq required for config reading" >&2
        exit 1
    fi
fi
