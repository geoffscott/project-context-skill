# project-context

**Status:** MVP (monorepo edition)

## What It Does

Creates focused project workspaces for discrete deliverables, all tracked in a single git monorepo at `~/.openclaw/projects/`. Each new project gets:
- A dedicated folder with README and project description
- Subdirectories for docs, drafts, and final outputs
- Automatic commit to the projects monorepo

## When to Use

- **Starting new work:** Tax return, legal filing, report, case analysis, research project, document collaboration
- **Organizing around outcomes:** "I need to deliver X by Y date"
- **Scoping context:** All files for this project in one place, git-tracked
- **Viewing all projects together:** Everything in one monorepo, easy to search and reference across projects

## Usage

### Start a New Project
```
project-context create [project-name] "[description]"
```

**Example:**
```
project-context create divorce-settlement "Work through divorce settlement. Legal docs, spreadsheets, negotiation notes."
```

**What happens:**
1. Creates `~/.openclaw/projects/[project-name]/`
2. Creates README.md with project context
3. Creates subdirectories: `docs/`, `drafts/`, `final/`
4. Commits the new project to the monorepo

### List All Projects
```
project-context list
```

### View Project Details
```
project-context info [project-name]
```

Shows project path, recent git history, and files.

### Day-to-Day Workflow

When you mention a project by name:
1. I treat that project folder as the working directory
2. Upload files to `docs/`, `drafts/`, or `final/`
3. I commit changes to the monorepo
4. All projects are visible together in git history

## Structure

```
~/.openclaw/projects/          # Monorepo root
├── [project-name-1]/
│   ├── README.md              # Project description
│   ├── docs/                  # Raw input files
│   ├── drafts/                # Working documents
│   └── final/                 # Completed deliverables
├── [project-name-2]/
└── .git/                       # Unified monorepo history
```

## What You Need

- OpenClaw agent with file access
- Git (usually already available)
- No GitHub account required (local git works fine)

## Implementation

**Core logic:**
- Bash script that:
  - Creates project folder hierarchy
  - Generates templated README
  - Commits to the parent monorepo
  
**Data location:** `~/.openclaw/projects/` (monorepo)

**Dependencies:** Standard tools (bash, git)

## Benefits of Monorepo

- **Single clone** → all projects available
- **Unified history** → easy to see all work across projects
- **No per-project overhead** → no GitHub repo creation per project
- **Easy search** → grep across all projects at once
- **Simple backup** → one git repo to push/pull

## Known Limitations

- GitHub integration not automatic (can push monorepo manually if needed)
- Projects share a single git history (but folder structure keeps them logically separate)

## Future Iterations

- Auto-commit with context-aware messages
- Extract text from PDFs, parse Excel/CSV/Word
- Project status/metadata tracking
- Archive/cleanup old projects
- Optional: push monorepo to GitHub for backup
