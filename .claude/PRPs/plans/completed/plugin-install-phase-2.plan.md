# Feature: Plugin Install Command

## Summary

Implement the `/install-plugin` and `/uninstall-plugin` commands that enable users to install plugins from a git-based registry or local path. This phase builds on the plugin format specification from Phase 1.

## User Story

As a Codebuddy user
I want to install plugins with a single command
So that I can quickly add new capabilities without manual file copying

## Problem Statement

Users must manually copy plugin files to `.claude/skills/`, leading to:
- No version tracking
- No dependency resolution
- No validation of installed plugins
- Difficult updates

## Solution Statement

Create install/uninstall commands that:
1. Fetch plugins from git repositories or local paths
2. Validate plugin format before installation
3. Handle version tracking via lockfile
4. Resolve dependencies recursively

## Metadata

| Field | Value |
|-------|-------|
| Type | NEW_CAPABILITY |
| Complexity | MEDIUM |
| Systems Affected | .claude/commands/, .claude/plugins/ |
| Dependencies | Phase 1 (Plugin Format) |
| Estimated Tasks | 6 |

---

## Files to Create

| File | Action | Justification |
|------|--------|---------------|
| `.claude/commands/install-plugin.md` | CREATE | Install command definition |
| `.claude/commands/uninstall-plugin.md` | CREATE | Uninstall command definition |
| `.claude/commands/list-plugins.md` | CREATE | List installed plugins command |
| `.claude/plugins/scripts/install-plugin.sh` | CREATE | Installation script |
| `.claude/plugins/plugin-lock.json` | CREATE | Lockfile for tracking installed plugins |
| `.claude/plugins/registry.json` | CREATE | Default plugin registry |

---

## Step-by-Step Tasks

### Task 1: CREATE `.claude/plugins/plugin-lock.json`

Initial empty lockfile structure:

```json
{
  "version": "1.0.0",
  "generated": "2024-01-15T00:00:00Z",
  "plugins": {}
}
```

### Task 2: CREATE `.claude/plugins/registry.json`

Default registry with known plugins:

```json
{
  "version": "1.0.0",
  "updated": "2024-01-15T00:00:00Z",
  "plugins": {
    "prp-framework": {
      "name": "prp-framework",
      "version": "1.0.0",
      "description": "Product Requirements Prompts framework",
      "repository": "https://bgithub.xyz/user/prp-framework",
      "keywords": ["prp", "prd", "planning", "implementation"]
    }
  }
}
```

### Task 3: CREATE `.claude/plugins/scripts/install-plugin.sh`

Installation script that:
- Validates input (plugin name or URL)
- Fetches plugin from registry or git URL
- Validates plugin format
- Installs to `.claude/skills/`
- Updates lockfile
- Handles dependencies

### Task 4: CREATE `.claude/commands/install-plugin.md`

Command definition for `/install-plugin`:

```markdown
---
description: Install a plugin from registry or URL
argument-hint: <plugin-name | git-url | local-path>
---

# Install Plugin

Install a Codebuddy plugin from:
- Plugin registry (by name)
- Git repository URL
- Local directory path

## Process

1. Parse argument to determine source type
2. Fetch plugin (from registry, git, or local)
3. Validate plugin format
4. Check dependencies
5. Install to .claude/skills/
6. Update plugin-lock.json
7. Run post-install validation
```

### Task 5: CREATE `.claude/commands/uninstall-plugin.md`

Command definition for `/uninstall-plugin`:

```markdown
---
description: Uninstall a previously installed plugin
argument-hint: <plugin-name>
---

# Uninstall Plugin

Remove an installed plugin:
1. Validate plugin is installed
2. Check for dependent plugins
3. Remove from .claude/skills/
4. Update plugin-lock.json
5. Clean up configuration
```

### Task 6: CREATE `.claude/commands/list-plugins.md`

Command definition for `/list-plugins`:

```markdown
---
description: List installed plugins and their versions
argument-hint: [--available] to show registry plugins
---

# List Plugins

Show installed plugins with:
- Name and version
- Installation date
- Dependencies
- Configuration status
```

---

## Validation Commands

### Level 1: SCRIPT_SYNTAX
```bash
bash -n .claude/plugins/scripts/install-plugin.sh
```

### Level 2: COMMAND_VALIDATION
```bash
# Check command files exist and have valid frontmatter
head -5 .claude/commands/install-plugin.md
head -5 .claude/commands/uninstall-plugin.md
head -5 .claude/commands/list-plugins.md
```

### Level 3: INTEGRATION_TEST
```bash
# Test install script on PRP framework (already installed)
.claude/plugins/scripts/install-plugin.sh prp-framework --dry-run
```

---

## Acceptance Criteria

- [ ] `/install-plugin` command works
- [ ] `/uninstall-plugin` command works
- [ ] `/list-plugins` command works
- [ ] Lockfile tracks installed plugins
- [ ] Plugin validation runs before installation
- [ ] Dependencies are checked

---

## Risks and Mitigations

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Git clone fails | MEDIUM | MEDIUM | Retry logic, fallback to local |
| Plugin already exists | HIGH | LOW | Update instead of error |
| Dependency cycle | LOW | MEDIUM | Detect and prevent cycles |
