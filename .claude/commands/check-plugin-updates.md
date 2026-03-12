---
description: Check for plugin updates and show available versions
argument-hint: <plugin-name> [--json]
---

# Check Plugin Updates

Check if updates are available for installed plugins.

## Input

**Argument**: `$ARGUMENTS`

Parse:
- `PLUGIN_NAME`: Plugin name to check (optional, checks all if omitted)
- `--json`: Output in JSON format

## Usage

```
/check-plugin-updates                    # Check all installed plugins
/check-plugin-updates prp-framework      # Check specific plugin
/check-plugin-updates prp-framework --json
```

## Process

### Step 1: Read Installed Plugins

Load `.claude/plugins/plugin-lock.json`:

```json
{
  "plugins": {
    "prp-framework": {
      "version": "1.0.0",
      "source": "https://bgithub.xyz/codebuddy/prp-framework"
    }
  }
}
```

### Step 2: Check Remote Version

For each plugin:
1. Parse repository URL from lockfile
2. Fetch latest tag: `git ls-remote --tags <url>`
3. Compare versions using semver

### Step 3: Compare Versions

| Current | Latest | Status |
|---------|--------|--------|
| 1.0.0 | 1.0.0 | ✅ Up to date |
| 1.0.0 | 1.1.0 | 📦 Update available (minor) |
| 1.0.0 | 2.0.0 | ⚠️ Major update available |
| 1.0.0 | 0.9.0 | ⚠️ Downgrade? (check source) |

## Output

### Default Format

```markdown
## Plugin Updates

| Plugin | Current | Latest | Status |
|--------|---------|--------|--------|
| prp-framework | 1.0.0 | 1.1.0 | 📦 Update available |
| my-plugin | 2.0.0 | 2.0.0 | ✅ Up to date |

**Summary**: 1 update available
```

### JSON Format

```json
{
  "checked": "2024-01-15T10:00:00Z",
  "plugins": [
    {
      "name": "prp-framework",
      "current": "1.0.0",
      "latest": "1.1.0",
      "updateAvailable": true,
      "updateType": "minor"
    }
  ],
  "updatesAvailable": 1
}
```

## Examples

```bash
# Check all plugins
/check-plugin-updates

# Check specific plugin
/check-plugin-updates prp-framework

# JSON output
/check-plugin-updates --json
```
