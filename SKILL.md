---
name: project-context
description: >
  Organize project workspaces by context with channel-aware working directories.
  Prevents context window flooding by partitioning work into separate, manageable
  folders. Each channel can set its own working directory (like cd), so you
  can work deeply on one project without dragging other contexts in. Works with
  any OpenClaw-supported chat platform (Discord, Slack, etc.).
---

# project-context

**Status:** Working directory edition — channel-aware project management

## What It Does

Organizes project workspaces by context in a shared repository at `~/.openclaw/project-context/`. 

Each channel has its own **working directory**, so you can:
- Set a context once (e.g., `work/active-project`)
- Create multiple projects under that context without repeating the path
- Switch contexts when you move to a different channel or area

## When to Use

- **Starting new work:** Create a project for any deliverable, task, or analysis
- **Organizing by domain:** Keep work/research/personal separate so they don't mix
- **Channel-based workflows:** Set context once per channel, work without context bleed

## How to Use

Invoke this skill by describing what you want to do in natural language. Examples:

**Set your project context:**
- "Set my project context to work/active-project"
- "I'm working on research/long-term stuff"
- "Switch context to documentation"

**Create a project:**
- "Create a new project called feature-analysis for researching and documenting the new feature"
- "Create a project in my current context called bug-investigation"

**View your context:**
- "What's my current project context?"
- "Where am I right now?"

**List projects:**
- "Show me all projects in the repository"
- "What projects do I have?"

**Get project details:**
- "Tell me about work/active-project/research"
- "What's in the personal/taxes/2025 project?"

**Back up your projects:**
- "Push my projects to GitHub"
- "Back up my project changes"

Commits any uncommitted changes and pushes them to GitHub for backup.

## Daily Automatic Backups

Set up a cron job for daily backups:

```bash
crontab -e
# Add: 0 2 * * * cd ~/.openclaw/project-context && git push origin main
```

This pushes to GitHub automatically every day at 2 AM. Or ask the agent to "Back up my projects" for an on-demand push.

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

When working on work-related projects:
```
User: Set my project context to work/active-sprint
Agent: ✓ Working directory: work/active-sprint

User: Create a new project called feature-analysis for research and documentation
Agent: ✓ Project created: work/active-sprint/feature-analysis

User: (uploads documents, creates drafts, iterates)

User: What's my current project context?
Agent: Working directory: work/active-sprint
```

When switching to research:
```
User: Switch context to research/long-term
Agent: ✓ Working directory: research/long-term

User: Create a project called exploration for technical exploration
Agent: ✓ Project created: research/long-term/exploration

User: (works on research)
```

Each channel remembers its context independently, across platforms.

## How It Works

- **Channel-based state:** Each channel (Discord, Slack, etc.) remembers its working directory independently
- **Monorepo commits:** Every project creation is a git commit to the shared repository
- **Optional paths:** Specify a full path to create outside your working directory without changing context
- **Gitignored state:** Channel contexts stored in `.state/channel-contexts.json` (not committed)
- **Platform-agnostic:** Works with any OpenClaw-supported chat platform

## What You Need

- OpenClaw agent with file access
- Git (usually pre-installed)

## Implementation

**Core logic:**
- Bash script that:
  - Manages per-channel working directories in `.state/channel-contexts.json`
  - Creates project folders with docs/drafts/final structure
  - Commits new projects to the repository
  
**Data location:** `~/.openclaw/project-context/` (shared repository)

**Dependencies:** Standard tools (bash, git, jq)

## Future Iterations

- Auto-commit with better messages
- Extract text from PDFs/Word (context-optimizer feature)
- Project status/metadata tracking
- Archive/cleanup old projects
- Optional: push repository to GitHub for backup
- Integration with completion skill for project tasks
