---
description: Install a Codebuddy plugin from registry, git URL, or local path
argument-hint: <plugin-name | git-url | local-path> [--version X.Y.Z] [--dry-run] [--force]
---

# Install Plugin

Install a Codebuddy plugin to extend functionality.

## Input

**Argument**: `$ARGUMENTS`

Parse the argument to determine source type:
- **Plugin name**: Look up in registry (e.g., `prp-framework`)
- **Git URL**: Clone from repository (e.g., `https://github.com/user/plugin`)
- **Local path**: Copy from directory (e.g., `./my-plugin`)

**Options**:
- `--version X.Y.Z`: Install specific version (defaults to latest)
- `--dry-run`: Show what would be installed without making changes
- `--force`: Reinstall if already installed

## Installation Process

### Step 1: Parse Source

Determine source type from argument:

```
if ARGUMENTS matches "^https?://" → Git repository
if ARGUMENTS matches "^git@" → Git repository (SSH)
if ARGUMENTS is existing directory → Local path
else → Plugin name (registry lookup)
```

### Step 2: Check Registry (if plugin name)

Read `.claude/plugins/registry.json`:

```json
{
  "plugins": {
    "{plugin-name}": {
      "repository": "https://...",
      "version": "1.0.0"
    }
  }
}
```

### Step 3: Fetch Plugin

| Source | Action |
|--------|--------|
| Git URL | `git clone --depth 1 --branch vX.Y.Z <url> <temp-dir>` |
| Local | `cp -r <path> <temp-dir>` |
| Registry | Use repository URL from registry |

### Step 4: Validate Plugin Format

Run the validator:

```bash
.claude/plugins/validate-plugin.sh <temp-dir>
```

**If validation fails**:
- Report specific errors
- Do not proceed with installation
- Clean up temp directory

### Step 5: Check Dependencies

Read `plugin.json` dependencies:

```json
{
  "dependencies": {
    "other-plugin": ">=1.0.0"
  }
}
```

For each dependency:
1. Check if installed in `.claude/skills/`
2. Check version compatibility
3. If missing, prompt to install

### Step 6: Install Plugin

1. Create target directory: `.claude/skills/{plugin-name}/`
2. Copy plugin files
3. Create default config: `.claude/plugins/{plugin-name}.config.md`

### Step 7: Update Lockfile

Update `.claude/plugins/plugin-lock.json`:

```json
{
  "version": "1.0.0",
  "generated": "2024-01-15T10:00:00Z",
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

## Output Format

```markdown
## Plugin Installed

**Name**: {plugin-name}
**Version**: {version}
**Source**: {source}
**Location**: `.claude/skills/{plugin-name}/`

### Next Steps
1. Restart Codebuddy to load the plugin
2. Configure: `.claude/plugins/{plugin-name}.config.md`
3. Validate: `.claude/plugins/validate-plugin.sh .claude/skills/{plugin-name}/`
```

## Error Handling

| Error | Message | Action |
|-------|---------|--------|
| Plugin not found | "Plugin '{name}' not found in registry" | Suggest alternatives |
| Validation failed | "Plugin validation failed: {errors}" | Show specific errors |
| Already installed | "Plugin already installed (v{x.y.z})" | Suggest --force or --version |
| Dependency missing | "Missing dependency: {dep}" | Prompt to install |

## Examples

```bash
# Install from registry
/install-plugin prp-framework

# Install specific version
/install-plugin prp-framework --version 1.2.0

# Install from git
/install-plugin https://github.com/user/my-plugin

# Install from local path
/install-plugin ./plugins/my-custom-plugin

# Dry run
/install-plugin prp-framework --dry-run

# Reinstall
/install-plugin prp-framework --force
```

## Validation Commands

After installation, run:

```bash
# Validate the installed plugin
.claude/plugins/validate-plugin.sh .claude/skills/{plugin-name}

# Check lockfile
cat .claude/plugins/plugin-lock.json | jq .
```
