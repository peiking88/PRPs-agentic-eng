# Base PRP Template

Use this template for creating comprehensive Product Requirements Prompts.

---

## Goal

**Feature Goal**: [Specific, measurable end state of what needs to be built]

**Deliverable**: [Concrete artifact - API endpoint, service class, integration, etc.]

**Success Definition**: [How you'll know this is complete and working]

---

## User Persona (if applicable)

**Target User**: [Specific user type - developer, end user, admin, etc.]

**Use Case**: [Primary scenario when this feature will be used]

**User Journey**: [Step-by-step flow of how user interacts with this feature]

**Pain Points Addressed**: [Specific user frustrations this feature solves]

---

## Why

- [Business value and user impact]
- [Integration with existing features]
- [Problems this solves and for whom]

---

## What

[User-visible behavior and technical requirements]

### Success Criteria

- [ ] [Specific measurable outcomes]

---

## All Needed Context

### Context Completeness Check

_Before writing this PRP, validate: "If someone knew nothing about this codebase, would they have everything needed to implement this successfully?"_

### Documentation & References

```yaml
# MUST READ - Include these in your context window
- url: [Complete URL with section anchor]
  why: [Specific methods/concepts needed for implementation]
  critical: [Key insights that prevent common implementation errors]

- file: [exact/path/to/pattern/file.py]
  why: [Specific pattern to follow - class structure, error handling, etc.]
  pattern: [Brief description of what pattern to extract]
  gotcha: [Known constraints or limitations to avoid]
```

### Current Codebase Tree

```bash
# Run `tree` in the root of the project
```

### Desired Codebase Tree

```bash
# Show files to be added and their responsibilities
```

### Known Gotchas & Library Quirks

```python
# CRITICAL: [Library name] requires [specific setup]
# Example: FastAPI requires async functions for endpoints
```

---

## Implementation Blueprint

### Data Models and Structure

Create the core data models for type safety and consistency.

### Implementation Tasks (ordered by dependencies)

```yaml
Task 1: CREATE src/models/{domain}_models.py
  - IMPLEMENT: {SpecificModel}Request, {SpecificModel}Response
  - FOLLOW pattern: src/models/existing_model.py
  - NAMING: CamelCase for classes, snake_case for fields
  - VALIDATE: `ruff check src/models/ && mypy src/models/`

Task 2: CREATE src/services/{domain}_service.py
  - IMPLEMENT: {Domain}Service class with async methods
  - FOLLOW pattern: src/services/database_service.py
  - DEPENDENCIES: Import models from Task 1
  - VALIDATE: `ruff check src/services/ && mypy src/services/`

Task 3: CREATE tests/
  - IMPLEMENT: Unit tests for all service methods
  - FOLLOW pattern: tests/test_existing_service.py
  - COVERAGE: All public methods with positive and negative cases
  - VALIDATE: `pytest tests/ -v`
```

### Implementation Patterns

```python
# Show critical patterns and gotchas

# Example: Service method pattern
async def {domain}_operation(self, request: {Domain}Request) -> {Domain}Response:
    # PATTERN: Input validation first
    validated = self.validate_request(request)

    # GOTCHA: [Library-specific constraint]
    # CRITICAL: [Non-obvious requirement]

    return {Domain}Response(status="success", data=result)
```

### Integration Points

```yaml
DATABASE:
  - migration: "Add column 'feature_enabled' to users table"
  - index: "CREATE INDEX idx_feature_lookup ON users(feature_id)"

CONFIG:
  - add to: config/settings.py
  - pattern: "FEATURE_TIMEOUT = int(os.getenv('FEATURE_TIMEOUT', '30'))"

ROUTES:
  - add to: src/api/routes.py
  - pattern: "router.include_router(feature_router, prefix='/feature')"
```

---

## Validation Loop

### Level 1: Syntax & Style

```bash
# Run after each file creation
ruff check src/{new_files} --fix
mypy src/{new_files}
ruff format src/{new_files}

# Expected: Zero errors
```

### Level 2: Unit Tests

```bash
# Test each component
pytest src/services/tests/test_{domain}_service.py -v

# Coverage validation
pytest src/ --cov=src --cov-report=term-missing

# Expected: All tests pass
```

### Level 3: Integration Testing

```bash
# Service startup validation
python main.py &
sleep 3

# Health check
curl -f http://localhost:8000/health

# Feature endpoint testing
curl -X POST http://localhost:8000/{endpoint} \
  -H "Content-Type: application/json" \
  -d '{"test": "data"}'

# Expected: All integrations working
```

### Level 4: Domain-Specific Validation

```bash
# Performance testing (if applicable)
ab -n 100 -c 10 http://localhost:8000/{endpoint}

# Security scanning (if applicable)
bandit -r src/

# Expected: All validations pass
```

---

## Final Validation Checklist

### Technical Validation

- [ ] All 4 validation levels completed successfully
- [ ] All tests pass
- [ ] No linting errors
- [ ] No type errors

### Feature Validation

- [ ] All success criteria met
- [ ] Manual testing successful
- [ ] Error cases handled gracefully
- [ ] Integration points work as specified

### Code Quality Validation

- [ ] Follows existing codebase patterns
- [ ] File placement matches desired structure
- [ ] Anti-patterns avoided
- [ ] Dependencies properly managed

---

## Anti-Patterns to Avoid

- ❌ Don't create new patterns when existing ones work
- ❌ Don't skip validation because "it should work"
- ❌ Don't ignore failing tests - fix them
- ❌ Don't use sync functions in async context
- ❌ Don't hardcode values that should be config
- ❌ Don't catch all exceptions - be specific
