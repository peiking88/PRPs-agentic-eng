# Feature: Plugin Format Specification

## Summary

Define a standardized plugin structure that Codebuddy can recognize, load, and manage. This specification will enable the PRP framework and future plugins to be distributed as installable packages with consistent structure, metadata, and versioning.

## User Story

As a Codebuddy plugin developer
I want a standardized plugin format
So that my plugins can be easily installed, configured, and updated across projects

## Problem Statement

Codebuddy lacks a plugin system. Skills and commands must be manually copied between projects, leading to:
- Version drift across projects
- No standard way to discover or validate plugins
- No mechanism for updates or dependency management

## Solution Statement

Create a plugin format specification that defines:
1. Directory structure with SKILL.md entrypoint
2. Metadata schema (name, version, dependencies)
3. Configuration file format
4. Validation rules

## Metadata

| Field | Value |
|-------|-------|
| Type | NEW_CAPABILITY |
| Complexity | MEDIUM |
| Systems Affected | .claude/skills/, plugin-system |
| Dependencies | None (foundational) |
| Estimated Tasks | 7 |

---

## Mandatory Reading

| Priority | File | Lines | Why Read This |
|----------|------|-------|---------------|
| P0 | `.claude/skills/prp-framework/SKILL.md` | 1-50 | Existing skill structure to extend |
| P1 | `.claude/skills/prp-core-runner/SKILL.md` | 1-70 | Skill with frontmatter metadata |
| P2 | `.claude/PRPs/features/completed/add-prp-core-runner-skill.md` | 55-100 | Feature spec pattern to follow |

---

## UX Design

### Before State

```
╔═══════════════════════════════════════════════════════════╗
║                     BEFORE STATE                           ║
╠═══════════════════════════════════════════════════════════╣
║                                                            ║
║   Developer wants to use PRP in new project                ║
║                     ↓                                      ║
║   Manually copy .claude/skills/prp-framework/              ║
║                     ↓                                      ║
║   No version tracking                                      ║
║   No validation                                            ║
║   No update mechanism                                      ║
║                     ↓                                      ║
║   PROBLEM: Drift, errors, no updates                       ║
║                                                            ║
╚═══════════════════════════════════════════════════════════╝
```

### After State

```
╔═══════════════════════════════════════════════════════════╗
║                     AFTER STATE                            ║
╠═══════════════════════════════════════════════════════════╣
║                                                            ║
║   Developer wants to use PRP in new project                ║
║                     ↓                                      ║
║   /install-plugin prp-framework                            ║
║                     ↓                                      ║
║   Plugin validated against SPEC                            ║
║   Installed with version tracking                          ║
║   Configuration created                                    ║
║                     ↓                                      ║
║   SUCCESS: Versioned, validated, updatable                 ║
║                                                            ║
╚═══════════════════════════════════════════════════════════╝
```

### Interaction Changes

| Location | Before | After | User Impact |
|----------|--------|-------|-------------|
| `.claude/skills/` | Manual copy | Auto-installed | No manual setup |
| Plugin metadata | None | plugin.json | Version tracking |
| Configuration | Per-project manual | .claude/plugins/*.config.md | Standardized config |

---

## Patterns to Mirror

### SKILL.md Frontmatter (from prp-core-runner)

```markdown
// SOURCE: .claude/skills/prp-core-runner/SKILL.md:1-4
---
name: prp-core-runner
description: Orchestrate complete PRP workflow from feature request to pull request...
---
```

**Key aspects**:
- YAML frontmatter with name and description
- Description is used for skill discovery
- Name is kebab-case identifier

### Skill Directory Structure (from prp-framework)

```
// SOURCE: .claude/skills/prp-framework/
prp-framework/
├── SKILL.md                    # Main entrypoint
├── skills/                     # Nested sub-skills
│   ├── prp-prd/SKILL.md
│   ├── prp-plan/SKILL.md
│   └── ...
├── agents/                     # Specialized agents
│   └── ...
└── templates/                  # Resource files
    └── ...
```

**Key aspects**:
- SKILL.md as entrypoint at root
- Organized subdirectories for components
- Supports nested skills

---

## Files to Create

| File | Action | Justification |
|------|--------|---------------|
| `.claude/plugins/SPEC.md` | CREATE | Plugin format specification |
| `.claude/plugins/plugin.json` | CREATE | Plugin metadata schema |
| `.claude/skills/prp-framework/plugin.json` | CREATE | PRP framework plugin metadata |
| `.claude/plugins/validate-plugin.sh` | CREATE | Validation script |

---

## NOT Building (Scope Limits)

- Plugin installation command (Phase 2)
- Plugin registry (Phase 5)
- Plugin update mechanism (Phase 4)
- Private/paid plugin support
- Plugin marketplace UI

---

## Step-by-Step Tasks

### Task 1: CREATE `.claude/plugins/SPEC.md`

- **ACTION**: CREATE plugin format specification document
- **IMPLEMENT**: Define directory structure, metadata schema, validation rules
- **MIRROR**: Follow spec document patterns from `.claude/PRPs/features/completed/`
- **CONTENTS**:
  ```markdown
  # Codebuddy Plugin Format Specification v1.0
  
  ## Overview
  Define what a Codebuddy plugin is and how it should be structured.
  
  ## Directory Structure
  ```
  {plugin-name}/
  ├── SKILL.md           # Required: Main entrypoint
  ├── plugin.json        # Required: Metadata
  ├── skills/            # Optional: Nested skills
  ├── agents/            # Optional: Specialized agents
  ├── templates/         # Optional: Resource templates
  └── resources/         # Optional: Static resources
  ```
  
  ## Metadata Schema (plugin.json)
  ```json
  {
    "name": "plugin-name",
    "version": "1.0.0",
    "description": "Plugin description",
    "author": "Author Name",
    "license": "MIT",
    "minCodebuddyVersion": "1.0.0",
    "dependencies": {},
    "keywords": ["keyword1", "keyword2"],
    "repository": "https://github.com/user/plugin",
    "configSchema": {}
  }
  ```
  
  ## Validation Rules
  1. SKILL.md must exist at root
  2. SKILL.md must have YAML frontmatter with name/description
  3. plugin.json must be valid JSON
  4. version must follow semver
  5. name must be kebab-case, unique
  ```
- **VALIDATE**: Review specification for completeness

### Task 2: CREATE `.claude/plugins/plugin.json` (schema file)

- **ACTION**: CREATE JSON schema for plugin metadata
- **IMPLEMENT**: Define required and optional fields with types
- **CONTENTS**:
  ```json
  {
    "$schema": "http://json-schema.org/draft-07/schema#",
    "title": "Codebuddy Plugin Metadata",
    "type": "object",
    "required": ["name", "version", "description"],
    "properties": {
      "name": {
        "type": "string",
        "pattern": "^[a-z][a-z0-9-]*$",
        "description": "Unique plugin identifier in kebab-case"
      },
      "version": {
        "type": "string",
        "pattern": "^\\d+\\.\\d+\\.\\d+(-[a-z0-9.]+)?$",
        "description": "Semantic version"
      },
      "description": {
        "type": "string",
        "minLength": 10,
        "description": "Plugin description for discovery"
      },
      "author": { "type": "string" },
      "license": { "type": "string" },
      "minCodebuddyVersion": { "type": "string" },
      "dependencies": {
        "type": "object",
        "additionalProperties": { "type": "string" }
      },
      "keywords": {
        "type": "array",
        "items": { "type": "string" }
      },
      "repository": { "type": "string", "format": "uri" },
      "configSchema": { "type": "object" }
    }
  }
  ```
- **VALIDATE**: `cat .claude/plugins/plugin.json | jq .`

### Task 3: CREATE `.claude/skills/prp-framework/plugin.json`

- **ACTION**: CREATE metadata for existing PRP framework
- **IMPLEMENT**: Convert existing skill to plugin format
- **CONTENTS**:
  ```json
  {
    "name": "prp-framework",
    "version": "1.0.0",
    "description": "Product Requirements Prompts framework for AI-assisted development",
    "author": "PRP Team",
    "license": "MIT",
    "minCodebuddyVersion": "1.0.0",
    "dependencies": {},
    "keywords": ["prp", "prd", "planning", "implementation", "validation"],
    "repository": "https://github.com/user/prp-framework",
    "configSchema": {
      "artifactsPath": {
        "type": "string",
        "default": ".claude/PRPs/",
        "description": "Path to store PRP artifacts"
      },
      "maxIterations": {
        "type": "integer",
        "default": 20,
        "description": "Max iterations for Ralph loop"
      }
    }
  }
  ```
- **VALIDATE**: `cat .claude/skills/prp-framework/plugin.json | jq .`

### Task 4: CREATE `.claude/plugins/validate-plugin.sh`

- **ACTION**: CREATE validation script for plugin format
- **IMPLEMENT**: Check all validation rules from SPEC
- **CONTENTS**:
  ```bash
  #!/bin/bash
  # Plugin Format Validator
  # Usage: ./validate-plugin.sh <plugin-directory>
  
  set -e
  
  PLUGIN_DIR="${1:-.}"
  ERRORS=0
  
  echo "Validating plugin at: $PLUGIN_DIR"
  
  # Check SKILL.md exists
  if [ ! -f "$PLUGIN_DIR/SKILL.md" ]; then
    echo "❌ ERROR: SKILL.md not found at root"
    ERRORS=$((ERRORS + 1))
  else
    echo "✅ SKILL.md exists"
  fi
  
  # Check plugin.json exists and is valid JSON
  if [ ! -f "$PLUGIN_DIR/plugin.json" ]; then
    echo "❌ ERROR: plugin.json not found"
    ERRORS=$((ERRORS + 1))
  else
    if ! jq empty "$PLUGIN_DIR/plugin.json" 2>/dev/null; then
      echo "❌ ERROR: plugin.json is not valid JSON"
      ERRORS=$((ERRORS + 1))
    else
      echo "✅ plugin.json is valid JSON"
      
      # Check required fields
      NAME=$(jq -r '.name' "$PLUGIN_DIR/plugin.json")
      VERSION=$(jq -r '.version' "$PLUGIN_DIR/plugin.json")
      DESC=$(jq -r '.description' "$PLUGIN_DIR/plugin.json")
      
      if [ "$NAME" = "null" ] || [ -z "$NAME" ]; then
        echo "❌ ERROR: name field required"
        ERRORS=$((ERRORS + 1))
      else
        echo "✅ name: $NAME"
      fi
      
      if [[ ! "$VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+ ]]; then
        echo "❌ ERROR: version must be semver (x.y.z)"
        ERRORS=$((ERRORS + 1))
      else
        echo "✅ version: $VERSION"
      fi
      
      if [ "$DESC" = "null" ] || [ ${#DESC} -lt 10 ]; then
        echo "❌ ERROR: description must be at least 10 characters"
        ERRORS=$((ERRORS + 1))
      else
        echo "✅ description: ${DESC:0:50}..."
      fi
    fi
  fi
  
  # Summary
  echo ""
  if [ $ERRORS -eq 0 ]; then
    echo "✅ Plugin validation passed!"
    exit 0
  else
    echo "❌ Plugin validation failed with $ERRORS error(s)"
    exit 1
  fi
  ```
- **VALIDATE**: `chmod +x .claude/plugins/validate-plugin.sh && .claude/plugins/validate-plugin.sh .claude/skills/prp-framework/`

### Task 5: UPDATE `.claude/skills/prp-framework/SKILL.md`

- **ACTION**: ADD plugin metadata reference to existing skill
- **IMPLEMENT**: Add frontmatter with name matching plugin.json
- **MIRROR**: Follow pattern from `.claude/skills/prp-core-runner/SKILL.md:1-4`
- **CHANGE**: Add frontmatter at top:
  ```markdown
  ---
  name: prp-framework
  version: 1.0.0
  description: Product Requirements Prompts framework for AI-assisted development with structured workflows
  ---
  ```
- **VALIDATE**: Check SKILL.md still loads correctly

### Task 6: CREATE `.claude/plugins/README.md`

- **ACTION**: CREATE documentation for plugin system
- **IMPLEMENT**: Explain plugin format, how to create plugins, validation
- **CONTENTS**:
  ```markdown
  # Codebuddy Plugin System
  
  ## Overview
  
  Plugins extend Codebuddy with new skills, agents, and workflows.
  
  ## Plugin Structure
  
  ```
  {plugin-name}/
  ├── SKILL.md           # Required: Main entrypoint
  ├── plugin.json        # Required: Metadata
  └── ...                # Additional resources
  ```
  
  ## Creating a Plugin
  
  1. Create directory with plugin name (kebab-case)
  2. Add SKILL.md with frontmatter
  3. Add plugin.json with metadata
  4. Validate: `./validate-plugin.sh ./your-plugin`
  
  ## Validation
  
  Run the validator:
  ```bash
  .claude/plugins/validate-plugin.sh path/to/plugin
  ```
  
  ## Installing Plugins
  
  (Coming in Phase 2 - Install Command)
  
  ## Plugin Registry
  
  (Coming in Phase 5 - Registry)
  ```
- **VALIDATE**: Review for clarity

### Task 7: TEST validation against PRP framework

- **ACTION**: Run validation script on PRP framework
- **IMPLEMENT**: Verify plugin.json works with existing skill
- **COMMAND**: 
  ```bash
  cd /home/li/PRPs-agentic-eng
  .claude/plugins/validate-plugin.sh .claude/skills/prp-framework/
  ```
- **VALIDATE**: All checks pass

---

## Validation Commands

### Level 1: STATIC_ANALYSIS

```bash
# JSON validation
cat .claude/plugins/plugin.json | jq .
cat .claude/skills/prp-framework/plugin.json | jq .

# Script syntax
bash -n .claude/plugins/validate-plugin.sh
```

**EXPECT**: Exit 0, valid JSON and bash syntax

### Level 2: PLUGIN_VALIDATION

```bash
# Run validator on PRP framework
chmod +x .claude/plugins/validate-plugin.sh
.claude/plugins/validate-plugin.sh .claude/skills/prp-framework/
```

**EXPECT**: All validation checks pass

### Level 3: INTEGRATION_TEST

```bash
# Verify SKILL.md still loads correctly
# Check that frontmatter doesn't break skill loading
head -20 .claude/skills/prp-framework/SKILL.md
```

**EXPECT**: SKILL.md has valid frontmatter, content unchanged

---

## Acceptance Criteria

- [ ] SPEC.md defines complete plugin format
- [ ] plugin.json schema is valid JSON Schema
- [ ] PRP framework has valid plugin.json
- [ ] Validation script catches all specified errors
- [ ] PRP framework passes validation
- [ ] Documentation explains plugin creation

---

## Risks and Mitigations

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Schema too restrictive | MEDIUM | MEDIUM | Allow optional fields, extensibility |
| Breaking existing skills | LOW | HIGH | Frontmatter is backward compatible |
| Validator misses edge cases | MEDIUM | LOW | Iterative testing with real plugins |

---

## Notes

This phase establishes the foundation for the plugin system. It does NOT:
- Install plugins (Phase 2)
- Update plugins (Phase 4)
- Provide a registry (Phase 5)

The validation script is intentionally simple for v1. It can be enhanced in future phases to include:
- JSON Schema validation against the schema file
- Dependency version resolution
- Custom validation rules via configSchema
