---
description: Update a plugin to the latest or specific version
argument-hint: <plugin-name> [--version X.Y.Z] [--force]
---

# Update Plugin

Update an installed plugin to a newer version.

## Input

**Argument**: `$ARGUMENTS`

Parse:
- `PLUGIN_NAME`: Plugin to update (required)
- `--version X.Y.Z`: Target version (defaults to latest)
- `--force`: Skip confirmation prompt

## Usage

```
/update-plugin prp-framework              # Update to latest
/update-plugin prp-framework --version 1.2.0
/update-plugin prp-framework --force
```

## Process

### Step 1: Check Current Version

Read from `.claude/plugins/plugin-lock.json`:

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

### Step 2: Fetch Available Versions

```bash
git ls-remote --tags <repository-url>
```

Parse versions using semver, find:
- Latest stable version
- Available versions list

### Step 3: Confirm Update

Show update details:

```markdown
## Update Available

**Plugin**: prp-framework
**Current**: 1.0.0
**Target**: 1.2.0
**Type**: Minor update

### Changes
- New features: [...]
- Bug fixes: [...]
- Breaking changes: None

Proceed with update? [y/N]
```

### Step 4: Backup Current Version

```bash
# Backup existing plugin
cp -r .claude/skills/prp-framework .claude/skills/prp-framework.bak
```

### Step 5: Download New Version

```bash
# Fetch specific version
git clone --depth 1 --branch vX.Y.Z <url> <temp-dir>
```

### Step 6: Validate New Version

Run validator:
```bash
.claude/plugins/validate-plugin.sh <temp-dir>
```

### Step 7: Apply Update

1. Remove old version
2. Install new version
3. Update lockfile
4. Run migration if needed

### Step 8: Update Lockfile

```json
{
  "plugins": {
    "prp-framework": {
      "version": "1.2.0",
      "source": "https://bgithub.xyz/codebuddy/prp-framework",
      "updated": "2024-01-15T10:30:00Z",
      "previousVersion": "1.0.0"
    }
  }
}
```

## Output

### Success

```markdown
## Plugin Updated

**Plugin**: prp-framework
**Version**: 1.0.0 → 1.2.0
**Location**: .claude/skills/prp-framework/

✅ Update completed successfully
```

### No Update Needed

```markdown
## Already Up to Date

**Plugin**: prp-framework
**Version**: 1.2.0 (latest)

✅ No update needed
```

## Rollback

If update fails:
```bash
# Restore backup
mv .claude/skills/prp-framework.bak .claude/skills/prp-framework
```

## Examples

```bash
# Update to latest
/update-plugin prp-framework

# Update to specific version
/update-plugin prp-framework --version 1.2.0

# Skip confirmation
/update-plugin prp-framework --force
```
