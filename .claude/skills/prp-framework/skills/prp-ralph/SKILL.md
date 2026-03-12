---
name: prp-ralph
description: Autonomous Ralph loop that executes PRP plans iteratively until all validations pass. Self-referential feedback loop that keeps iterating until the job is done. Use when user wants autonomous hands-off implementation, when user says "ralph", "autonomous execution", "run until complete", "/prp-ralph", or mentions hands-off implementation. Requires a .plan.md or .prd.md file. Do NOT use for simple tasks, when user wants to review each step manually, or for time-sensitive operations - use prp-implement for step-by-step control instead.
---

# PRP Ralph Loop - Autonomous Execution

## Overview

Start an autonomous Ralph loop that executes a PRP plan iteratively until all validations pass. Based on the Ralph Wiggum technique - a self-referential loop that keeps iterating until the job is done.

**Trigger**: `/prp-ralph <plan.md|prd.md> [--max-iterations N]`

## Core Philosophy

Self-referential feedback loop. Each iteration:
1. See your previous work in files and git history
2. Implement, validate, fix
3. Repeat until complete

---

## Phase 1: PARSE - Validate Input

### 1.1 Parse Arguments

Extract from input:
- **File path**: Must end in `.plan.md` or `.prd.md`
- **Max iterations**: `--max-iterations N` (default: 20)

### 1.2 Validate Input Type

| Input | Action |
|-------|--------|
| Ends with `.plan.md` | Valid - use as plan file |
| Ends with `.prd.md` | Valid - will select next phase |
| Free-form text | STOP - need plan or PRD file |
| No input | STOP - need plan or PRD file |

**If invalid input:**
```
Ralph requires a PRP plan or PRD file.

Create one first:
  /prp-plan "your feature description"
  /prp-prd "your product idea"

Then run:
  /prp-ralph .claude/PRPs/plans/your-feature.plan.md --max-iterations 20
```

### 1.3 Verify File Exists

```bash
test -f "{file_path}" && echo "EXISTS" || echo "NOT_FOUND"
```

### 1.4 If PRD File - Select Next Phase

If input is a `.prd.md` file:
1. Read the PRD
2. Parse Implementation Phases table
3. Find first phase with `Status: pending` where dependencies are `complete`
4. Report which phase will be executed
5. The loop will create and execute a plan for this phase

---

## Phase 2: SETUP - Initialize Ralph Loop

### 2.1 Create State File

Create `.claude/prp-ralph.state.md`:

```bash
mkdir -p .claude
mkdir -p .claude/PRPs/ralph-archives
```

State file structure:

```markdown
---
iteration: 1
max_iterations: {N}
plan_path: "{file_path}"
input_type: "{plan|prd}"
started_at: "{ISO timestamp}"
---

# PRP Ralph Loop State

## Codebase Patterns
(Consolidate reusable patterns here - future iterations read this first)

## Current Task
Execute PRP plan and iterate until all validations pass.

## Plan Reference
{file_path}

## Instructions
1. Read the plan file
2. Implement all incomplete tasks
3. Run ALL validation commands from the plan
4. If any validation fails: fix and re-validate
5. Update plan file: mark completed tasks, add notes
6. When ALL validations pass: output <promise>COMPLETE</promise>

## Progress Log
(Append learnings after each iteration)

---
```

### 2.2 Display Startup Message

```markdown
## PRP Ralph Loop Activated

**Plan**: {file_path}
**Iteration**: 1
**Max iterations**: {N}

The loop is now active. When you try to exit:
- If validations incomplete → same prompt fed back
- If all validations pass → loop exits

To monitor: `cat .claude/prp-ralph.state.md`
To cancel: `/prp-ralph-cancel`

---

CRITICAL REQUIREMENTS:
- Work through ALL tasks in the plan
- Run ALL validation commands
- Fix failures before proceeding
- Only output <promise>COMPLETE</promise> when ALL validations pass
- Do NOT lie to exit - the loop continues until genuinely complete

---

Starting iteration 1...
```

---

## Phase 3: EXECUTE - Work on Plan

### 3.1 Read Context First

Before implementing:
1. Read the state file - check "Codebase Patterns" section
2. Read the plan file - understand all tasks
3. Check git status - what's already changed?
4. Review progress log - what did previous iterations do?

### 3.2 Identify Work

From the plan, identify:
- Tasks not yet completed
- Validation commands to run
- Acceptance criteria to meet

### 3.3 Implement

For each incomplete task:
1. Read the task requirements
2. Read any MIRROR/pattern references
3. Implement the change
4. Run task-specific validation if specified

### 3.4 Validate

Run ALL validation commands from the plan:

```bash
# Typical validation levels (adapt to plan)
bun run type-check || npm run type-check
bun run lint || npm run lint
bun test || npm test
bun run build || npm run build
```

### 3.5 Track Results

| Check | Result | Notes |
|-------|--------|-------|
| Type check | PASS/FAIL | {details} |
| Lint | PASS/FAIL | {details} |
| Tests | PASS/FAIL | {details} |
| Build | PASS/FAIL | {details} |

### 3.6 If Any Validation Fails

1. Analyze the failure
2. Fix the issue
3. Re-run validation
4. Repeat until passing

### 3.7 Update State File Progress Log

Append to Progress Log section:

```markdown
## Iteration {N} - {ISO timestamp}

### Completed
- {Task 1 summary}
- {Task 2 summary}

### Validation Status
- Type-check: PASS/FAIL ({error count if failing})
- Lint: PASS/FAIL
- Tests: PASS/FAIL ({X/Y passing})
- Build: PASS/FAIL

### Learnings
- {Pattern discovered}
- {Gotcha found}
- {Context note}

### Next Steps
- {What still needs to be done}
- {Specific blockers}

---
```

### 3.8 Consolidate Codebase Patterns

If you discover a **reusable pattern**, add it to "Codebase Patterns" section:

```markdown
## Codebase Patterns
- Use `sql<number>` template for type-safe SQL aggregations
- Always use `IF NOT EXISTS` in migrations
- Export types from actions.ts for UI components
```

---

## Phase 4: COMPLETION CHECK

### 4.1 Verify All Validations Pass

ALL must be true:
- [ ] All tasks in plan completed
- [ ] Type check passes
- [ ] Lint passes (0 errors)
- [ ] Tests pass
- [ ] Build succeeds
- [ ] All acceptance criteria met

### 4.2 If ALL Pass - Complete the Loop

1. **Generate Implementation Report**

   Create `.claude/PRPs/reports/{plan-name}-report.md`:

   ```markdown
   # Implementation Report

   **Plan**: {plan_path}
   **Completed**: {timestamp}
   **Iterations**: {N}

   ## Summary
   {What was implemented}

   ## Tasks Completed
   {List from plan}

   ## Validation Results
   | Check | Result |
   |-------|--------|
   | Type check | PASS |
   | Lint | PASS |
   | Tests | PASS |
   | Build | PASS |

   ## Codebase Patterns Discovered
   {From state file}

   ## Learnings
   {Consolidated from progress log}
   ```

2. **Archive the Ralph Run**

   ```bash
   DATE=$(date +%Y-%m-%d)
   PLAN_NAME=$(basename {plan_path} .plan.md)
   ARCHIVE_DIR=".claude/PRPs/ralph-archives/${DATE}-${PLAN_NAME}"
   mkdir -p "$ARCHIVE_DIR"

   cp .claude/prp-ralph.state.md "$ARCHIVE_DIR/state.md"
   cp {plan_path} "$ARCHIVE_DIR/plan.md"
   cp .claude/PRPs/reports/{plan-name}-report.md "$ARCHIVE_DIR/learnings.md"
   ```

3. **Archive Plan to Completed**

   ```bash
   mkdir -p .claude/PRPs/plans/completed
   mv {plan_path} .claude/PRPs/plans/completed/
   ```

4. **Clean Up State**

   ```bash
   rm .claude/prp-ralph.state.md
   ```

5. **Output Completion Promise**

   ```
   <promise>COMPLETE</promise>
   ```

### 4.3 If NOT All Pass - End Iteration

- Document current state in progress log
- End your response normally
- The loop will feed the prompt back for next iteration

**Do NOT output the completion promise if validations are failing.**

---

## Handling Edge Cases

### Max Iterations Reached

If iteration count reaches max_iterations:
- Document what's incomplete
- Document what's blocking
- Archive current state (even if incomplete)
- Suggest next steps

### Stuck on Same Issue

If stuck (same error multiple iterations):
1. Document the blocker clearly
2. Check "Codebase Patterns" for hints
3. Try alternative approaches
4. If truly stuck, document for human review

### Plan Has Errors

If the plan itself has issues:
- Document the problems
- Suggest corrections
- Continue with what's executable

---

## Learnings Feedback System

### During Loop
- **Codebase Patterns**: Added to state file, read by future iterations
- **Progress Log**: Detailed notes on what worked/failed

### After Completion
- **Archive**: Full state preserved in `.claude/PRPs/ralph-archives/`
- **Report**: Consolidated learnings
- **CLAUDE.md Updates**: Permanent patterns added

### Using Archives

```bash
# List all Ralph archives
ls -la .claude/PRPs/ralph-archives/

# Review learnings from a specific run
cat .claude/PRPs/ralph-archives/2024-01-12-feature-name/learnings.md
```

---

## Success Criteria

- **PLAN_EXECUTED**: All tasks from plan completed
- **VALIDATIONS_PASS**: All validation commands succeed
- **REPORT_GENERATED**: Implementation report created
- **LEARNINGS_CAPTURED**: Progress log has useful insights
- **PATTERNS_CONSOLIDATED**: Reusable patterns extracted
- **ARCHIVE_CREATED**: Full run archived for future reference
- **CLEAN_EXIT**: Completion promise output only when genuinely complete

---

## Usage Example

```
User: /prp-ralph .claude/PRPs/plans/add-search.plan.md --max-iterations 15

AI:
## PRP Ralph Loop Activated

**Plan**: .claude/PRPs/plans/add-search.plan.md
**Iteration**: 1
**Max iterations**: 15

The loop is now active. When you try to exit:
- If validations incomplete → same prompt fed back
- If all validations pass → loop exits

To monitor: `cat .claude/prp-ralph.state.md`
To cancel: `/prp-ralph-cancel`

---

CRITICAL REQUIREMENTS:
- Work through ALL tasks in the plan
- Run ALL validation commands
- Fix failures before proceeding
- Only output <promise>COMPLETE</promise> when ALL validations pass

---

Starting iteration 1...

---

## Iteration 1 - 2024-01-15T10:30:00Z

### Reading Context
- Reading state file (no previous patterns)
- Reading plan: 6 tasks to complete
- Checking git status: clean, on feature branch

### Tasks
1. CREATE search models → ✅ Complete
2. CREATE search service → ✅ Complete
3. CREATE search routes → ✅ Complete

### Validation
```bash
bun run type-check
```
Result: FAIL - 3 type errors
- Error: 'SearchResult' type not exported
- Error: 'searchIndex' missing required property 'name'
- Error: 'SearchService' has no method 'indexDocument'

### Fixes Applied
- Added export for SearchResult type
- Added name property to searchIndex config
- Added indexDocument method to SearchService

### Validation Re-run
```bash
bun run type-check
```
Result: PASS

```bash
bun test
```
Result: FAIL - 2 tests failing
- test: should return search results → timeout
- test: should handle empty query → throws error

### Progress Log Updated

---

## Iteration 2 - 2024-01-15T10:35:00Z

### Reading Context
- Previous iteration: 3 tasks done, tests failing
- Pattern learned: SearchIndex requires 'name' property

### Fixes Applied
- Fixed timeout: increased test timeout to 5000ms
- Fixed empty query: added null check before search

### Validation
```bash
bun test
```
Result: PASS - 28 tests passed

```bash
bun run lint
```
Result: PASS - 0 errors, 2 warnings

```bash
bun run build
```
Result: PASS

### All Validation Results
| Check | Result |
|-------|--------|
| Type check | ✅ PASS |
| Lint | ✅ PASS |
| Tests | ✅ PASS (28/28) |
| Build | ✅ PASS |

### Codebase Patterns Discovered
- SearchIndex requires 'name' property in config
- Test timeout for async operations: 5000ms
- Use null check before search operations

### Completion Actions
1. Created report: .claude/PRPs/reports/add-search-report.md
2. Archived to: .claude/PRPs/ralph-archives/2024-01-15-add-search/
3. Moved plan to: .claude/PRPs/plans/completed/
4. Cleaned up state file

---

## Implementation Complete

**Plan**: .claude/PRPs/plans/add-search.plan.md
**Completed**: 2024-01-15T10:35:00Z
**Total Iterations**: 2

### Summary
Implemented full-text search feature with Elasticsearch integration,
including models, service, routes, and comprehensive test coverage.

### Tasks Completed
| # | Task | Status |
|---|------|--------|
| 1 | CREATE search models | ✅ |
| 2 | CREATE search service | ✅ |
| 3 | CREATE search routes | ✅ |
| 4 | CREATE search tests | ✅ |
| 5 | ADD search configuration | ✅ |
| 6 | UPDATE documentation | ✅ |

### Learnings Captured
- SearchIndex requires 'name' property - documented in patterns
- Async test timeout increased to 5000ms
- Null checks essential for empty query handling

<promise>COMPLETE</promise>
```

### Example: Multi-Iteration with Stuck Detection

```
User: /prp-ralph .claude/PRPs/plans/complex-feature.plan.md

[Iteration 1-3: Normal progress...]

---

## Iteration 4 - 2024-01-15T11:00:00Z

### Validation Status
- Type-check: FAIL - same error as iteration 3
- Error: 'DatabaseConnection' is not a constructor

### Stuck Detection
Same error for 2 iterations. Checking Codebase Patterns...
Pattern found: "Use createConnection() factory, not new DatabaseConnection()"

### Alternative Approach
Trying factory pattern instead of constructor...

[Fix applied using factory pattern...]

```bash
bun run type-check
```
Result: PASS

### Learning
- DatabaseConnection must be created via createConnection() factory
- Added to Codebase Patterns section

---

[Loop continues and completes...]
```
