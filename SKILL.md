# project-context

**Status:** MVP (minimal viable product)

## What It Does

Creates a focused project workspace for focused work on discrete deliverables. Each project gets:
- A dedicated folder with git initialization
- GitHub repo (optional, can be created manually)
- README with project context/description
- Clean starting point for files, drafts, iterations, and final outputs

## When to Use

- **Starting new work:** Tax return, legal filing, report, case analysis, research project
- **Organizing around outcomes:** "I need to deliver X by Y date"
- **Scoping context:** All files for this project in one place, git-tracked

## Usage

### Start a New Project
```
/project-context [project-name] [description]
```

**Example:**
```
/project-context taxes-2026 "Prepare 2026 tax return filing. Need to collect W-2s, 1099s, charitable deductions."
```

**What happens:**
1. Creates `~/.openclaw/projects/[project-name]/`
2. Initializes git repo
3. Creates README.md with project context
4. Makes initial commit
5. Attempts to create private GitHub repo
6. If GitHub fails, gives you a one-click link to create it manually

### List Projects
```
/project-context --list
```

### Switch Context
When you mention a project by name in a channel, I treat that project folder as the working directory. Upload files there, reference files from there, save outputs there.

## What You Need

- OpenClaw agent with file access
- GitHub account (optional; local git works fine without it)
- Discord channel per project (recommended for clarity)

## Implementation

**Core logic:**
- Bash script that:
  - Creates project folder hierarchy
  - Runs `git init`
  - Generates templated README
  - Commits initial state
  - Attempts `gh repo create` (GitHub CLI)
  - Falls back to manual creation link

**No dependencies:** Uses standard tools (git, gh CLI)

**Data location:** `~/.openclaw/projects/[project-name]/`

## Known Limitations

- GitHub repo creation requires `gh` CLI authentication (should already be set up)
- If GitHub fails, you create the repo manually (takes 30 seconds)
- No advanced project management (yet) — just folder + git

## Future Iterations

- List files in project
- Auto-commit with context-aware messages
- Extract text from PDFs, parse Excel/CSV/Word (requires additional skills)
- Project status/metadata tracking
- Archive/cleanup old projects
