# project-context Skill

Manage project workspaces in a shared monorepo, with channel-aware working directories.

## Quick Start

**Step 1: Set your working directory** (once per channel)
```bash
project-context cd personal/taxes/2025
```

**Step 2: Create projects** (stays in your working directory)
```bash
project-context create taxes-2026 "Prepare 2026 tax return. Upload W-2s, 1099s, deductions."
```

This creates:
- Folder: `~/.openclaw/project-context/personal/taxes/2025/taxes-2026/`
- README with context
- Subdirectories: `docs/`, `drafts/`, `final/`
- Automatic commit to monorepo
- Stays in `personal/taxes/2025/` context for next project

## Commands

### Set Working Directory
```bash
project-context cd <path>
```

Sets the working directory for the current Discord channel. Example:
```bash
project-context cd personal/taxes/2025
project-context cd saranam
project-context cd oneeleven/products
```

### Show Working Directory
```bash
project-context pwd
```

Shows where you are for the current channel.

### Create a Project
```bash
project-context create "<description>"
```

Creates a project in the current working directory. Example:
```bash
project-context create "2026 tax return filing"
```

**Or create elsewhere** (without changing context):
```bash
project-context create saranam/governance "Board governance framework"
```

### List All Projects
```bash
project-context list
```

Shows all projects in the monorepo.

### Project Info
```bash
project-context info <path>
```

Shows path, git history, and files. Example:
```bash
project-context info personal/taxes/2025/taxes-2026
```

## Directory Structure

```
~/.openclaw/project-context/                      # Monorepo root
├── oneeleven/                                    # OneEleven projects
├── saranam/                                      # Saranam board projects
├── personal/                                     # Personal projects
│   ├── taxes/2025/
│   │   ├── growthscience/      (GS taxes)
│   │   └── personal/           (Personal taxes)
│   └── [other personal projects]/
├── simny/                                        # SIMNY projects
│   └── taxes/2025/
├── eyethena/                                     # Eyethena projects
├── growthscience/                                # Growth Science projects
├── cfokit/                                       # CFOKit projects
├── kindness-flywheel/                            # Kindness Flywheel projects
└── .state/                                       # Working directory state (gitignored)
    └── channel-contexts.json
```

Each project folder has:
```
[project-name]/
├── README.md                  # Project description
├── docs/                      # Raw input files
├── drafts/                    # Working documents
└── final/                     # Completed deliverables
```

## Workflow Example

You're in **#personal-projects** channel:

```bash
# Set context once
project-context cd personal/taxes/2025

# Create projects under that context
project-context create taxes-2026 "2026 tax return"
# Creates: personal/taxes/2025/taxes-2026/

project-context create deductions-summary "Summary of charitable deductions"
# Creates: personal/taxes/2025/deductions-summary/

# Check where you are
project-context pwd
# → personal/taxes/2025

# Switch contexts when moving to a new area
project-context cd personal/legal
project-context create divorce-settlement "Divorce settlement documents"
# Creates: personal/legal/divorce-settlement/
```

In a **different channel** (#saranam):

```bash
project-context cd saranam
project-context create governance "Board governance docs"
# Creates: saranam/governance/
```

## Technical Details

**Storage:** `~/.openclaw/project-context/` (git monorepo)

**State:** `~/.openclaw/project-context/.state/channel-contexts.json` (gitignored)

**Git Config:**
- User: `ananda-bot`
- Email: `ananda@growthscience.co`

**Requirements:**
- Git (required)
- jq (required for JSON state management)
- Bash

## How It Works

1. **Channel state:** Each Discord channel stores its working directory in `.state/channel-contexts.json`
2. **Default behavior:** `create` uses current working directory if set
3. **Override:** Provide explicit path to create anywhere
4. **Commits:** Every new project is committed to monorepo with `git add && git commit`
5. **Organization:** Projects grouped by context folder, so you can see all related work together

## Development

Skill location: `/workspace/skills/project-context/`

Main script: `project-context.sh`

To test locally:
```bash
# Set channel ID and test
export OPENCLAW_CHANNEL_ID="test-channel"
./project-context.sh cd personal/taxes/2025
./project-context.sh create test-project "Test project"
./project-context.sh pwd
./project-context.sh list
./project-context.sh info personal/taxes/2025/test-project
```

Clean up:
```bash
cd ~/.openclaw/project-context
git log --oneline | head  # See what you created
git reset --hard HEAD~N   # Undo N commits if needed
```

## Future Enhancements

- Auto-commit with smarter messages
- Extract text from PDFs/Word/Excel
- Project status tracking
- Archive/cleanup workflows
- Push monorepo to GitHub for backup
- Integration with completion skill
