# project-context Skill

**Why you need this:** Large projects generate massive context. If you're juggling work across multiple domains, loading everything together floods your context window and dilutes focus. This skill organizes your work into separate contexts so you can work deeply on one thing without dragging everything else in.

**How it works:** Projects live in organized folders on disk. Beyond traditional file system boundaries, we've added channel awareness — each Discord channel can have its own project context (like setting a working directory). Switch channels, switch contexts. No mental overhead, no accidental context bleed.

## Quick Start

**Step 1: Set your working directory** (once per channel)
```bash
project-context cd work/active-project
```

**Step 2: Create projects** (stays in your working directory)
```bash
project-context create research "Document findings and analysis"
```

This creates:
- Folder: `~/.openclaw/project-context/work/active-project/research/`
- README with context
- Subdirectories: `docs/`, `drafts/`, `final/`
- Automatic commit to shared project repository
- Stays in `work/active-project/` context for next project

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
~/.openclaw/project-context/                      # Repository root
├── work/                                         # Work-related projects
│   ├── project-1/
│   ├── project-2/
│   └── [other projects]/
├── research/                                     # Research projects
├── documentation/                                # Docs projects
├── personal/                                     # Personal projects
├── archive/                                      # Completed/archived work
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

You're in **#work** channel:

```bash
# Set context once
project-context cd work/current-sprint

# Create projects under that context
project-context create feature-analysis "Research and document new feature"
# Creates: work/current-sprint/feature-analysis/

project-context create bug-investigation "Investigate reported bug"
# Creates: work/current-sprint/bug-investigation/

# Check where you are
project-context pwd
# → work/current-sprint

# Switch contexts when moving to a new area
project-context cd research/long-term
project-context create exploration "Technical exploration"
# Creates: research/long-term/exploration/
```

In a **different channel** (#documentation):

```bash
project-context cd documentation
project-context create api-guide "API reference guide"
# Creates: documentation/api-guide/
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
