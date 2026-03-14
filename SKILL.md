---
name: project-context
description: >
  Manage project workspaces in a shared monorepo organized by organizational context
  (oneeleven, saranam, personal, simny, etc.) with channel-aware working directories.
  Use when starting new projects, organizing work by context, or switching between
  project areas in different Discord channels.
---

---
name: project-context
description: >
  Manage project workspaces in a shared monorepo organized by organizational context
  (oneeleven, saranam, personal, simny, etc.) with channel-aware working directories.
  Use when starting new projects, organizing work by context, or switching between
  project areas in different Discord channels.
---

# project-context

**Status:** Working directory edition — channel-aware project management

## What It Does

Manages project workspaces organized by organizational context (oneeleven, saranam, personal, etc.) in a unified monorepo at `~/.openclaw/project-context/`. 

Each Discord channel has its own **working directory**, so you can:
- Set a context once (e.g., `personal/taxes/2025`)
- Create multiple projects under that context without repeating the path
- Switch contexts when you move to a different project area

## When to Use

- **Starting new work:** Project, task, document, analysis within an organizational area
- **Organizing by context:** All work for a context in one place
- **Channel-based workflows:** Work on taxes in #personal-projects, governance in #saranam, etc.

## Usage

### Set Your Working Directory
```
/project-context cd personal/taxes/2025
```

Sets the working directory for the current Discord channel. You only do this once per channel.

### Show Current Working Directory
```
/project-context pwd
```

Shows where you are in the project structure for this channel.

### Create a Project
```
/project-context create taxes-2026 "Prepare 2026 tax return"
```

Creates a project in your current working directory. If no working directory is set, you'll get an error asking you to set one first.

**Or specify the path explicitly:**
```
/project-context create saranam/governance "Board governance framework"
```

### List All Projects
```
/project-context list
```

Shows all projects in the monorepo and file counts.

### View Project Details
```
/project-context info personal/taxes/2025/taxes-2026
```

Shows project path, recent git history, and files.

## Directory Structure

The monorepo is organized by organizational context:

```
~/.openclaw/project-context/
├── oneeleven/                 (OneEleven projects)
├── saranam/                   (Saranam board projects)
├── personal/                  (Personal projects)
│   ├── taxes/
│   │   └── 2025/
│   │       ├── growthscience/ (Growth Science taxes)
│   │       └── personal/      (Personal taxes)
├── simny/                     (SIMNY projects)
│   └── taxes/
│       └── 2025/
├── eyethena/                  (Eyethena projects)
├── growthscience/             (Growth Science business projects)
├── cfokit/                    (CFOKit projects)
├── kindness-flywheel/         (Kindness Flywheel content)
└── .state/                    (Channel context state, gitignored)
    └── channel-contexts.json
```

## Workflow Example

**Channel: #personal-projects**
```
User: /project-context cd personal/taxes/2025
Bot: ✓ Working directory: personal/taxes/2025

User: /project-context create taxes-2026 "Annual 2026 tax filing"
Bot: ✓ Project created: personal/taxes/2025/taxes-2026

User: (uploads documents, creates drafts, iterates)

User: /project-context pwd
Bot: Working directory: personal/taxes/2025
```

**Channel: #saranam**
```
User: /project-context cd saranam
Bot: ✓ Working directory: saranam

User: /project-context create governance-framework "Board governance docs"
Bot: ✓ Project created: saranam/governance-framework

User: (works on governance)
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
