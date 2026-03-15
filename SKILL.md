---
name: project-context
description: >
  Organize project workspaces by context with channel-aware working directories.
  Prevents context window flooding by partitioning work into separate, manageable
  folders. Each Discord channel can set its own working directory (like cd), so you
  can work deeply on one project without dragging other contexts in.
---

# project-context

**Status:** Working directory edition — channel-aware project management

## What It Does

Organizes project workspaces by context in a shared repository at `~/.openclaw/project-context/`. 

Each Discord channel has its own **working directory**, so you can:
- Set a context once (e.g., `work/active-project`)
- Create multiple projects under that context without repeating the path
- Switch contexts when you move to a different area (channel = context)

## When to Use

- **Starting new work:** Create a project for any deliverable, task, or analysis
- **Organizing by domain:** Keep work/research/personal separate so they don't mix
- **Channel-based workflows:** Set context once per channel, work without context bleed

## Usage

### Set Your Working Directory
```
/project-context cd work/active-project
```

Sets the working directory for the current Discord channel. You only do this once per channel.

### Show Current Working Directory
```
/project-context pwd
```

Shows where you are in the project structure for this channel.

### Create a Project
```
/project-context create research "Document findings and research notes"
```

Creates a project in your current working directory. If no working directory is set, you'll get an error asking you to set one first.

**Or specify the path explicitly:**
```
/project-context create documentation/guide "User guide for feature X"
```

### List All Projects
```
/project-context list
```

Shows all projects in the repository and file counts.

### View Project Details
```
/project-context info work/active-project/research
```

Shows project path, recent git history, and files.

## Directory Structure

The repository is organized by context folders:

```
~/.openclaw/project-context/
├── work/                      (Work-related projects)
├── research/                  (Research projects)
├── documentation/             (Documentation projects)
├── personal/                  (Personal projects)
├── archive/                   (Completed/archived work)
└── .state/                    (Channel context state, gitignored)
    └── channel-contexts.json
```

## Workflow Example

**Channel: #work**
```
User: /project-context cd work/active-sprint
Bot: ✓ Working directory: work/active-sprint

User: /project-context create feature-analysis "Research and document feature"
Bot: ✓ Project created: work/active-sprint/feature-analysis

User: (uploads documents, creates drafts, iterates)

User: /project-context pwd
Bot: Working directory: work/active-sprint
```

**Channel: #research**
```
User: /project-context cd research/long-term
Bot: ✓ Working directory: research/long-term

User: /project-context create exploration "Technical exploration"
Bot: ✓ Project created: research/long-term/exploration

User: (works on research)
```

## How It Works

- **Channel-based state:** Each Discord channel remembers its working directory
- **Monorepo commits:** Every project creation is a git commit to the shared monorepo
- **Optional paths:** Use explicit paths if you need to create outside your working directory
- **Gitignored state:** Channel contexts stored in `.state/channel-contexts.json` (not committed)

## What You Need

- OpenClaw agent with file access
- Git (usually pre-installed)

## Implementation

**Core logic:**
- Bash script that:
  - Manages per-channel working directories in `.state/channel-contexts.json`
  - Creates project folders with docs/drafts/final structure
  - Commits new projects to monorepo
  
**Data location:** `~/.openclaw/project-context/` (monorepo)

**Dependencies:** Standard tools (bash, git, jq)

## Future Iterations

- Auto-commit with better messages
- Extract text from PDFs/Word
- Project status/metadata tracking
- Archive/cleanup old projects
- Optional: push monorepo to GitHub for backup
- Integration with completion skill for project tasks
