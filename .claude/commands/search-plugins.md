---
description: Search and browse available plugins in the registry
argument-hint: [search-term] [--category <name>] [--json]
---

# Search Plugins

Search for plugins in the registry.

## Input

**Argument**: `$ARGUMENTS`

Parse:
- `SEARCH_TERM`: Optional search term
- `--category <name>`: Filter by category
- `--json`: JSON output

## Usage

```
/search-plugins                    # List all plugins
/search-plugins prp                # Search for "prp"
/search-plugins --category workflow
/search-plugins --json
```

## Process

### Step 1: Load Registry

Read `.claude/plugins/registry.json`:

```json
{
  "version": "1.0.0",
  "plugins": {
    "prp-framework": {
      "name": "prp-framework",
      "description": "...",
      "keywords": [...],
      "category": "productivity"
    }
  },
  "categories": {
    "productivity": ["prp-framework"]
  }
}
```

### Step 2: Filter Results

| Filter | Action |
|--------|--------|
| Search term | Match name, description, keywords |
| Category | Filter by category field |

### Step 3: Format Output

Display matching plugins with details.

## Output

### Default Format

```markdown
## Available Plugins

### prp-framework
- **Version**: 1.0.0
- **Description**: Product Requirements Prompts framework...
- **Category**: productivity
- **Keywords**: prp, prd, planning, implementation
- **Install**: `/install-plugin prp-framework`

---
**Total**: 1 plugin found
```

### JSON Format

```json
{
  "query": "prp",
  "total": 1,
  "plugins": [
    {
      "name": "prp-framework",
      "version": "1.0.0",
      "description": "...",
      "category": "productivity"
    }
  ]
}
```

## Categories

| Category | Description |
|----------|-------------|
| productivity | Workflow and automation tools |
| development | Code generation and analysis |
| integration | External service connectors |
| testing | Test automation tools |

## Examples

```bash
# List all
/search-plugins

# Search
/search-plugins validation

# By category
/search-plugins --category productivity

# JSON output
/search-plugins --json
```
