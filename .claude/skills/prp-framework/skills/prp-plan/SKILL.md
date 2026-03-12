---
name: prp-plan
description: Create comprehensive feature implementation plans with systematic codebase exploration, pattern extraction, and strategic research. Use when you have a PRD file ready for planning, when user wants to create an implementation plan, or when user says "create plan", "plan implementation", "/prp-plan", or mentions planning for a feature. Do NOT use for trivial changes, simple bug fixes, or when user wants direct code changes without planning - use standard coding workflow instead.
---

# PRP Plan Generator

## Overview

Create comprehensive feature implementation plans with systematic codebase exploration, pattern extraction, and strategic research.

**Trigger**: `/prp-plan <feature description | path/to/prd.md>`

## Objective

Transform input into a battle-tested implementation plan through:
1. **CODEBASE FIRST** - Discover existing patterns before introducing new ones
2. **RESEARCH SECOND** - External docs after understanding codebase
3. **PLAN ONLY** - No code written, just context-rich planning

---

## Phase 0: DETECT - Input Type Resolution

| Input Pattern | Type | Action |
|---------------|------|--------|
| Ends with `.prd.md` | PRD file | Parse PRD, select next phase |
| File path exists | Document | Read and extract feature description |
| Free-form text | Description | Use directly as feature input |

### If PRD File Detected:

1. Read the PRD file
2. Parse Implementation Phases table - find rows with `Status: pending`
3. Check dependencies - only select phases whose dependencies are `complete`
4. Extract phase context:
   ```
   PHASE: {phase number and name}
   GOAL: {from phase details}
   SCOPE: {from phase details}
   SUCCESS SIGNAL: {from phase details}
   PRD CONTEXT: {problem statement, user, hypothesis from PRD}
   ```
5. Report selection to user

---

## Phase 1: PARSE - Feature Understanding

**EXTRACT from input:**
- Core problem being solved
- User value and business impact
- Feature type: NEW_CAPABILITY | ENHANCEMENT | REFACTOR | BUG_FIX
- Complexity: LOW | MEDIUM | HIGH
- Affected systems list

**FORMULATE user story:**
```
As a <user type>
I want to <action/goal>
So that <benefit/value>
```

**GATE**: If requirements are AMBIGUOUS → STOP and ASK user for clarification.

---

## Phase 2: EXPLORE - Codebase Intelligence

**CRITICAL: Launch exploration agents in parallel.**

### Agent 1: Codebase Explorer

Find WHERE code lives and extract implementation patterns:

```
Find all code relevant to implementing: [feature description].

LOCATE:
1. Similar implementations - analogous features with file:line references
2. Naming conventions - actual examples of function/class/file naming
3. Error handling patterns - how errors are created, thrown, caught
4. Logging patterns - logger usage, message formats
5. Type definitions - relevant interfaces and types
6. Test patterns - test file structure, assertion styles
7. Configuration - relevant config files and settings
8. Dependencies - relevant libraries already in use

Return ACTUAL code snippets from codebase, not generic examples.
```

### Agent 2: Codebase Analyst

Analyze HOW integration points work and trace data flow:

```
Analyze the implementation details relevant to: [feature description].

TRACE:
1. Entry points - where new code will connect to existing code
2. Data flow - how data moves through related components
3. State changes - side effects in related functions
4. Contracts - interfaces and expectations between components
5. Patterns in use - design patterns and architectural decisions

Document with precise file:line references. No suggestions.
```

### Merge Agent Results

| Category | File:Lines | Pattern Description | Code Snippet |
|----------|------------|---------------------|--------------|
| NAMING | `src/features/X/service.ts:10-15` | camelCase functions | `export function createThing()` |
| ERRORS | `src/features/X/errors.ts:5-20` | Custom error classes | `class ThingNotFoundError` |
| LOGGING | `src/core/logging/index.ts:1-10` | getLogger pattern | `const logger = getLogger("domain")` |

---

## Phase 3: RESEARCH - External Documentation

**ONLY AFTER Phase 2** - solutions must fit existing codebase patterns first.

```
Research external documentation relevant to: [feature description].

FIND:
1. Official documentation for involved libraries (match versions)
2. Known gotchas, breaking changes, deprecations
3. Security considerations and best practices
4. Performance optimization patterns

Return findings with direct links to specific doc sections.
```

---

## Phase 4: DESIGN - UX Transformation

**CREATE ASCII diagrams showing user experience before and after:**

```
╔═══════════════════════════════════════════════════════════════╗
║                        BEFORE STATE                            ║
╠═══════════════════════════════════════════════════════════════╣
║   USER_FLOW: [current step-by-step experience]                 ║
║   PAIN_POINT: [what's missing, broken, or inefficient]         ║
║   DATA_FLOW: [how data moves currently]                        ║
╚═══════════════════════════════════════════════════════════════╝

╔═══════════════════════════════════════════════════════════════╗
║                        AFTER STATE                             ║
╠═══════════════════════════════════════════════════════════════╣
║   USER_FLOW: [new step-by-step experience]                     ║
║   VALUE_ADD: [what user gains from this change]                ║
║   DATA_FLOW: [how data moves after implementation]             ║
╚═══════════════════════════════════════════════════════════════╝
```

---

## Phase 5: ARCHITECT - Strategic Design

**ANALYZE:**
- ARCHITECTURE_FIT: How does this integrate with existing architecture?
- EXECUTION_ORDER: What must happen first → second → third?
- FAILURE_MODES: Edge cases, race conditions, error scenarios?
- PERFORMANCE: Will this scale?
- SECURITY: Attack vectors? Data exposure risks?
- MAINTAINABILITY: Will future devs understand this code?

**DECIDE:**
```markdown
APPROACH_CHOSEN: [description]
RATIONALE: [why this over alternatives - reference codebase patterns]

ALTERNATIVES_REJECTED:
- [Alternative 1]: Rejected because [specific reason]
- [Alternative 2]: Rejected because [specific reason]

NOT_BUILDING:
- [Item 1] - explicitly out of scope and why
```

---

## Phase 6: GENERATE - Implementation Plan File

**OUTPUT_PATH**: `.claude/PRPs/plans/{kebab-case-feature-name}.plan.md`

### Plan Structure

```markdown
# Feature: {Feature Name}

## Summary
{One paragraph: What we're building and high-level approach}

## User Story
As a {user type}
I want to {action}
So that {benefit}

## Problem Statement
{Specific problem this solves - must be testable}

## Solution Statement
{How we're solving it - architecture overview}

## Metadata

| Field | Value |
|-------|-------|
| Type | NEW_CAPABILITY / ENHANCEMENT / REFACTOR / BUG_FIX |
| Complexity | LOW / MEDIUM / HIGH |
| Systems Affected | {comma-separated list} |
| Dependencies | {external libs/services with versions} |

---

## Mandatory Reading

| Priority | File | Lines | Why Read This |
|----------|------|-------|---------------|
| P0 | `path/to/critical.ts` | 10-50 | Pattern to MIRROR exactly |
| P1 | `path/to/types.ts` | 1-30 | Types to IMPORT |
| P2 | `path/to/test.ts` | all | Test pattern to FOLLOW |

---

## Patterns to Mirror

### NAMING_CONVENTION
```typescript
// SOURCE: src/features/example/service.ts:10-15
{actual code snippet from codebase}
```

### ERROR_HANDLING
```typescript
// SOURCE: src/features/example/errors.ts:5-20
{actual code snippet from codebase}
```

### LOGGING_PATTERN
```typescript
// SOURCE: src/features/example/service.ts:25-30
{actual code snippet from codebase}
```

---

## Files to Change

| File | Action | Justification |
|------|--------|---------------|
| `src/features/new/models.ts` | CREATE | Type definitions |
| `src/features/new/service.ts` | CREATE | Business logic |

---

## NOT Building (Scope Limits)

- {Item 1 - explicitly out of scope and why}

---

## Step-by-Step Tasks

### Task 1: CREATE `src/features/new/models.ts`

- **ACTION**: CREATE type definitions file
- **IMPLEMENT**: Re-export table, define inferred types
- **MIRROR**: `src/features/projects/models.ts:1-10`
- **IMPORTS**: `import { things } from "@/core/database/schema"`
- **GOTCHA**: Use `$inferSelect` for read types
- **VALIDATE**: `npx tsc --noEmit`

### Task 2: CREATE `src/features/new/service.ts`

- **ACTION**: CREATE business logic layer
- **IMPLEMENT**: createThing, getThing, updateThing, deleteThing
- **MIRROR**: `src/features/projects/service.ts:1-80`
- **PATTERN**: Use repository, add logging, throw custom errors
- **VALIDATE**: `npx tsc --noEmit && npx eslint src/features/new/`

---

## Validation Commands

### Level 1: STATIC_ANALYSIS
```bash
{runner} run lint && {runner} run type-check
```
**EXPECT**: Exit 0, no errors or warnings

### Level 2: UNIT_TESTS
```bash
{runner} test {path/to/feature/tests}
```
**EXPECT**: All tests pass, coverage >= 80%

### Level 3: FULL_SUITE
```bash
{runner} test && {runner} run build
```
**EXPECT**: All tests pass, build succeeds

---

## Acceptance Criteria

- [ ] All specified functionality implemented per user story
- [ ] Level 1-3 validation commands pass with exit 0
- [ ] Unit tests cover >= 80% of new code
- [ ] Code mirrors existing patterns exactly
- [ ] No regressions in existing tests

---

## Risks and Mitigations

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| {Risk} | LOW/MED/HIGH | LOW/MED/HIGH | {Strategy} |
```

---

## Output Report

After creating plan:

```markdown
## Plan Created

**File**: `.claude/PRPs/plans/{feature-name}.plan.md`

{If from PRD:}
**Source PRD**: `{prd-file-path}`
**Phase**: #{number} - {phase name}

**Summary**: {2-3 sentence feature overview}

**Complexity**: {LOW/MEDIUM/HIGH}

**Scope**:
- {N} files to CREATE
- {M} files to UPDATE
- {K} total tasks

**Key Patterns Discovered**:
- {Pattern 1 with file:line}
- {Pattern 2 with file:line}

**Confidence Score**: {1-10}/10 for one-pass implementation success

**Next Step**: To execute, run: `/prp-implement .claude/PRPs/plans/{feature-name}.plan.md`
```

---

## Success Criteria

- **CONTEXT_COMPLETE**: All patterns documented with file:line references
- **IMPLEMENTATION_READY**: Tasks executable top-to-bottom without questions
- **PATTERN_FAITHFUL**: Every new file mirrors existing codebase style
- **VALIDATION_DEFINED**: Every task has executable verification command
- **UX_DOCUMENTED**: Before/After transformation is clear

---

## Usage Examples

### Example 1: Plan from PRD File

```
User: /prp-plan .claude/PRPs/prds/team-workspace.prd.md

AI:
## PRD Detected
**File**: .claude/PRPs/prds/team-workspace.prd.md
**Selected Phase**: #1 - Core (Workspace and project structure)

### Dependencies Check
- No dependencies (first phase)
- Phase 2 and 3 depend on this phase

Proceeding with Phase 1...

[Launching parallel agents...]

**codebase-explorer findings:**
- Similar feature exists at `src/features/projects/`
- Repository pattern used: `src/features/projects/repository.ts`
- Service pattern: `src/features/projects/service.ts`
- Test structure: `src/features/projects/__tests__/`

**codebase-analyst findings:**
- Auth middleware at `src/middleware/auth.ts:8-35`
- Database client at `src/core/database/client.ts`
- Logger at `src/core/logging/index.ts`

**web-researcher findings:**
- Drizzle ORM relations best practices: https://orm.drizzle.team/docs/relations
- Workspace permission models: RBAC vs ABAC

→ .claude/PRPs/plans/team-workspace-phase-1.plan.md

## Plan Created

**File**: `.claude/PRPs/plans/team-workspace-phase-1.plan.md`
**Phase**: #1 - Core

**Summary**: Create workspace and project data models, services, and API endpoints
following existing feature patterns.

**Complexity**: MEDIUM - 6 new files, integrates with existing auth and database

**Scope**:
- 6 files to CREATE
- 2 files to UPDATE
- 8 total tasks

**Key Patterns Discovered**:
- Repository pattern: `src/features/projects/repository.ts:1-60`
- Service pattern: `src/features/projects/service.ts:40-120`
- Error handling: `src/features/projects/errors.ts:5-40`

**Confidence Score**: 8/10
- Existing feature provides clear template
- Well-documented ORM patterns
- Auth integration straightforward

**Next Step**: `/prp-implement .claude/PRPs/plans/team-workspace-phase-1.plan.md`
```

### Example 2: Plan from Feature Description

```
User: /prp-plan "add dark mode toggle to settings page"

AI:
## Feature Parsed

**User Story**: As a user, I want to toggle dark mode, so I can reduce eye strain
**Type**: ENHANCEMENT
**Complexity**: LOW
**Affected Systems**: UI, settings, theme provider

[Launching exploration agents...]

**codebase-explorer findings:**
- Theme provider exists at `src/providers/theme-provider.tsx`
- Settings page at `src/pages/settings.tsx`
- Tailwind dark mode configured in `tailwind.config.js`
- No dark mode toggle component exists

**UX Transformation:**
```
╔═══════════════════════════════════════════╗
║ BEFORE: No theme toggle                    ║
║ Settings page has:                         ║
║ - Account section                          ║
║ - Notifications section                    ║
║ User must change system theme to switch    ║
╚═══════════════════════════════════════════╝

╔═══════════════════════════════════════════╗
║ AFTER: Theme toggle in settings            ║
║ Settings page has:                         ║
║ - Appearance section (NEW)                 ║
║   - Dark mode toggle                       ║
║   - Follow system option                   ║
║ Theme persists in localStorage             ║
╚═══════════════════════════════════════════╝
```

→ .claude/PRPs/plans/add-dark-mode-toggle.plan.md

## Plan Created

**File**: `.claude/PRPs/plans/add-dark-mode-toggle.plan.md`

**Summary**: Add dark mode toggle component to settings page using existing
theme provider infrastructure.

**Complexity**: LOW - 2 new components, 1 file update

**Scope**:
- 2 files to CREATE
- 1 file to UPDATE
- 4 total tasks

**Confidence Score**: 9/10
- Theme infrastructure already exists
- Simple UI addition
- Clear Tailwind pattern

**Next Step**: `/prp-implement .claude/PRPs/plans/add-dark-mode-toggle.plan.md`
```
