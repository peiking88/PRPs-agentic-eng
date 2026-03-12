# Codebuddy Plugin Format Specification v1.0

## Overview

A Codebuddy plugin is a distributable package that extends Codebuddy with new skills, agents, templates, and workflows. This specification defines the standard structure, metadata format, and validation rules for plugins.

## Directory Structure

```
{plugin-name}/
├── SKILL.md           # Required: Main entrypoint with YAML frontmatter
├── plugin.json        # Required: Plugin metadata
├── skills/            # Optional: Nested sub-skills
│   └── {subskill}/SKILL.md
├── agents/            # Optional: Specialized agent definitions
│   └── {agent}.md
├── templates/         # Optional: Resource templates
│   └── {template}.md
├── scripts/           # Optional: Executable scripts
│   └── {script}.sh
└── resources/         # Optional: Static resources
    └── ...
```

### Required Files

| File | Purpose |
|------|---------|
| `SKILL.md` | Main entrypoint with instructions for the skill |
| `plugin.json` | Metadata including name, version, dependencies |

### Optional Directories

| Directory | Purpose |
|-----------|---------|
| `skills/` | Nested sub-skills for modular functionality |
| `agents/` | Specialized agent definitions |
| `templates/` | Reusable template files |
| `scripts/` | Executable helper scripts |
| `resources/` | Static resources (fonts, icons, etc.) |

## Metadata Schema (plugin.json)

### Required Fields

```json
{
  "name": "plugin-name",
  "version": "1.0.0",
  "description": "Plugin description for discovery"
}
```

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| `name` | string | kebab-case, unique | Unique plugin identifier |
| `version` | string | Semantic version (x.y.z) | Plugin version |
| `description` | string | min 10 chars | Description for discovery |

### Optional Fields

```json
{
  "name": "plugin-name",
  "version": "1.0.0",
  "description": "Plugin description",
  "author": "Author Name",
  "license": "MIT",
  "minCodebuddyVersion": "1.0.0",
  "keywords": ["keyword1", "keyword2"],
  "repository": "https://github.com/user/plugin",
  "dependencies": {
    "other-plugin": ">=1.0.0"
  },
  "configSchema": {
    "settingName": {
      "type": "string",
      "default": "value",
      "description": "Setting description"
    }
  },
  "files": [
    "SKILL.md",
    "skills/",
    "templates/"
  ]
}
```

| Field | Type | Description |
|-------|------|-------------|
| `author` | string | Plugin author |
| `license` | string | License identifier (MIT, Apache-2.0, etc.) |
| `minCodebuddyVersion` | string | Minimum Codebuddy version required |
| `keywords` | array | Keywords for discovery |
| `repository` | string | Source repository URL |
| `dependencies` | object | Other plugins required |
| `configSchema` | object | Configuration options schema |
| `files` | array | Files to include in distribution |

## SKILL.md Format

### YAML Frontmatter

The SKILL.md file must include YAML frontmatter:

```markdown
---
name: skill-name
description: What the skill does and when to use it. Include trigger phrases.
---

# Skill Title

## Instructions
...
```

### Frontmatter Fields

| Field | Required | Description |
|-------|----------|-------------|
| `name` | Yes | Skill identifier (kebab-case) |
| `description` | Yes | Description with WHAT and WHEN |
| `version` | No | Skill version if different from plugin |

## Validation Rules

A valid plugin must satisfy:

1. **Structure**
   - [ ] `SKILL.md` exists at root
   - [ ] `plugin.json` exists at root

2. **SKILL.md**
   - [ ] Has YAML frontmatter with `---` delimiters
   - [ ] Contains `name` field
   - [ ] Contains `description` field

3. **plugin.json**
   - [ ] Valid JSON syntax
   - [ ] Contains `name` field (kebab-case)
   - [ ] Contains `version` field (semver)
   - [ ] Contains `description` field (min 10 chars)

4. **Naming**
   - [ ] Plugin directory name matches `plugin.json` name
   - [ ] No reserved prefixes: `claude-*`, `anthropic-*`
   - [ ] No spaces or uppercase in name

## Installation Location

Plugins are installed to:

```
.claude/skills/{plugin-name}/
```

Configuration files are stored at:

```
.claude/plugins/{plugin-name}.config.md
```

## Version Management

### Semantic Versioning

Versions follow [SemVer 2.0](https://semver.org/):

- `MAJOR.MINOR.PATCH`
- Example: `1.0.0`, `2.1.3`, `0.1.0-alpha`

### Version Resolution

- `1.0.0` - Exact version
- `>=1.0.0` - Minimum version
- `^1.0.0` - Compatible version (same major)
- `~1.0.0` - Approximate version (same minor)

## Dependency Resolution

Plugins can declare dependencies:

```json
{
  "dependencies": {
    "prp-framework": ">=1.0.0",
    "code-reviewer": "^2.0.0"
  }
}
```

Dependencies are resolved recursively during installation.

## Configuration Schema

Plugins can define configurable options:

```json
{
  "configSchema": {
    "artifactsPath": {
      "type": "string",
      "default": ".claude/PRPs/",
      "description": "Path to store artifacts"
    },
    "maxIterations": {
      "type": "integer",
      "default": 20,
      "minimum": 1,
      "maximum": 100,
      "description": "Maximum loop iterations"
    },
    "enableFeatureX": {
      "type": "boolean",
      "default": true,
      "description": "Enable feature X"
    }
  }
}
```

### Supported Types

| Type | Example |
|------|---------|
| `string` | `"value"` |
| `integer` | `42` |
| `boolean` | `true` |
| `array` | `["a", "b"]` |
| `object` | `{"key": "value"}` |

## Distribution

### Package Format

Plugins are distributed as:

1. **Git repository** - Clone/pull from URL
2. **ZIP archive** - Download and extract
3. **Registry** - Central plugin registry (Phase 5)

### Package Contents

Distribution should include:
- All required files
- All optional directories referenced in `files` array
- README with usage instructions
- CHANGELOG for version history

## Security Considerations

- Plugins run with user's permissions
- Scripts should not execute arbitrary code without user consent
- Dependencies should be explicitly declared
- Sensitive configuration should be stored outside plugin directory

## Examples

### Minimal Plugin

```
my-plugin/
├── SKILL.md
└── plugin.json
```

```json
{
  "name": "my-plugin",
  "version": "1.0.0",
  "description": "A minimal Codebuddy plugin"
}
```

### Complex Plugin

```
prp-framework/
├── SKILL.md
├── plugin.json
├── skills/
│   ├── prp-prd/SKILL.md
│   ├── prp-plan/SKILL.md
│   ├── prp-implement/SKILL.md
│   └── prp-ralph/SKILL.md
├── agents/
│   ├── codebase-explorer.md
│   └── web-researcher.md
└── templates/
    ├── prp_base.md
    └── prp_planning.md
```

---

*Specification Version: 1.0.0*
*Last Updated: 2024-01-15*
