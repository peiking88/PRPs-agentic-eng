---
name: prp-framework
version: 1.0.0
description: Product Requirements Prompts framework for AI-assisted development with structured workflows, validation loops, and autonomous execution. Use when creating new features with clear requirements, planning implementation from PRDs, executing implementation plans with validation, running autonomous implementation loops, or when user mentions "PRP", "PRD", "product requirements prompt", "create PRD", "implement plan". Do NOT use for simple bug fixes, quick code changes, or one-off edits - use standard coding workflow instead. Includes sub-skills: prp-prd, prp-plan, prp-implement, prp-ralph.
---

# PRP Framework - Product Requirements Prompts for Codebuddy

## Description

A comprehensive framework for AI-assisted development with structured Product Requirement Prompts (PRPs). PRPs combine traditional PRDs with AI-specific context to enable one-pass implementation success.

**Use this skill when:**
- Creating new features with clear requirements
- Planning implementation from PRDs or feature descriptions
- Executing implementation plans with validation
- Running autonomous implementation loops
- Investigating and fixing issues systematically

## Core Concepts

### What is a PRP?

A PRP (Product Requirements Prompt) differs from a traditional PRD by adding three AI-critical layers:

| Layer | Description |
|-------|-------------|
| **Context** | Precise file paths, library versions, code snippets, documentation |
| **Implementation Details** | Explicit how-to-build specifications including patterns, API endpoints |
| **Validation Gates** | Executable commands (tests, lint, type-check) that verify correctness |

### Workflow Patterns

1. **Large Features**: PRD → Plan → Implement → (repeat for next phase)
2. **Medium Features**: Direct Plan → Implement
3. **Bug Fixes**: Issue Investigate → Issue Fix

## Available Sub-Skills

| Skill | Trigger | Description |
|-------|---------|-------------|
| `prp-prd` | `/prp-prd [feature]` | Interactive PRD generator with implementation phases |
| `prp-plan` | `/prp-plan [description\|prd.md]` | Create implementation plan with codebase analysis |
| `prp-implement` | `/prp-implement plan.md` | Execute plan with rigorous validation loops |
| `prp-ralph` | `/prp-ralph plan.md\|prd.md` | Autonomous loop until all validations pass |

## Quick Start

### Create a new feature from scratch

```
/prp-prd "user authentication system"
# → Creates PRD with Implementation Phases

/prp-plan .claude/PRPs/prds/user-auth.prd.md
# → Selects next phase, creates implementation plan

/prp-implement .claude/PRPs/plans/user-auth-phase-1.plan.md
# → Executes plan, validates, creates report
```

### Implement a medium feature directly

```
/prp-plan "add pagination to the API"
# → Creates plan directly from description

/prp-implement .claude/PRPs/plans/add-pagination.plan.md
# → Execute with validation
```

### Autonomous execution

```
/prp-ralph .claude/PRPs/plans/feature.plan.md --max-iterations 20
# → Runs autonomously until all validations pass
```

## Usage Examples

### Example 1: Building a New Feature from Scratch

**Scenario**: You want to build a user notification system.

```
Step 1: Generate PRD
────────────────────
User: /prp-prd "user notification system"

AI asks clarifying questions:
> What do you want to build?
> I understand you want to build: A system to notify users about important events...
> Is this correct?

User: Yes, users should get email and in-app notifications

AI continues with foundation questions:
> Foundation Questions:
> 1. Who has this problem?
> 2. What problem are they facing?
> ...

After research and Q&A, AI generates:
→ .claude/PRPs/prds/user-notifications.prd.md

The PRD contains:
- Problem Statement
- Key Hypothesis
- Implementation Phases table with 4 phases:
  | # | Phase | Description | Status |
  |---|-------|-------------|--------|
  | 1 | Core | Notification service | pending |
  | 2 | Email | Email provider integration | pending |
  | 3 | UI | In-app notification center | pending |
  | 4 | Prefs | User preferences | pending |
```

```
Step 2: Create Implementation Plan
───────────────────────────────────
User: /prp-plan .claude/PRPs/prds/user-notifications.prd.md

AI:
1. Reads PRD, selects Phase 1 (Core)
2. Launches codebase-explorer and codebase-analyst in parallel
3. Researches notification best practices
4. Generates implementation plan

→ .claude/PRPs/plans/user-notifications-phase-1.plan.md

Plan contains:
- Patterns to Mirror (with file:line references)
- Step-by-Step Tasks (8 tasks)
- Validation Commands for each level
- Files to Change table
```

```
Step 3: Execute Implementation
──────────────────────────────
User: /prp-implement .claude/PRPs/plans/user-notifications-phase-1.plan.md

AI:
1. Creates feature branch: feature/user-notifications-core
2. Executes tasks in order:
   - Task 1: CREATE models → validate → ✅
   - Task 2: CREATE schemas → validate → ✅
   - Task 3: CREATE errors → validate → ✅
   ...
3. Runs full validation suite
4. Creates implementation report

→ .claude/PRPs/reports/user-notifications-phase-1-report.md
→ Plan archived to .claude/PRPs/plans/completed/

Output:
## Implementation Complete

**Branch**: feature/user-notifications-core
**Status**: ✅ Complete

| Check | Result |
|-------|--------|
| Type check | ✅ |
| Lint | ✅ |
| Tests | ✅ (12 passed) |
| Build | ✅ |

To continue with Phase 2: /prp-plan .claude/PRPs/prds/user-notifications.prd.md
```

---

### Example 2: Autonomous Execution with Ralph Loop

**Scenario**: You want hands-off implementation of a feature.

```
User: /prp-ralph .claude/PRPs/plans/add-search.plan.md --max-iterations 15

AI:
## PRP Ralph Loop Activated

**Plan**: .claude/PRPs/plans/add-search.plan.md
**Iteration**: 1
**Max iterations**: 15

Starting iteration 1...

[AI implements tasks, runs validations]

## Iteration 1 - 2024-01-15T10:30:00Z

### Completed
- Task 1: CREATE search models
- Task 2: CREATE search service

### Validation Status
- Type-check: FAIL (2 errors)
- Tests: Not run (blocked by type errors)

### Learnings
- Search index uses Elasticsearch client at src/lib/elasticsearch.ts
- Must use async/await for all DB operations

[AI fixes type errors, continues...]

## Iteration 2 - 2024-01-15T10:35:00Z

### Completed
- Task 3: CREATE search routes
- Task 4: ADD tests

### Validation Status
- Type-check: PASS
- Lint: PASS
- Tests: PASS (8/8)
- Build: PASS

[All validations pass!]

## Implementation Complete

<promise>COMPLETE</promise>

→ Report: .claude/PRPs/reports/add-search-report.md
→ Archived: .claude/PRPs/ralph-archives/2024-01-15-add-search/
```

---

### Example 3: Quick Feature (Direct Plan)

**Scenario**: Small feature, skip PRD.

```
User: /prp-plan "add rate limiting to the API"

AI:
1. Explores codebase for:
   - Existing middleware patterns
   - API route structure
   - Configuration patterns

2. Researches rate limiting libraries for the project's stack

3. Generates plan with 4 tasks:
   - Task 1: ADD rate-limit dependency
   - Task 2: CREATE rate-limit middleware
   - Task 3: APPLY middleware to routes
   - Task 4: ADD configuration

→ .claude/PRPs/plans/add-rate-limiting.plan.md

Confidence Score: 8/10
- Pattern exists in codebase (auth middleware)
- Well-documented library available
```

---

### Example 4: Using Agents Directly

**Scenario**: You need to understand how authentication works before planning.

```
User: Use codebase-analyst to trace how user authentication works

AI [as codebase-analyst]:
## Analysis: User Authentication

### Entry Points
| Location | Purpose |
|----------|---------|
| `src/routes/auth.ts:15` | Login endpoint |
| `src/routes/auth.ts:45` | Register endpoint |
| `src/middleware/auth.ts:8` | Token verification |

### Implementation Flow

#### 1. Login (`src/routes/auth.ts:15-42`)
- Receives email/password at line 15
- Validates with Zod schema at line 20
- Calls authService.login() at line 28
- Returns JWT token at line 40

#### 2. Token Verification (`src/middleware/auth.ts:8-35`)
- Extracts Bearer token at line 12
- Verifies with JWT library at line 18
- Attaches user to request at line 30

### Data Flow
```
Request → auth middleware → token verify → user lookup → request.user
                                    ↓
                              JWT verify
```

### Patterns Found
| Pattern | Location | Usage |
|---------|----------|-------|
| Middleware chain | `src/middleware/` | Auth, logging, error handling |
| Service layer | `src/services/auth.ts` | Business logic isolation |
```

---

### Example 5: Web Research for Documentation

**Scenario**: Need to understand a library's breaking changes.

```
User: Use web-researcher to find Drizzle ORM v0.30 breaking changes

AI [as web-researcher]:
## Summary
Drizzle ORM v0.30 introduces significant changes to relations API
and migrates from zod to internal schema validation.

## Detailed Findings

### Drizzle ORM v0.30 Release Notes
**Source**: [Drizzle Blog](https://orm.drizzle.team/blog/drizzle-orm-0-30-0)
**Authority**: Official documentation
**Key Information**:
- `relations()` API signature changed - now requires explicit table reference
- Zod integration moved to separate package `drizzle-zod`
- `db.select()` now returns `PgSelectBuilder` instead of `SelectQueryBuilder`

### Migration Guide
**Source**: [Migration Docs](https://orm.drizzle.team/migration-guides/v0.30)
**Authority**: Official docs
**Key Information**:
- Update imports from `drizzle-orm/zod` to `drizzle-zod`
- Replace `relations(users, ({ one }) => ...)` with `relations(users, ({ one }) => ({...}))`

## Code Examples
```typescript
// OLD (v0.29)
export const usersRelations = relations(users, ({ many }) => ({
  posts: many(posts),
}));

// NEW (v0.30)
export const usersRelations = relations(users, ({ many }) => ({
  posts: many(posts),
}));
// Note: Syntax unchanged, but type inference improved
```

## Gaps or Conflicts
- Performance comparison with v0.29 not documented
- Some community members report edge case type issues
```

---

## Validation Levels

PRP uses 6 levels of validation:

| Level | Type | Description |
|-------|------|-------------|
| 1 | Static Analysis | Type checking, linting |
| 2 | Unit Tests | Test suite execution |
| 3 | Integration | Full suite + build |
| 4 | Domain-Specific | MCP, database, performance |
| 5 | Browser/UI | UI verification, user flows |
| 6 | Manual | Step-by-step testing |

## Artifacts Structure

All PRP artifacts are stored in `.claude/PRPs/`:

```
.claude/PRPs/
├── prds/              # Product requirement documents
├── plans/             # Implementation plans
│   └── completed/     # Archived completed plans
├── reports/           # Implementation reports
├── issues/            # Issue investigation artifacts
├── debug/             # Root cause analysis reports
├── reviews/           # PR review reports
└── ralph-archives/    # Ralph loop execution archives
```

## Key Principles

1. **Context is King** - Include ALL necessary documentation, examples, caveats
2. **Validation Loops** - Provide executable tests/lints the AI can run and fix
3. **Information Dense** - Use keywords and patterns from the codebase
4. **Bounded Scope** - Each plan completable in one loop
5. **Pattern Faithful** - Mirror existing codebase patterns exactly

## Configuration

Add to your project's `CLAUDE.md` or `CODEBUDDY.md`:

```markdown
## PRP Configuration
- PRP artifacts location: .claude/PRPs/
- Validation commands: (project-specific)
- Default max iterations: 20
```

## Dependencies

This skill works with the following specialized agents:

| Agent | Purpose | Use Case |
|-------|---------|----------|
| `codebase-explorer` | Finds WHERE code lives, shows HOW it's implemented | Locate similar implementations, extract patterns |
| `codebase-analyst` | Analyzes HOW integration points work, traces data flow | Understand system architecture, trace execution paths |
| `web-researcher` | Strategic web research with citations | Find documentation, best practices, version-specific info |

### Agent Usage

These agents are invoked through the Task tool during planning and research phases:

```
# Codebase exploration
Task tool with subagent_type="Explore" or specialized instructions

# Codebase analysis
Task tool with analyst-focused instructions

# Web research
WebSearch and WebFetch tools, or Task tool with research instructions
```

## Files in This Skill

```
prp-framework/
├── SKILL.md                    # Main skill (this file)
├── skills/
│   ├── prp-prd/SKILL.md       # PRD generation
│   ├── prp-plan/SKILL.md      # Plan creation
│   ├── prp-implement/SKILL.md # Plan execution
│   └── prp-ralph/SKILL.md     # Autonomous loop
├── agents/
│   ├── codebase-explorer.md   # Code location and patterns
│   ├── codebase-analyst.md    # Data flow and integration
│   └── web-researcher.md      # External documentation
└── templates/
    ├── prp_base.md            # Base PRP template
    ├── prp_story_task.md      # Sprint task template
    └── prp_planning.md        # Planning session template
```
