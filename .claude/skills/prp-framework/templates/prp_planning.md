# PRP Planning Template

Use this template for planning sessions with diagrams and architecture decisions.

---

## Planning Session: [Feature/Project Name]

**Date**: [YYYY-MM-DD]

**Participants**: [List]

**Goal**: [What we want to achieve in this session]

---

## Problem Statement

[Clear description of the problem to solve]

---

## Current State Analysis

### Architecture Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                     CURRENT ARCHITECTURE                         │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│   ┌──────────┐     ┌──────────┐     ┌──────────┐               │
│   │ Client   │────▶│ Server   │────▶│ Database │               │
│   └──────────┘     └──────────┘     └──────────┘               │
│                                                                  │
│   KEY COMPONENTS:                                               │
│   - Component A: [description]                                  │
│   - Component B: [description]                                  │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

### Data Flow

```
User Action → API → Service → Repository → Database
                 ↓
              Logger
```

### Current Pain Points

| Pain Point | Impact | Frequency |
|------------|--------|-----------|
| [Issue] | [Impact] | [How often] |

---

## Proposed Solution

### Architecture Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                     PROPOSED ARCHITECTURE                        │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│   ┌──────────┐     ┌──────────┐     ┌──────────┐               │
│   │ Client   │────▶│ Server   │────▶│ Database │               │
│   └──────────┘     └──────────┘     └──────────┘               │
│        │                │                                        │
│        │                ▼                                        │
│        │          ┌──────────┐                                   │
│        └─────────▶│ NEW FEATURE│  ◄── [What's new]              │
│                   └──────────┘                                   │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

### New Data Flow

```
User Action → API → [NEW COMPONENT] → Service → Repository → Database
                           ↓
                        Validation
                           ↓
                        Business Logic
```

---

## Implementation Phases

| # | Phase | Description | Dependencies | Est. Effort |
|---|-------|-------------|--------------|-------------|
| 1 | Foundation | [What] | - | [Time] |
| 2 | Core | [What] | 1 | [Time] |
| 3 | Integration | [What] | 2 | [Time] |
| 4 | Polish | [What] | 3 | [Time] |

---

## Technical Decisions

### Decision 1: [Topic]

| Option | Pros | Cons |
|--------|------|------|
| A | [pros] | [cons] |
| B | [pros] | [cons] |

**Decision**: [Chosen option]

**Rationale**: [Why this choice]

---

## Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| [Risk] | H/M/L | H/M/L | [Strategy] |

---

## Open Questions

- [ ] [Question 1]
- [ ] [Question 2]
- [ ] [Question 3]

---

## Action Items

| Action | Owner | Due Date |
|--------|-------|----------|
| [Action] | [Person] | [Date] |

---

## Next Steps

1. [First step]
2. [Second step]
3. [Third step]
