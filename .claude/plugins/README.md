# Codebuddy Plugin System Documentation

## Overview

Codebuddy plugins extend functionality with new skills, commands, and workflows. This guide covers installation, configuration, and plugin development.

## Quick Start

### Install a Plugin

```bash
# From registry
/install-plugin prp-framework

# From git URL
/install-plugin https://github.com/user/my-plugin

# From local path
/install-plugin ./my-local-plugin
```

### Configure a Plugin

```bash
# View settings
/configure-plugin prp-framework

# Change setting
/configure-plugin prp-framework maxIterations --set 50
```

### Manage Plugins

```bash
# List installed
/list-plugins

# Check updates
/check-plugin-updates

# Update
/update-plugin prp-framework

# Uninstall
/uninstall-plugin prp-framework
```

---

## Plugin Commands Reference

| Command | Description |
|---------|-------------|
| `/install-plugin` | Install plugin from registry, git, or local |
| `/uninstall-plugin` | Remove installed plugin |
| `/list-plugins` | List installed plugins |
| `/configure-plugin` | View or edit plugin settings |
| `/search-plugins` | Search registry for plugins |
| `/check-plugin-updates` | Check for available updates |
| `/update-plugin` | Update plugin to newer version |

---

## Plugin Structure

```
{plugin-name}/
├── SKILL.md           # Required: Main entrypoint
├── plugin.json        # Required: Metadata
├── skills/            # Optional: Sub-skills
├── agents/            # Optional: Agent definitions
├── templates/         # Optional: Templates
└── scripts/           # Optional: Helper scripts
```

### SKILL.md Format

```markdown
---
name: my-plugin
description: What it does and when to use it. Include trigger phrases.
---

# My Plugin

## Instructions
...
```

### plugin.json Format

```json
{
  "name": "my-plugin",
  "version": "1.0.0",
  "description": "Plugin description",
  "author": "Author Name",
  "license": "MIT",
  "keywords": ["keyword1", "keyword2"],
  "configSchema": {
    "settingName": {
      "type": "string",
      "default": "value",
      "description": "Setting description"
    }
  }
}
```

---

## Configuration

### Configuration File Location

```
.claude/plugins/{plugin-name}.config.md
```

### Configuration Format

```markdown
# plugin-name Configuration

## Settings

### settingName
- **Type**: string
- **Default**: defaultValue
- **Description**: What this setting does
- **Value**: userValue
```

### Reading Configuration

```bash
# Get all settings
.claude/plugins/scripts/get-config.sh prp-framework

# Get specific value
.claude/plugins/scripts/get-config.sh prp-framework maxIterations
```

---

## Plugin Registry

### Default Registry

Located at `.claude/plugins/registry.json`:

```json
{
  "version": "1.0.0",
  "plugins": {
    "plugin-name": {
      "name": "plugin-name",
      "version": "1.0.0",
      "repository": "https://github.com/user/plugin"
    }
  }
}
```

### Adding Plugins to Registry

Edit `registry.json` to add new plugins:

```json
{
  "plugins": {
    "my-new-plugin": {
      "name": "my-new-plugin",
      "version": "1.0.0",
      "description": "Description",
      "repository": "https://github.com/user/my-new-plugin"
    }
  }
}
```

---

## Version Management

### Semantic Versioning

Plugins use semver: `MAJOR.MINOR.PATCH`

- **MAJOR**: Breaking changes
- **MINOR**: New features (backward compatible)
- **PATCH**: Bug fixes

### Checking Updates

```bash
# Check all plugins
/check-plugin-updates

# Check specific plugin
/check-plugin-updates prp-framework
```

### Updating

```bash
# Update to latest
/update-plugin prp-framework

# Update to specific version
/update-plugin prp-framework --version 1.2.0
```

---

## Creating a Plugin

### Step 1: Create Directory

```bash
mkdir -p my-plugin
```

### Step 2: Create SKILL.md

```markdown
---
name: my-plugin
description: My awesome plugin. Use when user says "my plugin" or "do my thing".
---

# My Plugin

## Instructions

Your plugin instructions here...
```

### Step 3: Create plugin.json

```json
{
  "name": "my-plugin",
  "version": "1.0.0",
  "description": "My awesome plugin",
  "author": "Your Name",
  "license": "MIT"
}
```

### Step 4: Validate

```bash
.claude/plugins/validate-plugin.sh ./my-plugin
```

### Step 5: Install

```bash
/install-plugin ./my-plugin
```

---

## Validation

### Validate Plugin

```bash
.claude/plugins/validate-plugin.sh .claude/skills/my-plugin
```

### Validate Configuration

```bash
.claude/plugins/scripts/validate-config.sh my-plugin
```

---

## Troubleshooting

### Plugin Not Loading

1. Validate plugin structure
2. Check SKILL.md frontmatter
3. Verify plugin.json syntax

```bash
.claude/plugins/validate-plugin.sh .claude/skills/plugin-name
```

### Installation Fails

1. Check network connectivity
2. Verify repository URL
3. Validate plugin after clone

### Configuration Not Applied

1. Validate config file
2. Check for schema violations
3. Restart Codebuddy

---

## Files Reference

| File | Purpose |
|------|---------|
| `.claude/plugins/SPEC.md` | Plugin format specification |
| `.claude/plugins/registry.json` | Plugin registry |
| `.claude/plugins/plugin-lock.json` | Installed plugins lockfile |
| `.claude/plugins/validate-plugin.sh` | Plugin validator |
| `.claude/plugins/scripts/` | Helper scripts |

---

## Available Plugins

| Plugin | Description |
|--------|-------------|
| prp-framework | Product Requirements Prompts for AI-assisted development |

---

*Last Updated: 2026-03-12*
