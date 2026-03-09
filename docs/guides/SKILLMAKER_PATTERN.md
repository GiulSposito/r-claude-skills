# SkillMaker - Complete Guide

## What Was Created

A comprehensive Claude Code skill for creating production-ready skills following best practices. The `skillMaker` skill is now available in this project at `.claude/skills/skillMaker/`.

## Project Structure

```
.claude/skills/skillMaker/
├── SKILL.md                           # Main skill definition (5000+ lines)
├── README.md                          # User documentation
├── templates/
│   └── basic-skill-template.md       # 5 skill type templates
├── examples/
│   └── skill-structures.md           # Complete working examples
└── references/
    └── skill-patterns.md             # Comprehensive pattern catalog
```

## Key Features

### 1. Comprehensive Workflow
- **Phase 1**: Requirements gathering via targeted questions
- **Phase 2**: Structure decision based on complexity
- **Phase 3**: Content generation following patterns
- **Phase 4**: Optimization for performance
- **Phase 5**: Testing and validation

### 2. Five Skill Types Supported

**Reference Skills** - Background knowledge Claude applies automatically
- Example: Code conventions, API patterns, style guides
- Configuration: `user-invocable: false`

**Task Workflow Skills** - Multi-step processes users invoke manually
- Example: Feature creation, deployment, testing
- Configuration: `disable-model-invocation: true`

**Dynamic Context Skills** - Skills leveraging live data
- Example: PR reviews, git analysis, project scanning
- Uses: Shell command injection with `!`command``

**Bundled Skills** - Complex skills with supporting files
- Example: Code generators with templates, analyzers with docs
- Structure: templates/, examples/, references/, scripts/

**Research Skills** - Deep exploration in isolated context
- Example: Architecture analysis, dependency mapping
- Configuration: `context: fork`, `agent: Explore`

### 3. Template Library

Pre-built templates for quick starts:
- Simple reference skill
- Task workflow skill
- Dynamic context skill
- Bundled skill with supporting files
- Research/exploration skill

### 4. Pattern Catalog

Comprehensive patterns covering:
- **Description patterns** - Writing effective trigger descriptions
- **Argument handling** - Positional, optional, and flexible arguments
- **Dynamic context** - Shell command injection patterns
- **Tool restrictions** - Appropriate permission scopes
- **Invocation control** - User-only, Claude-only, or both
- **File organization** - Optimal structure for different complexities
- **Error handling** - Graceful failures and validation
- **Performance** - Optimization techniques

### 5. Real-World Examples

Complete, working skill examples:
1. **API Conventions** (Reference skill)
2. **Feature Creator** (Task workflow skill)
3. **PR Reviewer** (Dynamic context skill)
4. **Test Generator** (Bundled skill)
5. **Architecture Analyzer** (Research skill)

## How to Use SkillMaker

### Method 1: Direct Invocation

```bash
/skillMaker
```

### Method 2: Natural Conversation

Just mention creating a skill:
- "Create a skill for API documentation"
- "Make a skill that reviews PRs"
- "I want to build a skill for deployment"
- "Help me create a skill for testing"

### Method 3: Specific Requests

Provide details upfront:
- "Create a user-only skill with arguments for migrating components"
- "Build a Claude-only skill for our naming conventions"
- "Generate a skill that uses git commands to analyze commits"

## What Happens When Invoked

1. **Requirements Gathering**
   - SkillMaker asks targeted questions using AskUserQuestion
   - Determines purpose, triggers, invocation control, tools needed
   - Identifies complexity level and context requirements

2. **Structure Generation**
   - Decides if simple (SKILL.md only) or bundled (with supporting files)
   - Creates appropriate directory structure
   - Generates file organization

3. **Content Creation**
   - Writes main SKILL.md with:
     - Properly formatted frontmatter
     - Clear description with triggers
     - Structured workflow/instructions
     - Examples and patterns
   - Creates supporting files if needed:
     - Templates for generation
     - Examples for reference
     - Reference docs for details
     - Scripts for automation

4. **Optimization**
   - Applies performance optimizations
   - Adds error handling
   - Configures tool restrictions
   - Sets invocation flags

5. **Validation**
   - Validates YAML frontmatter
   - Checks file references
   - Verifies shell command syntax
   - Provides testing checklist

## Key Patterns Learned from Documentation

### 1. Description Quality Matters

**Good Description:**
```yaml
description: |
  Generate API documentation from code.
  Use when user asks to "document the API", "create API docs",
  "generate OpenAPI spec", mentions "Swagger" or "API documentation",
  or discusses documenting endpoints.
```

**Bad Description:**
```yaml
description: Helpful skill for documentation tasks
```

### 2. File Structure Based on Size

- **< 200 lines**: Single SKILL.md
- **200-500 lines**: SKILL.md + examples/
- **> 500 lines**: Split into SKILL.md + templates/ + examples/ + references/

### 3. Invocation Control

```yaml
# Both can invoke (default)
# Omit both flags

# User-only (for side-effect tasks)
disable-model-invocation: true

# Claude-only (for background knowledge)
user-invocable: false
```

### 4. Tool Restrictions

```yaml
# Read-only
allowed-tools: Read, Grep, Glob

# Safe modification
allowed-tools: Read, Write, Edit

# Specific commands
allowed-tools: Read, Write, Bash(npm test:*), Bash(git status:*)
```

### 5. Dynamic Context Injection

```markdown
Current branch: !`git branch --show-current 2>/dev/null || echo "Not a git repo"`
```

## Best Practices Built-In

SkillMaker automatically applies:

✅ **Specific descriptions** with 3+ trigger phrases
✅ **Appropriate structure** based on complexity
✅ **Tool restrictions** matching actual needs
✅ **Error handling** in shell commands
✅ **Supporting files** properly referenced
✅ **Concrete examples** (2-3 per skill)
✅ **Optimization patterns** for performance
✅ **Validation checklist** for testing

## Testing the Skill

### Test 1: Manual Invocation
```bash
/skillMaker
```

### Test 2: Trigger Phrases
In conversation, say:
- "Create a skill for..."
- "Make a new skill"
- "Build a skill"
- "Generate skill"

### Test 3: Specific Request
"Create a skill that deploys to staging when I type /deploy-staging"

## Example Usage Scenarios

### Scenario 1: Code Conventions Skill

**User**: "Create a skill for our TypeScript naming conventions"

**SkillMaker will**:
1. Identify it as a reference skill (background knowledge)
2. Set `user-invocable: false` (Claude-only)
3. Generate SKILL.md with naming patterns
4. Include examples of good/bad naming
5. No templates needed (simple structure)

### Scenario 2: Feature Creation Skill

**User**: "Build a skill that creates React components with tests"

**SkillMaker will**:
1. Identify as task workflow skill
2. Set `disable-model-invocation: true` (user-only)
3. Create bundled structure with:
   - templates/component-template.tsx
   - templates/test-template.test.tsx
   - examples/generated-component/
4. Add argument handling for component name
5. Include validation and testing steps

### Scenario 3: PR Review Skill

**User**: "Make a skill for reviewing pull requests"

**SkillMaker will**:
1. Identify need for GitHub CLI
2. Add dynamic context: `!`gh pr view``
3. Set `allowed-tools: Bash(gh *), Read`
4. Create review checklist
5. Include both manual and auto-invoke options

## Skill Invocation Flow

```
User types /skillMaker (or mentions creating skill)
    ↓
SKILL.md frontmatter processed
    ↓
String substitutions applied ($ARGUMENTS, ${CLAUDE_SKILL_DIR}, etc.)
    ↓
Shell commands in !`...` execute (preprocessing)
    ↓
Complete content sent to Claude
    ↓
Claude executes workflow
    ↓
Questions asked via AskUserQuestion
    ↓
Files generated with Write/Edit tools
    ↓
Validation checklist provided
```

## Advanced Features

### 1. Multi-Phase Workflows
Skills can have checkpoints for user approval between phases

### 2. Template Selection Logic
Dynamic template selection based on project detection

### 3. Conditional Context
Different information gathering based on environment

### 4. Incremental Generation
Large output generation in steps with validation

### 5. Subagent Delegation
Research skills run in isolated context

## Troubleshooting

### Skill doesn't appear in autocomplete
- Check SKILL.md is in correct location
- Verify frontmatter YAML is valid
- Ensure no syntax errors

### Skill doesn't auto-trigger
- Add more specific trigger phrases to description
- Remove `disable-model-invocation: true` if present
- Test with exact phrases from description

### Shell commands fail
- Add error handling: `2>/dev/null || echo "fallback"`
- Test commands independently first
- Check commands available in user's environment

## What Makes This Implementation Special

1. **Comprehensive**: Covers all skill types and patterns from documentation
2. **Educational**: Teaches best practices through examples and patterns
3. **Interactive**: Uses AskUserQuestion for guided creation
4. **Production-Ready**: Generates skills following official conventions
5. **Well-Organized**: Proper file structure with supporting materials
6. **Optimized**: Applies performance and maintainability patterns
7. **Validated**: Includes testing and validation checklist

## Documentation Sources

This skill was built from:
1. **Official Claude Code documentation** (via claude-code-guide agent)
2. **Example skills** from official plugins
3. **Best practices** from the skill development guide
4. **Real-world patterns** from production skills

## Next Steps

### To Use SkillMaker:
1. Type `/skillMaker` or mention creating a skill
2. Answer the guided questions
3. Review generated files
4. Test the new skill
5. Iterate and refine

### To Extend SkillMaker:
1. Add more templates to templates/
2. Contribute examples to examples/
3. Document new patterns in references/
4. Share custom skill patterns

### To Install System-Wide:
```bash
# Copy to personal skills directory
cp -r .claude/skills/skillMaker ~/.claude/skills/

# Now available in all projects
```

## Resources

- Main skill: `.claude/skills/skillMaker/SKILL.md`
- Templates: `.claude/skills/skillMaker/templates/`
- Examples: `.claude/skills/skillMaker/examples/`
- Patterns: `.claude/skills/skillMaker/references/`
- Documentation: `.claude/skills/skillMaker/README.md`

## Summary

The `skillMaker` skill is a comprehensive, production-ready tool for creating Claude Code skills. It:

- Guides you through the entire creation process
- Applies best practices automatically
- Generates appropriate file structures
- Includes templates, examples, and patterns
- Provides validation and testing support
- Follows official conventions and optimizations

**Ready to create your first skill?** Just type `/skillMaker`!

---

*Created: 2026-03-08*
*Version: 1.0.0*
*Location: .claude/skills/skillMaker/*
