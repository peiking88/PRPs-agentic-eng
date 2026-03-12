---
description: List installed Codebuddy plugins and their status
argument-hint: [--available] [--json]
---

# List Plugins

Display information about installed plugins.

## Input

**Argument**: `$ARGUMENTS`

**Options**:
- `--available`: Show plugins available in registry (not just installed)
- `--json`: Output in JSON format

## Process

### Step 1: Read Lockfile

Parse `.claude/plugins/plugin-lock.json`:

```json
{
  "version": "1.0.0",
  "plugins": {
    "prp-framework": {
      "version": "1.0.0",
      "source": "https://github.com/user/prp-framework",
      "installed": "2024-01-15T10:00:00Z",
      "dependencies": {}
    }
  }
}
```

### Step 2: Read Registry (if --available)

Parse `.claude/plugins/registry.json` for available plugins.

### Step 3: Check Plugin Status

For each plugin, verify:
- Directory exists in `.claude/skills/`
- Config file exists
- Validation passes

## Output Format

### Default Output

```markdown
## Installed Plugins

| Name | Version | Status | Dependencies |
|------|---------|--------|--------------|
| prp-framework | 1.0.0 | ✅ Valid | - |
| my-plugin | 0.5.0 | ⚠️ Missing config | prp-framework |

**Total**: 2 plugins installed
```

### With --available

```markdown
## Available Plugins

### Installed

| Name | Version | Status |
|------|---------|--------|
| prp-framework | 1.0.0 | ✅ Installed |

### Available in Registry

| Name | Version | Description |
|------|---------|-------------|
| code-reviewer | 2.0.0 | Automated code review |
| test-generator | 1.0.0 | Generate tests from code |

**Install with**: `/install-plugin <name>`
```

### With --json

```json
{
  "installed": [
    {
      "name": "prp-framework",
      "version": "1.0.0",
      "status": "valid",
      "location": ".claude/skills/prp-framework",
      "installed": "2024-01-15T10:00:00Z"
    }
  ],
  "total": 1
}
```

## Status Indicators

| Status | Meaning |
|--------|---------|
| ✅ Valid | Plugin passes validation |
| ⚠️ Missing config | Installed but no config file |
| ❌ Invalid | Plugin fails validation |
| 📦 Not installed | Available in registry |

## Examples

```bash
# List installed plugins
/list-plugins

# Show available plugins from registry
/list-plugins --available

# JSON output for scripting
/list-plugins --json

# Combine options
/list-plugins --available --json
```
