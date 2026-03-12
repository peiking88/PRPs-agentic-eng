# prp-framework Configuration

## Meta
- **Plugin**: prp-framework
- **Version**: 1.0.0
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

### validationLevels
- **Type**: integer
- **Default**: 3
- **Min**: 1
- **Max**: 6
- **Description**: Number of validation levels to run (1-6)
- **Value**: 3

### autoArchive
- **Type**: boolean
- **Default**: true
- **Description**: Automatically archive completed plans to completed/ folder
- **Value**: true

## Advanced Settings

### customValidationCommands
- **Type**: array
- **Default**: []
- **Description**: Custom validation commands to run after each phase
- **Value**: []

### excludedPaths
- **Type**: array
- **Default**: ["node_modules", ".git", "dist", "build"]
- **Description**: Paths to exclude from codebase analysis
- **Value**: ["node_modules", ".git", "dist", "build"]

## Notes

- All paths are relative to project root
- validationLevels: 1=static, 2=unit, 3=integration, 4=domain, 5=ui, 6=manual
- Set maxIterations higher for complex features
- Disable autoArchive if you want to keep plans in active folder

## Validation

Run the configuration validator:
```bash
.claude/plugins/scripts/validate-config.sh prp-framework
```
