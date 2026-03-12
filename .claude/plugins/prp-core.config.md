# prp-core Configuration

## Meta
- **Plugin**: prp-core
- **Version**: 2.4.0
- **Last Modified**: 2026-03-12

## Settings

### artifactsPath
- **Type**: string
- **Default**: .claude/PRPs/
- **Description**: Path to store PRP artifacts (PRDs, plans, reports)
- **Value**: .claude/PRPs/

### maxIterations
- **Type**: integer
- **Default**: 20
- **Min**: 1
- **Max**: 100
- **Description**: Maximum iterations for Ralph autonomous loop
- **Value**: 20

### autoArchive
- **Type**: boolean
- **Default**: true
- **Description**: Automatically archive completed plans to completed/ folder
- **Value**: true

## Commands Available

| Command | Description |
|---------|-------------|
| `/prp-prd` | Interactive PRD generator with implementation phases |
| `/prp-plan` | Create implementation plan (from PRD or free-form input) |
| `/prp-implement` | Execute a plan with validation loops |
| `/prp-issue-investigate` | Analyze GitHub issue, create implementation plan |
| `/prp-issue-fix` | Execute fix from investigation artifact |
| `/prp-research-team` | Design dynamic research team and plan |
| `/prp-commit` | Smart commit with natural language file targeting |
| `/prp-pr` | Create PR with template support |
| `/prp-review` | Comprehensive PR code review |
| `/prp-review-agents` | Multi-agent PR review |
| `/prp-debug` | Debug and fix issues in codebase |
| `/prp-ralph` | Autonomous implementation loop |
| `/prp-ralph-cancel` | Cancel running Ralph loop |
| `/prp-codebase-question` | Ask questions about codebase |

## Agents Available

| Agent | Description |
|-------|-------------|
| `codebase-analyst` | Documents HOW code works with file:line references |
| `codebase-explorer` | Finds WHERE code lives AND extracts patterns |
| `web-researcher` | Researches web for docs, APIs, best practices |
| `code-reviewer` | Project guidelines, bugs, type/module checks |
| `comment-analyzer` | Comment accuracy and maintainability |
| `pr-test-analyzer` | Test coverage quality and gaps |
| `silent-failure-hunter` | Error handling and silent failures |
| `type-design-analyzer` | Type encapsulation and invariants |
| `code-simplifier` | Clarity and maintainability improvements |
| `docs-impact-agent` | Updates stale documentation |

## Notes

- All paths are relative to project root
- Set maxIterations higher for complex features
- Disable autoArchive if you want to keep plans in active folder
