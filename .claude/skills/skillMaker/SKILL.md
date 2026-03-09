---
name: skillMaker
description: Create new Claude Code skills following best practices. Use when user asks to "create a skill", "make a new skill", "build a skill", "generate skill", mentions "skill maker", discusses creating Claude Code automations, or wants help building custom Claude skills.
version: 1.0.0
allowed-tools: Read, Write, Edit, Glob, Bash
---

# Skill Maker - Claude Code Skill Generator

Create production-ready Claude Code skills following established patterns and best practices.

## Overview

This skill guides you through creating well-structured, effective Claude Code skills by:
1. Understanding the skill's purpose and trigger conditions
2. Gathering requirements through targeted questions
3. Generating appropriate file structure and content
4. Following optimization patterns and conventions

## When This Skill Activates

Use this skill when the user wants to:
- Create a new Claude Code skill from scratch
- Understand skill structure and patterns
- Generate skill templates with best practices
- Convert manual workflows into reusable skills

## Skill Creation Workflow

### Phase 1: Requirements Gathering

Ask the user these key questions (use AskUserQuestion for efficiency):

1. **Purpose & Trigger**
   - What should this skill do?
   - When should Claude invoke it automatically?
   - What phrases or keywords would users say to trigger it?

2. **Invocation Control**
   - Who can invoke it?
     - Both user and Claude (default)
     - User-only (for side-effect tasks: deploy, commit, delete)
     - Claude-only (for background knowledge/reference)

3. **Argument Pattern**
   - Does it need arguments? (e.g., `/migrate-component SearchBar React Vue`)
   - If yes, what are they and how should they be used?

4. **Tool Requirements**
   - What tools will it need? (Read, Write, Edit, Bash, Grep, Glob, Agent, etc.)
   - Should tool access be restricted for safety?

5. **Complexity Level**
   - Simple reference skill (conventions, patterns)
   - Task workflow skill (multi-step process)
   - Dynamic context skill (uses shell commands)
   - Bundled skill (includes templates, scripts, examples)

6. **Execution Context**
   - Inline in main conversation (default)
   - Isolated subagent (`context: fork`)
   - Specific agent type (`agent: Explore`)

### Phase 2: Structure Decision

Based on requirements, determine file structure:

**Simple skill** (reference/conventions):
```
.claude/skills/skill-name/
└── SKILL.md
```

**Bundled skill** (with supporting files):
```
.claude/skills/skill-name/
├── SKILL.md              # Main instructions
├── templates/            # Templates for generation
│   └── template.md
├── examples/             # Example outputs
│   └── example.md
├── references/           # Detailed reference docs
│   └── patterns.md
└── scripts/              # Helper scripts
    └── helper.sh
```

### Phase 3: Content Generation

Generate skill content following these patterns:

#### A. Frontmatter Configuration

```yaml
---
name: skill-name                    # Required: kebab-case identifier
description: |                      # Required: Clear trigger conditions
  [Action] when user asks to "[phrase]",
  "[another phrase]", mentions "[keyword]",
  or discusses [topic].
version: 1.0.0                      # Optional: Semantic version
disable-model-invocation: true      # Optional: User-only invocation
user-invocable: false               # Optional: Claude-only invocation
allowed-tools: Read, Grep, Glob     # Optional: Tool restrictions
model: claude-3-5-haiku             # Optional: Model override
context: fork                       # Optional: Isolated execution
agent: Explore                      # Optional: Specific agent type
---
```

**Description Writing Formula:**
- Start with verb: "Create", "Analyze", "Generate", "Review"
- Include specific trigger phrases users would say
- List relevant keywords
- Mention the domain/topic area

**Examples:**
```yaml
# Good - Specific and actionable
description: Generate API documentation from code. Use when user asks to "document the API", "create API docs", mentions "OpenAPI" or "Swagger", or discusses API documentation needs.

# Bad - Too vague
description: Helps with documentation tasks.
```

#### B. Main Content Structure

Follow this template for SKILL.md body:

```markdown
# [Skill Name] - [One-line Purpose]

[2-3 sentence overview of what this skill does and its value]

## Overview

[Detailed explanation of the skill's capabilities and when to use it]

## When This Skill Activates

[List specific scenarios that trigger this skill]

## Workflow / Process

[Step-by-step instructions if it's a task skill]

### Phase 1: [First Phase Name]
[Instructions for first phase]

### Phase 2: [Second Phase Name]
[Instructions for second phase]

## Guidelines / Patterns

[Best practices, conventions, or patterns to follow]

## Examples

[Include 2-3 concrete examples if relevant]

## Supporting Files

[Reference any templates, examples, or scripts]
- For [use case], see [file-name.md](file-name.md)
- Script for [action]: `${CLAUDE_SKILL_DIR}/scripts/helper.sh`

## Common Patterns

[Include reusable patterns or code snippets]

## Optimization Tips

[Performance or quality improvements]
```

#### C. Supporting Files

**When to create supporting files:**

1. **templates/** - Create when:
   - Skill generates structured output (API docs, test files, configs)
   - Users need consistent format across invocations
   - Content follows a repeatable pattern

2. **examples/** - Create when:
   - Complex output that benefits from reference
   - Multiple valid approaches to show
   - Helping users understand expected results

3. **references/** - Create when:
   - Detailed reference material (>500 lines)
   - Technical specifications or API docs
   - Comprehensive pattern libraries
   - Keep main SKILL.md focused, reference these for details

4. **scripts/** - Create when:
   - Preprocessing data before Claude sees it
   - Complex calculations or transformations
   - External tool integration
   - File system operations

**Reference linking pattern:**
```markdown
## Additional Resources

For complete details, see:
- API patterns: [references/api-patterns.md](references/api-patterns.md)
- Code examples: [examples/sample-output.md](examples/sample-output.md)
- Generation template: [templates/component-template.md](templates/component-template.md)
- Preprocessing script: `${CLAUDE_SKILL_DIR}/scripts/analyze.sh`
```

#### D. Dynamic Context Injection

Use shell command substitution for live data:

```markdown
## Current Project Context

- Repository: !`git remote get-url origin 2>/dev/null || echo "No git remote"`
- Current branch: !`git branch --show-current 2>/dev/null || echo "Not a git repo"`
- Recent commits: !`git log --oneline -3 2>/dev/null || echo "No commits"`
- Staged files: !`git diff --cached --name-only 2>/dev/null || echo "No staged files"`

## Dependencies

- Node version: !`node --version 2>/dev/null || echo "Node not installed"`
- Package manager: !`[ -f "package-lock.json" ] && echo "npm" || [ -f "yarn.lock" ] && echo "yarn" || [ -f "pnpm-lock.yaml" ] && echo "pnpm" || echo "Unknown"`
```

**Command patterns for common needs:**

| Need | Command Pattern |
|------|----------------|
| Git status | `git status --short` |
| Recent commits | `git log --oneline -N` |
| Changed files | `git diff --name-only` |
| PR info | `gh pr view --json title,body 2>/dev/null \|\| echo "Not in a PR"` |
| Project type | `ls package.json pyproject.toml go.mod` |
| Dependencies | `cat package.json \| jq '.dependencies'` |
| File count | `find src -name "*.js" \| wc -l` |

### Phase 4: Optimization

Apply these optimizations:

#### A. Context Efficiency
- Keep SKILL.md under 500 lines
- Move detailed references to separate files
- Use dynamic injection for live data
- Reference supporting files explicitly

#### B. Tool Restrictions
```yaml
# Read-only research skill
allowed-tools: Read, Grep, Glob

# Safe modification skill
allowed-tools: Read, Write, Edit

# Full automation
allowed-tools: Read, Write, Edit, Bash(npm *), Bash(git *)
```

#### C. Invocation Control
```yaml
# Default: Both can invoke (most common)
# Omit both flags

# User-only: Prevents accidental auto-invocation
disable-model-invocation: true

# Claude-only: Background knowledge/reference
user-invocable: false
```

#### D. Execution Context
```yaml
# Default: Inline execution (most efficient)
# Omit context flag

# Isolated subagent: For research/exploration
context: fork
agent: Explore

# Isolated subagent: For code work
context: fork
```

### Phase 5: Testing & Validation

After generating the skill, validate:

1. **Frontmatter syntax** - Valid YAML
2. **Description clarity** - Specific trigger conditions
3. **File references** - All referenced files exist
4. **Shell commands** - Valid syntax in dynamic injection blocks
5. **Tool alignment** - allowed-tools matches actual needs
6. **Invocation logic** - Flags match intended behavior

**Test invocation:**
```bash
# Test manual invocation
/skill-name arg1 arg2

# Test in conversation
# Use trigger phrases from description
```

## Skill Templates by Category

### Template 1: Reference/Conventions Skill
```yaml
---
name: coding-standards
description: Apply coding standards and conventions. Use when writing code, reviewing code, or when user asks about "code style", "conventions", or "standards".
user-invocable: false  # Claude-only background knowledge
---

# Coding Standards

Apply these conventions when writing code:

## Naming Conventions
- Variables: camelCase
- Constants: UPPER_SNAKE_CASE
- Classes: PascalCase

## File Structure
[patterns...]

## Best Practices
[guidelines...]
```

### Template 2: Task Workflow Skill
```yaml
---
name: create-feature
description: Create a new feature following project standards. Use when user asks to "add a feature", "create new feature", "implement feature", or discusses adding functionality.
disable-model-invocation: true  # User-only
allowed-tools: Read, Write, Edit, Bash
---

# Feature Creator

Create a complete feature following project patterns.

## Workflow

### Phase 1: Planning
1. Read existing similar features
2. Identify files to modify/create
3. Confirm approach with user

### Phase 2: Implementation
1. Create feature files
2. Add tests
3. Update documentation

### Phase 3: Validation
1. Run tests
2. Check formatting
3. Create commit

## Arguments

$0 - Feature name (kebab-case)
$1 - Feature type (component|page|api)
```

### Template 3: Dynamic Context Skill
```yaml
---
name: pr-summarizer
description: Summarize pull request changes. Use when user asks to "summarize PR", "explain changes", mentions "pull request summary", or discusses PR content.
allowed-tools: Bash(gh *)
---

# Pull Request Summarizer

## Current PR Context

- Title: !`gh pr view --json title -q .title 2>/dev/null || echo "Not in a PR context"`
- Author: !`gh pr view --json author -q .author.login 2>/dev/null || echo "N/A"`
- Status: !`gh pr view --json state -q .state 2>/dev/null || echo "Unknown"`

## Changes

!`gh pr diff 2>/dev/null || echo "No PR diff available"`

## Summary Instructions

Analyze the PR and provide:
1. High-level summary (2-3 sentences)
2. Key changes by file
3. Potential impacts
4. Testing recommendations
```

### Template 4: Bundled Skill with Templates
```yaml
---
name: api-documenter
description: Generate API documentation from code. Use when user asks to "document API", "create API docs", mentions "OpenAPI" or "Swagger", or discusses API documentation.
allowed-tools: Read, Write, Bash
---

# API Documenter

Generate comprehensive API documentation.

## Templates

Use these templates for structured output:
- OpenAPI spec: [templates/openapi.yaml](templates/openapi.yaml)
- Endpoint docs: [templates/endpoint.md](templates/endpoint.md)

## Process

1. Scan for API routes
2. Extract endpoint details
3. Generate documentation using templates
4. Validate with: `${CLAUDE_SKILL_DIR}/scripts/validate-openapi.sh`

## Examples

See [examples/sample-api-docs.md](examples/sample-api-docs.md) for expected format.
```

## Generation Checklist

Before finalizing, verify:

- [ ] `name` matches directory name (kebab-case)
- [ ] `description` includes specific trigger phrases
- [ ] Invocation control flags align with intended use
- [ ] `allowed-tools` covers actual tool needs
- [ ] Main SKILL.md is under 500 lines
- [ ] Supporting files are referenced in main content
- [ ] Shell commands use proper dynamic injection syntax
- [ ] Examples demonstrate key patterns
- [ ] File structure matches complexity needs

## Installation & Usage

After creating the skill:

1. **Save to correct location:**
   - Project: `.claude/skills/skill-name/SKILL.md`
   - Personal: `~/.claude/skills/skill-name/SKILL.md`

2. **Test invocation:**
   ```bash
   # Manual test
   /skill-name [arguments]

   # Automatic test
   # Use trigger phrases in conversation
   ```

3. **Verify activation:**
   - Check skill appears in `/` autocomplete
   - Verify description triggers work
   - Test with and without arguments

## Best Practices Recap

**DO:**
- Write specific, trigger-rich descriptions
- Keep SKILL.md focused and under 500 lines
- Use supporting files for complex content
- Restrict tools when possible for safety
- Use dynamic context for live data
- Include concrete examples
- Test trigger phrases

**DON'T:**
- Write vague descriptions ("helps with tasks")
- Put everything in one huge SKILL.md
- Forget to reference supporting files
- Over-restrict tools unnecessarily
- Hardcode data that can be dynamic
- Create skills with overlapping triggers
- Skip testing invocation patterns

## Common Patterns Library

### Pattern: Multi-Argument Skill
```yaml
Fix $0 by $1 in $2 files.
# $0 = bug description
# $1 = approach
# $2 = file pattern
```

### Pattern: Optional Arguments
```yaml
Generate tests for ${1:-all components}.
# $1 = optional component name, defaults to "all components"
```

### Pattern: Conditional Logic
```yaml
!`[ -f "package.json" ] && cat package.json || echo "{}"`
# Returns package.json if exists, else empty object
```

### Pattern: Error Handling
```yaml
!`git status 2>/dev/null || echo "Not a git repository"`
# Suppresses errors and provides fallback
```

## Skill Quality Metrics

Evaluate skill quality:

| Metric | Good | Needs Improvement |
|--------|------|-------------------|
| Description | 3+ trigger phrases, specific keywords | Generic, vague |
| Size | < 500 lines in SKILL.md | > 500 lines, no supporting files |
| Structure | Organized sections, clear flow | Wall of text, unclear |
| References | Explicitly linked supporting files | References missing |
| Examples | 2-3 concrete examples | No examples or too abstract |
| Dynamic context | Uses shell injection for live data | All static content |
| Tool restrictions | Aligned with actual needs | Too broad or too narrow |

## Troubleshooting

**Skill doesn't auto-trigger:**
- Check description has specific trigger phrases
- Verify no `disable-model-invocation: true` flag
- Test with exact phrases from description

**Skill not in autocomplete:**
- Verify SKILL.md in correct location
- Check frontmatter YAML is valid
- Ensure no `user-invocable: false` flag

**Shell commands fail:**
- Verify dynamic injection syntax (backticks with exclamation prefix)
- Add error handling with `|| echo "fallback"`
- Check commands available in user's environment

## Related Tools

- **Hooks**: For automatic actions on tool events
- **Subagents**: For parallel execution and isolation
- **Plugins**: For bundling multiple related skills
- **MCP Servers**: For external tool integration

## Supporting Files

For detailed skill patterns and examples:
- Skill structure examples: [examples/skill-structures.md](examples/skill-structures.md)
- Template library: [templates/](templates/)
- Reference patterns: [references/skill-patterns.md](references/skill-patterns.md)
