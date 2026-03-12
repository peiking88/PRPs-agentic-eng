---
description: Uninstall a previously installed Codebuddy plugin
argument-hint: <plugin-name> [--keep-config]
---

# Uninstall Plugin

Remove an installed plugin from Codebuddy.

## Input

**Argument**: `$ARGUMENTS`

Parse for:
- **Plugin name** (required): Name of plugin to uninstall
- `--keep-config`: Preserve configuration files

## Uninstallation Process

### Step 1: Validate Plugin Exists

Check if plugin is installed:

```bash
test -d .claude/skills/$PLUGIN_NAME && echo "INSTALLED" || echo "NOT_FOUND"
```

**If not found**:
```
Error: Plugin '{name}' is not installed

Installed plugins:
- prp-framework (v1.0.0)
- ...
```

### Step 2: Check for Dependent Plugins

Check if other plugins depend on this one:

```bash
jq -r '.plugins | to_entries[] | select(.value.dependencies["'$PLUGIN_NAME'"] != null) | .key' .claude/plugins/plugin-lock.json
```

**If dependents exist**:
```
Warning: The following plugins depend on '{name}':
  - dependent-plugin-1
  - dependent-plugin-2

These plugins may stop working. Continue? [y/N]
```

### Step 3: Remove Plugin Files

1. Remove plugin directory:
   ```bash
   rm -rf .claude/skills/$PLUGIN_NAME
   ```

2. Optionally remove config:
   ```bash
   rm -f .claude/plugins/$PLUGIN_NAME.config.md
   ```

### Step 4: Update Lockfile

Remove plugin from lockfile:

```bash
jq 'del(.plugins["'$PLUGIN_NAME'"])' .claude/plugins/plugin-lock.json > tmp.json && mv tmp.json .claude/plugins/plugin-lock.json
```

## Output Format

```markdown
## Plugin Uninstalled

**Name**: {plugin-name}
**Version**: {version} (was installed)
**Removed**: {timestamp}

### Cleanup
- ✅ Removed: .claude/skills/{plugin-name}/
- ✅ Removed: .claude/plugins/{plugin-name}.config.md
- ✅ Updated: plugin-lock.json

### Note
Any project-specific configuration should be manually cleaned up.
```

## Examples

```bash
# Basic uninstall
/uninstall-plugin my-plugin

# Keep configuration
/uninstall-plugin my-plugin --keep-config
```

## Confirmation Prompt

Before uninstalling, confirm with user:

```
About to uninstall: {plugin-name} v{version}

This will remove:
  - .claude/skills/{plugin-name}/
  - .claude/plugins/{plugin-name}.config.md

Continue? [y/N]
```
