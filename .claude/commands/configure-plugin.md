---
description: View or edit plugin configuration settings
argument-hint: <plugin-name> [key] [--set value] [--reset]
---

# Configure Plugin

View or modify plugin configuration settings.

## Input

**Argument**: `$ARGUMENTS`

**Usage**:
- `/configure-plugin <plugin-name>` - View all settings
- `/configure-plugin <plugin-name> <key>` - View specific setting
- `/configure-plugin <plugin-name> <key> --set <value>` - Set a value
- `/configure-plugin <plugin-name> --reset` - Reset to defaults
- `/configure-plugin <plugin-name> --reset <key>` - Reset specific key

## Process

### Step 1: Parse Arguments

```
PLUGIN_NAME = first argument
KEY = second argument (if not a flag)
ACTION = view | set | reset
VALUE = value after --set
```

### Step 2: Locate Plugin and Config

1. Find plugin in `.claude/skills/{plugin-name}/`
2. Read `plugin.json` for configSchema
3. Find or create config file at `.claude/plugins/{plugin-name}.config.md`

### Step 3: Execute Action

#### View Mode (default)

Display configuration with current values and defaults:

```markdown
## Plugin Configuration: prp-framework

| Setting | Type | Default | Current | Description |
|---------|------|---------|---------|-------------|
| artifactsPath | string | .claude/PRPs/ | .claude/PRPs/ | Path to store artifacts |
| maxIterations | integer | 20 | 30 | Max Ralph iterations |
| validationLevels | integer | 3 | 3 | Validation depth |
| autoArchive | boolean | true | true | Auto-archive plans |
```

#### Set Mode

1. Validate value against schema (type, min/max, enum)
2. Update config file with new value
3. Run validator to confirm
4. Report success or error

Example:
```bash
/configure-plugin prp-framework maxIterations --set 50
```

Output:
```
✅ Updated maxIterations: 20 → 50

Validation: passed
Config file: .claude/plugins/prp-framework.config.md
```

#### Reset Mode

1. Remove overrides from config file
2. Restore defaults from plugin.json
3. Report changes

Example:
```bash
/configure-plugin prp-framework maxIterations --reset
```

Output:
```
✅ Reset maxIterations to default: 50 → 20
```

### Step 4: Validate Changes

After any modification, run:
```bash
.claude/plugins/scripts/validate-config.sh <plugin-name>
```

## Config File Format

The config file uses Markdown for readability:

```markdown
# plugin-name Configuration

## Settings

### settingName
- **Type**: string
- **Default**: defaultValue
- **Description**: What this setting does
- **Value**: userValue
```

## Schema Validation

Settings are validated against `configSchema` in `plugin.json`:

```json
{
  "configSchema": {
    "maxIterations": {
      "type": "integer",
      "default": 20,
      "minimum": 1,
      "maximum": 100,
      "description": "Maximum loop iterations"
    }
  }
}
```

## Error Messages

| Error | Cause | Solution |
|-------|-------|----------|
| "Plugin not found" | Plugin name doesn't exist | Check spelling with `/list-plugins` |
| "Key not in schema" | Unknown setting | View available keys with `/configure-plugin <name>` |
| "Invalid value" | Type mismatch or out of range | Check schema constraints |
| "Config file not found" | First time configuring | Will be created automatically |

## Examples

```bash
# View all settings for PRP framework
/configure-plugin prp-framework

# View specific setting
/configure-plugin prp-framework maxIterations

# Change a setting
/configure-plugin prp-framework maxIterations --set 50

# Reset to defaults
/configure-plugin prp-framework --reset

# Reset specific setting
/configure-plugin prp-framework maxIterations --reset
```

## Integration

This command works with:
- `/install-plugin` - Creates default config on install
- `/list-plugins` - Shows config status
- `.claude/plugins/scripts/validate-config.sh` - Validates config
- `.claude/plugins/scripts/get-config.sh` - Reads config values
