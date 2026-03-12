---
name: prp-implement
description: Execute implementation plans with rigorous validation loops. Each change is validated immediately with fixes applied before moving on. Use when you have a .plan.md file ready for execution, when user wants to implement a plan, or when user says "implement plan", "execute plan", "/prp-implement", or mentions executing an implementation plan. Do NOT use for simple one-off code changes.
---

# PRP Implement

## Overview

Execute an implementation plan with rigorous validation loops. Each change is validated immediately, with fixes applied before moving on.

**Trigger**: `/prp-implement <path/to/plan.md> [--base <branch>]`

## Core Philosophy

**Validation loops catch mistakes early.** Run checks after every change. Fix issues immediately. The goal is a working implementation, not just code that exists.

**Golden Rule**: If a validation fails, fix it before moving on. Never accumulate broken state.

---

## Phase 0: DETECT - Project Environment

### 0.1 Identify Package Manager

| File Found | Package Manager | Runner |
|------------|-----------------|--------|
| `bun.lockb` | bun | `bun` / `bun run` |
| `pnpm-lock.yaml` | pnpm | `pnpm` / `pnpm run` |
| `yarn.lock` | yarn | `yarn` / `yarn run` |
| `package-lock.json` | npm | `npm run` |
| `pyproject.toml` | uv/pip | `uv run` / `python` |
| `Cargo.toml` | cargo | `cargo` |
| `go.mod` | go | `go` |

**Store the detected runner** - use it for all subsequent commands.

### 0.2 Detect Base Branch

1. Check arguments for `--base <branch>`
2. Auto-detect from remote:
   ```bash
   git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@'
   ```
3. Fallback: `main`

### 0.3 Identify Validation Scripts

Check package.json for available scripts:
- Type checking: `type-check`, `typecheck`, `tsc`
- Linting: `lint`, `lint:fix`
- Testing: `test`, `test:unit`
- Building: `build`

---

## Phase 1: LOAD - Read the Plan

### 1.1 Load Plan File

Read the plan file and extract key sections:
- **Summary** - What we're building
- **Patterns to Mirror** - Code to copy from
- **Files to Change** - CREATE/UPDATE list
- **Step-by-Step Tasks** - Implementation order
- **Validation Commands** - How to verify
- **Acceptance Criteria** - Definition of done

### 1.2 Validate Plan Exists

**If plan not found:**
```
Error: Plan not found at $ARGUMENTS

Create a plan first: /prp-plan "feature description"
```

---

## Phase 2: PREPARE - Git State

### 2.1 Check Current State

```bash
git branch --show-current
git status --porcelain
git worktree list
```

### 2.2 Branch Decision

| Current State | Action |
|---------------|--------|
| In worktree | Use it |
| On base-branch, clean | Create branch: `git checkout -b feature/{plan-slug}` |
| On base-branch, dirty | STOP: "Stash or commit changes first" |
| On feature branch | Use it |

### 2.3 Sync with Remote

```bash
git fetch origin
git pull --rebase origin {base-branch} 2>/dev/null || true
```

---

## Phase 3: EXECUTE - Implement Tasks

**For each task in the plan's Step-by-Step Tasks section:**

### 3.1 Read Context

1. Read the **MIRROR** file reference from the task
2. Understand the pattern to follow
3. Read any **IMPORTS** specified

### 3.2 Implement

1. Make the change exactly as specified
2. Follow the pattern from MIRROR reference
3. Handle any **GOTCHA** warnings

### 3.3 Validate Immediately

**After EVERY file change, run the type-check command from the plan.**

**If types fail:**
1. Read the error
2. Fix the issue
3. Re-run type-check
4. Only proceed when passing

### 3.4 Track Progress

Log each task as you complete it:
```
Task 1: CREATE src/features/x/models.ts ✅
Task 2: CREATE src/features/x/service.ts ✅
Task 3: UPDATE src/routes/index.ts ✅
```

**Deviation Handling:**
If you must deviate from the plan:
- Note WHAT changed
- Note WHY it changed
- Continue with the deviation documented

---

## Phase 4: VALIDATE - Full Verification

### 4.1 Static Analysis

Run type-check and lint commands from plan:
- JS/TS: `{runner} run type-check && {runner} run lint`
- Python: `ruff check . && mypy .`
- Rust: `cargo check && cargo clippy`
- Go: `go vet ./...`

**Must pass with zero errors.**

### 4.2 Unit Tests

**You MUST write or update tests for new code.** This is not optional.

**Test requirements:**
1. Every new function/feature needs at least one test
2. Edge cases identified in the plan need tests
3. Update existing tests if behavior changed

**If tests fail:**
1. Read failure output
2. Determine: bug in implementation or bug in test?
3. Fix the actual issue
4. Re-run tests
5. Repeat until green

### 4.3 Build Check

Run the build command from the plan:
- JS/TS: `{runner} run build`
- Rust: `cargo build --release`
- Go: `go build ./...`

**Must complete without errors.**

### 4.4 Integration Testing (if applicable)

If plan involves API/server changes:
1. Start server in background
2. Test endpoints
3. Verify responses
4. Stop server

---

## Phase 5: REPORT - Create Implementation Report

### 5.1 Create Report Directory

```bash
mkdir -p .claude/PRPs/reports
```

### 5.2 Generate Report

**Path**: `.claude/PRPs/reports/{plan-name}-report.md`

```markdown
# Implementation Report

**Plan**: `$ARGUMENTS`
**Branch**: `{branch-name}`
**Date**: {YYYY-MM-DD}
**Status**: {COMPLETE | PARTIAL}

---

## Summary
{Brief description of what was implemented}

---

## Assessment vs Reality

| Metric | Predicted | Actual | Reasoning |
|--------|-----------|--------|-----------|
| Complexity | {from plan} | {actual} | {why matched/differed} |
| Confidence | {from plan} | {actual} | {reasoning} |

---

## Tasks Completed

| # | Task | File | Status |
|---|------|------|--------|
| 1 | {description} | `src/x.ts` | ✅ |

---

## Validation Results

| Check | Result | Details |
|-------|--------|---------|
| Type check | ✅ | No errors |
| Lint | ✅ | 0 errors |
| Unit tests | ✅ | X passed |
| Build | ✅ | Compiled |

---

## Files Changed

| File | Action | Lines |
|------|--------|-------|
| `src/x.ts` | CREATE | +{N} |

---

## Deviations from Plan
{List or "None"}

---

## Issues Encountered
{List or "None"}

---

## Tests Written

| Test File | Test Cases |
|-----------|------------|
| `src/x.test.ts` | {list} |

---

## Next Steps
- [ ] Review implementation
- [ ] Create PR: `gh pr create`
- [ ] Merge when approved
```

### 5.3 Update Source PRD (if applicable)

If plan was from a PRD:
1. Read the PRD file
2. Find the phase in Implementation Phases table
3. Update Status from `in-progress` to `complete`
4. Save the PRD

### 5.4 Archive Plan

```bash
mkdir -p .claude/PRPs/plans/completed
mv $ARGUMENTS .claude/PRPs/plans/completed/
```

---

## Phase 6: OUTPUT - Report to User

```markdown
## Implementation Complete

**Plan**: `$ARGUMENTS`
**Branch**: `{branch-name}`
**Status**: ✅ Complete

### Validation Summary

| Check | Result |
|-------|--------|
| Type check | ✅ |
| Lint | ✅ |
| Tests | ✅ ({N} passed) |
| Build | ✅ |

### Files Changed
- {N} files created
- {M} files updated
- {K} tests written

### Artifacts
- Report: `.claude/PRPs/reports/{name}-report.md`
- Plan archived to: `.claude/PRPs/plans/completed/`

{If from PRD:}
### PRD Progress
**Phase Completed**: #{number} - {phase name}

To continue: `/prp-plan {prd-path}`

### Next Steps
1. Review the report
2. Create PR: `gh pr create` or `/prp-pr`
3. Merge when approved
```

---

## Handling Failures

### Type Check Fails
1. Read error message carefully
2. Fix the type issue
3. Re-run type-check
4. Don't proceed until passing

### Tests Fail
1. Identify which test failed
2. Determine: implementation bug or test bug?
3. Fix the root cause
4. Re-run tests
5. Repeat until green

### Lint Fails
1. Run lint fix command
2. Manually fix remaining issues
3. Re-run lint
4. Proceed when clean

### Build Fails
1. Usually a type or import issue
2. Check the error output
3. Fix and re-run

---

## Success Criteria

- **TASKS_COMPLETE**: All plan tasks executed
- **TYPES_PASS**: Type-check command exits 0
- **LINT_PASS**: Lint command exits 0
- **TESTS_PASS**: Test command all green
- **BUILD_PASS**: Build command succeeds
- **REPORT_CREATED**: Implementation report exists
- **PLAN_ARCHIVED**: Original plan moved to completed

---

## Usage Example

```
User: /prp-implement .claude/PRPs/plans/add-dark-mode-toggle.plan.md

AI:
## Phase 0: Detect Environment

**Package Manager**: bun (bun.lockb found)
**Base Branch**: main
**Validation Scripts**: type-check, lint, test, build

## Phase 1: Load Plan

Reading plan... 4 tasks identified:
1. CREATE src/components/theme-toggle.tsx
2. CREATE src/components/__tests__/theme-toggle.test.tsx
3. UPDATE src/pages/settings.tsx
4. UPDATE tailwind.config.js

## Phase 2: Prepare Git State

Current branch: main
Working directory: clean
Creating branch: feature/dark-mode-toggle

```bash
git checkout -b feature/dark-mode-toggle
```

## Phase 3: Execute Tasks

### Task 1: CREATE src/components/theme-toggle.tsx

Reading MIRROR: `src/components/button.tsx:1-30`

[Creating component following button pattern...]

```bash
bun run type-check
```
✅ No errors

### Task 2: CREATE src/components/__tests__/theme-toggle.test.tsx

Reading MIRROR: `src/components/__tests__/button.test.tsx:1-40`

[Creating tests following existing patterns...]

```bash
bun test src/components/__tests__/theme-toggle.test.tsx
```
✅ 5 tests passed

### Task 3: UPDATE src/pages/settings.tsx

[Adding Appearance section with theme toggle...]

```bash
bun run type-check
```
✅ No errors

### Task 4: UPDATE tailwind.config.js

[Adding darkMode: 'class' configuration...]

```bash
bun run type-check && bun run lint
```
✅ All pass

## Phase 4: Validate

### Level 1: Static Analysis
```bash
bun run type-check && bun run lint
```
✅ Exit 0, no errors

### Level 2: Unit Tests
```bash
bun test
```
✅ 47 tests passed (5 new)

### Level 3: Build
```bash
bun run build
```
✅ Build successful

## Phase 5: Report

→ .claude/PRPs/reports/add-dark-mode-toggle-report.md
→ Plan archived to .claude/PRPs/plans/completed/

## Implementation Complete

**Branch**: feature/dark-mode-toggle
**Status**: ✅ Complete

### Validation Summary

| Check | Result |
|-------|--------|
| Type check | ✅ |
| Lint | ✅ |
| Tests | ✅ (47 passed, 5 new) |
| Build | ✅ |

### Files Changed
- 2 files created
- 2 files updated
- 5 tests written

### Deviations
None - Implementation matched the plan exactly.

### Next Steps
1. Review the report
2. Create PR: `gh pr create`
3. Merge when approved
```
