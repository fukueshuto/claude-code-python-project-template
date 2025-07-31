# Guidelines
This document defines the project's rules, objectives, and progress management methods.

## Top-Level Rules
- To maximize efficiency, **if you need to execute multiple independent processes, invoke those tools concurrently, not sequentially**.
- **You must think exclusively in English**. However, you are required to **respond in Japanese**.
- **After using Write or Edit tools, ALWAYS verify the actual file contents using the Read tool**.
- Please respond critically and without pandering to my opinions.

## Programming Rules (Language-Agnostic)
- Avoid hard-coding values unless absolutely necessary
- Follow the principle of DRY (Don't Repeat Yourself)
- Write self-documenting code with clear variable and function names
- Implement proper error handling and logging
- Consider edge cases and boundary conditions
- Write tests for critical functionality
- Keep functions small and focused on a single responsibility
- Use consistent coding style throughout the project

## Language-Specific Rules
If the project uses a specific language, follow these additional rules:

### TypeScript/JavaScript
- Do not use `any` or `unknown` types in TypeScript
- Prefer functional programming patterns over classes when possible
- Use `const` by default, `let` only when reassignment is needed

### Python
- Follow PEP 8 style guide
- Use type hints for function signatures
- Prefer list comprehensions for simple transformations
- Use context managers (`with` statements) for resource management

### Other Languages
- Follow the official style guide and best practices for the detected language
- Use the language's standard tooling for formatting and linting

## Development Style - Hybrid Specification-Driven Development

### Overview
This approach combines manual specification creation with autonomous task execution using Sub agents.

### 2-Phase Workflow

#### Phase 1: Specification Creation (Manual with Commands)
1. **Requirements** (`/requirements`)
   - Analyze user requests
   - Document in `.tmp/requirements.md`
   - Get user approval

2. **Design** (`/design`)
   - Create technical design
   - Document in `.tmp/design.md`
   - Get user approval

3. **Task Breakdown** (`/tasks`)
   - Break down into implementable units
   - Document in `.tmp/tasks.md`
   - Prepare for autonomous execution

#### Phase 2: Autonomous Execution (Sub agents)
1. **Task Decomposition** (task-decomposer agent)
   - Convert plans to executable task files
   - Create in `docs/plans/tasks/`
   - Include overview and context

2. **Task Execution** (task-executor agent)
   - Execute tasks autonomously
   - Update progress in real-time
   - Handle context management

3. **Quality Assurance** (quality-checker agent)
   - Run after each task
   - Use language-appropriate tools
   - Fix issues before commit

### Workflow Commands
- `/spec` - Start complete workflow
- `/requirements` - Stage 1 only
- `/design` - Stage 2 only
- `/tasks` - Stage 3 only
- `/implement` - Start autonomous execution

### Sub Agent Usage
- `task-decomposer`: Break down complex plans
- `task-executor`: Execute individual tasks
- `quality-checker`: Ensure code quality (universal or language-specific)
- `spec-manager`: Manage specifications

## Quality Assurance Strategy

### Automatic Language Detection
The quality-checker will automatically detect the project language and use appropriate tools:
- **Python**: `quality-checker-python` (ruff, pytest, mypy)
- **TypeScript/JavaScript**: `quality-checker-typescript` (eslint, prettier, jest)
- **Other/Mixed**: `quality-checker-universal` (language-agnostic tools)

### Quality Standards
- Code coverage: Aim for 80% minimum
- Complexity: Keep cyclomatic complexity below 10
- Documentation: All public APIs must be documented
- Testing: Write tests before or alongside implementation

## Context Management Strategy
- Use Sub agents to prevent context overflow
- Each agent has focused responsibilities
- Maintain project coherence through shared documents
- Regular checkpoints to ensure alignment with specifications

## Project-Specific Configuration
Projects may override these defaults by providing:
- `.claude/project.md` - Project-specific rules and guidelines
- `pyproject.toml`, `package.json`, etc. - Language-specific configuration
- `.claude/agents/` - Custom Sub agents for the project

## Important Notes
- Each stage depends on the deliverables of the previous stage
- Please obtain user confirmation before proceeding to the next stage
- Always use this workflow for complex tasks or new feature development
- Simple fixes or clear bug fixes can be implemented directly
- Adapt the process based on project size and complexity