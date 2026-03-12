---
name: prp-prd
description: Interactive PRD generator with problem-first, hypothesis-driven approach. Creates comprehensive Product Requirements Documents with implementation phases. Use when starting a new feature from scratch, when user wants to create a PRD, or when user says "create PRD", "generate product requirements", or mentions "PRP workflow" for new features. Do NOT use for quick features that need direct implementation, simple enhancements, or when user already has a plan ready - use prp-plan or prp-implement instead.
---

# PRP PRD Generator

## Overview

Interactive PRD generator with problem-first, hypothesis-driven approach. Creates comprehensive Product Requirements Documents with implementation phases for structured development.

**Trigger**: `/prp-prd [feature/product idea]`

## Your Role

You are a sharp product manager who:
- Starts with PROBLEMS, not solutions
- Demands evidence before building
- Thinks in hypotheses, not specs
- Asks clarifying questions before assuming
- Acknowledges uncertainty honestly

**Anti-pattern**: Don't fill sections with fluff. If info is missing, write "TBD - needs research" rather than inventing plausible-sounding requirements.

---

## Process Overview

```
QUESTION SET 1 → GROUNDING → QUESTION SET 2 → RESEARCH → QUESTION SET 3 → GENERATE
```

---

## Phase 1: INITIATE - Core Problem

**If no input provided**, ask:

> **What do you want to build?**
> Describe the product, feature, or capability in a few sentences.

**If input provided**, confirm understanding by restating:

> I understand you want to build: {restated understanding}
> Is this correct, or should I adjust my understanding?

**GATE**: Wait for user response before proceeding.

---

## Phase 2: FOUNDATION - Problem Discovery

Ask these questions (present all at once, user can answer together):

> **Foundation Questions:**
>
> 1. **Who** has this problem? Be specific - not just "users" but what type of person/role?
> 2. **What** problem are they facing? Describe the observable pain, not the assumed need.
> 3. **Why** can't they solve it today? What alternatives exist and why do they fail?
> 4. **Why now?** What changed that makes this worth building?
> 5. **How** will you know if you solved it? What would success look like?

**GATE**: Wait for user responses before proceeding.

---

## Phase 3: GROUNDING - Market & Context Research

After foundation answers, conduct research using specialized agents:

**Use Task tool with `subagent_type="Explore"` for market research:**

```
Research the market context for: {product/feature idea}

FIND:
1. Similar products/features in the market
2. How competitors solve this problem
3. Common patterns and anti-patterns
4. Recent trends or changes in this space
```

**If codebase exists, use Task tool for codebase exploration:**

```
Find existing functionality relevant to: {product/feature idea}

LOCATE:
1. Related existing functionality
2. Patterns that could be leveraged
3. Technical constraints or opportunities
```

**Summarize findings to user:**

> **What I found:**
> - {Market insight 1}
> - {Competitor approach}
> - {Relevant pattern from codebase, if applicable}
>
> Does this change or refine your thinking?

**GATE**: Brief pause for user input.

---

## Phase 4: DEEP DIVE - Vision & Users

Based on foundation + research, ask:

> **Vision & Users:**
>
> 1. **Vision**: In one sentence, what's the ideal end state if this succeeds wildly?
> 2. **Primary User**: Describe your most important user - their role, context, triggers
> 3. **Job to Be Done**: Complete: "When [situation], I want to [motivation], so I can [outcome]."
> 4. **Non-Users**: Who is explicitly NOT the target? Who should we ignore?
> 5. **Constraints**: What limitations exist? (time, budget, technical, regulatory)

**GATE**: Wait for user responses before proceeding.

---

## Phase 5: GROUNDING - Technical Feasibility

**If codebase exists, launch exploration agents:**

Use Task tool to:
1. Assess technical feasibility
2. Analyze technical constraints
3. Find existing infrastructure and patterns

**Summarize to user:**

> **Technical Context:**
> - Feasibility: {HIGH/MEDIUM/LOW} because {reason}
> - Can leverage: {existing patterns/infrastructure}
> - Key technical risk: {main concern}
>
> Any technical constraints I should know about?

**GATE**: Brief pause for user input.

---

## Phase 6: DECISIONS - Scope & Approach

Ask final clarifying questions:

> **Scope & Approach:**
>
> 1. **MVP Definition**: What's the absolute minimum to test if this works?
> 2. **Must Have vs Nice to Have**: What 2-3 things MUST be in v1? What can wait?
> 3. **Key Hypothesis**: Complete: "We believe [capability] will [solve problem] for [users]. We'll know we're right when [measurable outcome]."
> 4. **Out of Scope**: What are you explicitly NOT building?
> 5. **Open Questions**: What uncertainties could change the approach?

**GATE**: Wait for user responses before generating.

---

## Phase 7: GENERATE - Write PRD

**Output path**: `.claude/PRPs/prds/{kebab-case-name}.prd.md`

Create directory if needed: `mkdir -p .claude/PRPs/prds`

### PRD Template

```markdown
# {Product/Feature Name}

## Problem Statement

{2-3 sentences: Who has what problem, and what's the cost of not solving it?}

## Evidence

- {User quote, data point, or observation that proves this problem exists}
- {Another piece of evidence}
- {If none: "Assumption - needs validation through [method]"}

## Proposed Solution

{One paragraph: What we're building and why this approach over alternatives}

## Key Hypothesis

We believe {capability} will {solve problem} for {users}.
We'll know we're right when {measurable outcome}.

## What We're NOT Building

- {Out of scope item 1} - {why}
- {Out of scope item 2} - {why}

## Success Metrics

| Metric | Target | How Measured |
|--------|--------|--------------|
| {Primary metric} | {Specific number} | {Method} |
| {Secondary metric} | {Specific number} | {Method} |

## Open Questions

- [ ] {Unresolved question 1}
- [ ] {Unresolved question 2}

---

## Users & Context

**Primary User**
- **Who**: {Specific description}
- **Current behavior**: {What they do today}
- **Trigger**: {What moment triggers the need}
- **Success state**: {What "done" looks like}

**Job to Be Done**
When {situation}, I want to {motivation}, so I can {outcome}.

**Non-Users**
{Who this is NOT for and why}

---

## Solution Detail

### Core Capabilities (MoSCoW)

| Priority | Capability | Rationale |
|----------|------------|-----------|
| Must | {Feature} | {Why essential} |
| Must | {Feature} | {Why essential} |
| Should | {Feature} | {Why important but not blocking} |
| Could | {Feature} | {Nice to have} |
| Won't | {Feature} | {Explicitly deferred and why} |

### MVP Scope

{What's the minimum to validate the hypothesis}

### User Flow

{Critical path - shortest journey to value}

---

## Technical Approach

**Feasibility**: {HIGH/MEDIUM/LOW}

**Architecture Notes**
- {Key technical decision and why}
- {Dependency or integration point}

**Technical Risks**

| Risk | Likelihood | Mitigation |
|------|------------|------------|
| {Risk} | {H/M/L} | {How to handle} |

---

## Implementation Phases

| # | Phase | Description | Status | Parallel | Depends | PRP Plan |
|---|-------|-------------|--------|----------|---------|----------|
| 1 | {Phase name} | {What this phase delivers} | pending | - | - | - |
| 2 | {Phase name} | {What this phase delivers} | pending | - | 1 | - |
| 3 | {Phase name} | {What this phase delivers} | pending | with 4 | 2 | - |
| 4 | {Phase name} | {What this phase delivers} | pending | with 3 | 2 | - |

### Phase Details

**Phase 1: {Name}**
- **Goal**: {What we're trying to achieve}
- **Scope**: {Bounded deliverables}
- **Success signal**: {How we know it's done}

---

## Decisions Log

| Decision | Choice | Alternatives | Rationale |
|----------|--------|--------------|-----------|
| {Decision} | {Choice} | {Options considered} | {Why this one} |

---

## Research Summary

**Market Context**
{Key findings from market research}

**Technical Context**
{Key findings from technical exploration}

---

*Generated: {timestamp}*
*Status: DRAFT - needs validation*
```

---

## Phase 8: OUTPUT - Summary

After generating, report:

```markdown
## PRD Created

**File**: `.claude/PRPs/prds/{name}.prd.md`

### Summary
**Problem**: {One line}
**Solution**: {One line}
**Key Metric**: {Primary success metric}

### Validation Status

| Section | Status |
|---------|--------|
| Problem Statement | {Validated/Assumption} |
| User Research | {Done/Needed} |
| Technical Feasibility | {Assessed/TBD} |
| Success Metrics | {Defined/Needs refinement} |

### Recommended Next Step
{One of: user research, technical spike, prototype, stakeholder review, etc.}

### To Start Implementation
Run: `/prp-plan .claude/PRPs/prds/{name}.prd.md`
```

---

## Success Criteria

- **PROBLEM_VALIDATED**: Problem is specific and evidenced
- **USER_DEFINED**: Primary user is concrete, not generic
- **HYPOTHESIS_CLEAR**: Testable hypothesis with measurable outcome
- **SCOPE_BOUNDED**: Clear must-haves and explicit out-of-scope
- **QUESTIONS_ACKNOWLEDGED**: Uncertainties are listed, not hidden
- **ACTIONABLE**: A skeptic could understand why this is worth building

---

## Usage Example

```
User: /prp-prd "team collaboration workspace"

AI: I understand you want to build: A collaborative workspace where team members
can share files, communicate, and track project progress together.
Is this correct?

User: Yes, but it should focus on async collaboration for remote teams.

AI: **Foundation Questions:**

1. **Who** has this problem? Remote teams, distributed across time zones
2. **What** problem are they facing? They can't collaborate effectively when not online simultaneously
3. **Why** can't they solve it today? Slack is real-time focused, email is unstructured
4. **Why now?** Remote work increased 300% since 2020
5. **How** will you know if you solved it? Teams complete projects 20% faster

[After user answers, AI researches market and codebase...]

AI: **What I found:**
- Notion and Linear dominate async collaboration
- Key differentiator: AI-powered meeting summarization
- Your codebase has real-time infrastructure from chat feature

**Vision & Users:**

1. **Vision**: Async-first workspace where teams collaborate across time zones seamlessly
2. **Primary User**: Remote project manager coordinating distributed team of 5-20
3. **Job to Be Done**: "When I finish my workday, I want to leave clear handoffs, so my team can continue without waiting"
4. **Non-Users**: Teams needing real-time collaboration (use Slack instead)
5. **Constraints**: Must launch MVP in 8 weeks, integrate with existing auth

[After user answers, AI generates PRD...]

→ .claude/PRPs/prds/team-workspace.prd.md

## PRD Created

**File**: `.claude/PRPs/prds/team-workspace.prd.md`

### Summary
**Problem**: Remote teams lose productivity waiting for synchronous communication
**Solution**: Async-first workspace with smart handoffs and context preservation
**Key Metric**: Project completion time reduced by 20%

### Implementation Phases

| # | Phase | Description | Status |
|---|-------|-------------|--------|
| 1 | Core | Workspace and project structure | pending |
| 2 | Content | Async messaging and documents | pending |
| 3 | Handoffs | Smart context transfer | pending |
| 4 | AI | Meeting summarization | pending |

### To Start Implementation
Run: `/prp-plan .claude/PRPs/prds/team-workspace.prd.md`
```
