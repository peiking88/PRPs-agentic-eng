# Feature: Plugin Configuration System

## Summary

Implement the configuration system that allows users to customize plugin behavior per project. This includes config file format, override mechanism, and validation of configuration values.

## User Story

As a Codebuddy user
I want to customize plugin settings for my project
So that the plugin works with my project's specific requirements

## Problem Statement

Plugins have default settings but:
- Users cannot override defaults per project
- No validation of configuration values
- No documentation of available settings

## Solution Statement

Create a configuration system that:
1. Reads plugin default config from `configSchema` in plugin.json
2. Allows user overrides in `.claude/plugins/{plugin-name}.config.md`
3. Validates configuration values against schema
4. Provides clear error messages for invalid config

## Metadata

| Field | Value |
|-------|-------|
| Type | NEW_CAPABILITY |
| Complexity | LOW |
| Systems Affected | .claude/plugins/ |
| Dependencies | Phase 1 (Plugin Format), Phase 2 (Install Command) |
| Estimated Tasks | 4 |

---

## Files to Create

| File | Action | Justification |
|------|--------|---------------|
| `.claude/plugins/scripts/validate-config.sh` | CREATE | Configuration validator script |
| `.claude/plugins/scripts/get-config.sh` | CREATE | Read config with defaults |
| `.claude/plugins/prp-framework.config.md` | CREATE | PRP framework default config |
| `.claude/commands/configure-plugin.md` | CREATE | Configure plugin command |

---

## Step-by-Step Tasks

### Task 1: CREATE `.claude/plugins/scripts/validate-config.sh`

Script that validates a plugin's configuration against its configSchema.

### Task 2: CREATE `.claude/plugins/scripts/get-config.sh`

Script that reads config values with proper defaults and overrides.

### Task 3: CREATE `.claude/plugins/prp-framework.config.md`

Default configuration for PRP framework with all settings documented.

### Task 4: CREATE `.claude/commands/configure-plugin.md`

Command for viewing and editing plugin configuration.

---

## Configuration File Format

### Config File Structure (Markdown)

```markdown
# {plugin-name} Configuration

## Meta
- **Plugin**: {plugin-name}
- **Version**: 1.0.0
- **Last Modified**: 2024-01-15

## Settings

### artifactsPath
- **Type**: string
- **Default**: .claude/PRPs/
- **Description**: Path to store PRP artifacts
- **Value**: .claude/PRPs/

### maxIterations
- **Type**: integer
- **Default**: 20
- **Min**: 1
- **Max**: 100
- **Description**: Maximum iterations for Ralph loop
- **Value**: 20

## Advanced Settings
<!-- Additional settings can be added here -->
```

### Config Resolution Order

1. **Defaults** from `plugin.json` configSchema
2. **Project overrides** from `.claude/plugins/{plugin-name}.config.md`
3. **Environment variables** (optional, for CI/CD)

---

## Validation Commands

### Level 1: SCRIPT_SYNTAX
```bash
bash -n .claude/plugins/scripts/validate-config.sh
bash -n .claude/plugins/scripts/get-config.sh
```

### Level 2: CONFIG_VALIDATION
```bash
# Validate PRP framework config
.claude/plugins/scripts/validate-config.sh prp-framework
```

### Level 3: INTEGRATION
```bash
# Get a config value
.claude/plugins/scripts/get-config.sh prp-framework artifactsPath
```

---

## Acceptance Criteria

- [ ] Config validator script works
- [ ] Config reader script works
- [ ] PRP framework has valid default config
- [ ] `/configure-plugin` command works
- [ ] Invalid configs are rejected with clear errors
