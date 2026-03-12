# PRP Story/Task Template

Use this template for sprint tasks and user stories within a larger feature.

---

## Story

**As a** [type of user]

**I want** [some goal]

**So that** [some reason]

---

## Acceptance Criteria

- [ ] Given [context], when [action], then [outcome]
- [ ] Given [context], when [action], then [outcome]
- [ ] Given [context], when [action], then [outcome]

---

## Tasks

### Task 1: [Short description]

- **File**: `path/to/file.ts`
- **Action**: CREATE | UPDATE
- **Pattern**: Follow `path/to/example.ts:10-30`
- **Validate**: `npm run type-check`

### Task 2: [Short description]

- **File**: `path/to/another-file.ts`
- **Action**: CREATE
- **Pattern**: Follow `path/to/example.ts:45-60`
- **Validate**: `npm test path/to/test.ts`

---

## Technical Notes

### Context from Parent PRD

[Link to parent PRD and extract relevant context]

### Dependencies

- Task 1 must complete before Task 2
- Requires [external service/library]

### Gotchas

- [Library-specific constraint]
- [Known issue with workaround]

---

## Validation Commands

```bash
# Type check
npm run type-check

# Lint
npm run lint

# Test
npm test path/to/tests/

# Build
npm run build
```

---

## Definition of Done

- [ ] All acceptance criteria met
- [ ] All validation commands pass
- [ ] Code reviewed
- [ ] Tests written
- [ ] Documentation updated (if needed)
