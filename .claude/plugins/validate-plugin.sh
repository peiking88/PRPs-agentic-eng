#!/bin/bash
# Codebuddy Plugin Format Validator
# Validates a plugin directory against the plugin specification
#
# Usage: ./validate-plugin.sh <plugin-directory>
#
# Exit codes:
#   0 - Validation passed
#   1 - Validation failed

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

PLUGIN_DIR="${1:-.}"
ERRORS=0
WARNINGS=0

echo "=========================================="
echo "Codebuddy Plugin Validator"
echo "=========================================="
echo ""
echo "Validating plugin at: $PLUGIN_DIR"
echo ""

# Function to print error
error() {
    echo -e "${RED}❌ ERROR: $1${NC}"
    ERRORS=$((ERRORS + 1))
}

# Function to print success
success() {
    echo -e "${GREEN}✅ $1${NC}"
}

# Function to print warning
warning() {
    echo -e "${YELLOW}⚠️  WARNING: $1${NC}"
    WARNINGS=$((WARNINGS + 1))
}

# ==========================================
# Check 1: Directory exists
# ==========================================
if [ ! -d "$PLUGIN_DIR" ]; then
    error "Plugin directory does not exist: $PLUGIN_DIR"
    echo ""
    echo "=========================================="
    echo -e "${RED}Validation failed with $ERRORS error(s)${NC}"
    echo "=========================================="
    exit 1
fi
success "Plugin directory exists"

# ==========================================
# Check 2: SKILL.md exists
# ==========================================
if [ ! -f "$PLUGIN_DIR/SKILL.md" ]; then
    error "SKILL.md not found at root"
else
    success "SKILL.md exists at root"
    
    # Check for YAML frontmatter
    if head -1 "$PLUGIN_DIR/SKILL.md" | grep -q "^---$"; then
        success "SKILL.md has YAML frontmatter delimiter"
        
        # Check if frontmatter is closed
        if head -10 "$PLUGIN_DIR/SKILL.md" | grep -n "^---$" | wc -l | grep -q "2"; then
            success "SKILL.md frontmatter is properly closed"
            
            # Extract frontmatter and check required fields
            FRONTMATTER=$(sed -n '/^---$/,/^---$/p' "$PLUGIN_DIR/SKILL.md" | head -n -1 | tail -n +2)
            
            if echo "$FRONTMATTER" | grep -q "^name:"; then
                SKILL_NAME=$(echo "$FRONTMATTER" | grep "^name:" | sed 's/^name:[[:space:]]*//')
                success "SKILL.md has 'name' field: $SKILL_NAME"
            else
                error "SKILL.md frontmatter missing 'name' field"
            fi
            
            if echo "$FRONTMATTER" | grep -q "^description:"; then
                success "SKILL.md has 'description' field"
            else
                error "SKILL.md frontmatter missing 'description' field"
            fi
        else
            error "SKILL.md frontmatter not properly closed with '---'"
        fi
    else
        error "SKILL.md missing YAML frontmatter (must start with '---')"
    fi
fi

# ==========================================
# Check 3: plugin.json exists
# ==========================================
if [ ! -f "$PLUGIN_DIR/plugin.json" ]; then
    error "plugin.json not found"
else
    success "plugin.json exists"
    
    # Check if valid JSON
    if command -v jq &> /dev/null; then
        if jq empty "$PLUGIN_DIR/plugin.json" 2>/dev/null; then
            success "plugin.json is valid JSON"
            
            # Check required fields
            NAME=$(jq -r '.name' "$PLUGIN_DIR/plugin.json" 2>/dev/null)
            VERSION=$(jq -r '.version' "$PLUGIN_DIR/plugin.json" 2>/dev/null)
            DESC=$(jq -r '.description' "$PLUGIN_DIR/plugin.json" 2>/dev/null)
            
            # Validate name
            if [ "$NAME" = "null" ] || [ -z "$NAME" ]; then
                error "plugin.json missing 'name' field"
            elif [[ ! "$NAME" =~ ^[a-z][a-z0-9-]*$ ]]; then
                error "plugin.json 'name' must be kebab-case (lowercase, numbers, hyphens only): $NAME"
            else
                success "plugin.json 'name' is valid: $NAME"
                
                # Check for reserved prefixes
                if [[ "$NAME" =~ ^(claude|anthropic)- ]]; then
                    error "Plugin name uses reserved prefix (claude-*, anthropic-*)"
                fi
            fi
            
            # Validate version
            if [ "$VERSION" = "null" ] || [ -z "$VERSION" ]; then
                error "plugin.json missing 'version' field"
            elif [[ ! "$VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+ ]]; then
                error "plugin.json 'version' must be semver (x.y.z): $VERSION"
            else
                success "plugin.json 'version' is valid: $VERSION"
            fi
            
            # Validate description
            if [ "$DESC" = "null" ] || [ -z "$DESC" ]; then
                error "plugin.json missing 'description' field"
            elif [ ${#DESC} -lt 10 ]; then
                error "plugin.json 'description' must be at least 10 characters (currently ${#DESC})"
            else
                success "plugin.json 'description' is valid (${#DESC} chars)"
            fi
            
            # Optional fields warnings
            AUTHOR=$(jq -r '.author' "$PLUGIN_DIR/plugin.json" 2>/dev/null)
            LICENSE=$(jq -r '.license' "$PLUGIN_DIR/plugin.json" 2>/dev/null)
            
            [ "$AUTHOR" = "null" ] && warning "plugin.json missing optional 'author' field"
            [ "$LICENSE" = "null" ] && warning "plugin.json missing optional 'license' field"
            
        else
            error "plugin.json is not valid JSON"
            jq empty "$PLUGIN_DIR/plugin.json" 2>&1 || true
        fi
    else
        warning "jq not installed - skipping JSON validation"
        # Basic JSON check
        if grep -q '"name"' "$PLUGIN_DIR/plugin.json" && \
           grep -q '"version"' "$PLUGIN_DIR/plugin.json" && \
           grep -q '"description"' "$PLUGIN_DIR/plugin.json"; then
            success "plugin.json appears to have required fields (install jq for full validation)"
        else
            error "plugin.json missing required fields"
        fi
    fi
fi

# ==========================================
# Check 4: Directory name matches plugin name
# ==========================================
DIR_NAME=$(basename "$(cd "$PLUGIN_DIR" && pwd)")
if [ -n "$NAME" ] && [ "$NAME" != "null" ]; then
    if [ "$DIR_NAME" = "$NAME" ]; then
        success "Directory name matches plugin name: $NAME"
    else
        warning "Directory name '$DIR_NAME' differs from plugin name '$NAME'"
    fi
fi

# ==========================================
# Check 5: No forbidden XML tags in SKILL.md
# ==========================================
if [ -f "$PLUGIN_DIR/SKILL.md" ]; then
    # Check for forbidden XML-like tags (excluding allowed pseudo-tags like <promise>)
    # Forbidden: tags that look like HTML/XML elements (e.g., <script>, <div>, <a href>)
    # Allowed: pseudo-tags used as markers (e.g., <promise>COMPLETE</promise>)
    FORBIDDEN_TAGS=$(grep -oE "<[a-zA-Z]+[^>]*>" "$PLUGIN_DIR/SKILL.md" | grep -vE "^<(promise|COMPLETE|TODO|FIXME|NOTE|IMPORTANT|WARNING|CRITICAL)>$" | head -5)
    if [ -n "$FORBIDDEN_TAGS" ]; then
        error "SKILL.md contains forbidden XML-like tags: $FORBIDDEN_TAGS"
    else
        success "SKILL.md contains no forbidden XML tags"
    fi
fi

# ==========================================
# Check 6: Optional directories
# ==========================================
for dir in skills agents templates scripts resources; do
    if [ -d "$PLUGIN_DIR/$dir" ]; then
        FILE_COUNT=$(find "$PLUGIN_DIR/$dir" -type f | wc -l)
        success "Optional directory '$dir' exists ($FILE_COUNT files)"
    fi
done

# ==========================================
# Summary
# ==========================================
echo ""
echo "=========================================="
if [ $ERRORS -eq 0 ]; then
    echo -e "${GREEN}✅ Plugin validation passed!${NC}"
    [ $WARNINGS -gt 0 ] && echo -e "${YELLOW}   ($WARNINGS warning(s))${NC}"
    echo "=========================================="
    exit 0
else
    echo -e "${RED}❌ Plugin validation failed with $ERRORS error(s)${NC}"
    [ $WARNINGS -gt 0 ] && echo -e "${YELLOW}   ($WARNINGS warning(s))${NC}"
    echo "=========================================="
    exit 1
fi
