# project-context Skill

**Why you need this:** Large projects generate massive context. If you're juggling work across multiple domains, loading everything together floods your context window and dilutes focus. This skill organizes your work into separate contexts so you can work deeply on one thing without dragging everything else in.

**How it works:** Projects live in organized folders on disk. Beyond traditional file system boundaries, we've added channel awareness — each channel (Discord, Slack, etc.) can have its own project context (like setting a working directory). Switch channels, switch contexts. No mental overhead, no accidental context bleed.

## Using This Skill

Invoke this skill by describing what you want to do in natural language. The agent will understand your intent and execute the appropriate action.

### Set Your Project Context

Say something like:
- "Set my project context to work/active-project"
- "I'm working on research/long-term stuff"
- "Switch context to documentation"

This sets the working directory for your current channel.

### Create a Project

Say something like:
- "Create a new project called feature-analysis for researching and documenting the new feature"
- "Create a project in my current context called bug-investigation"

Projects are created in your current working directory by default.

### View Your Context

Say something like:
- "What's my current project context?"
- "Where am I right now?"

The agent will show your working directory for this channel.

### List Projects

Say something like:
- "Show me all projects in the monorepo"
- "What projects do I have?"
- "List everything"

### Get Project Details

Say something like:
- "Tell me about work/active-project/research"
- "What's in the personal/taxes/2025 project?"

The agent will show you the path, recent git history, and files.

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

When working on work-related projects:

```
User: Set my project context to work/current-sprint
Agent: ✓ Working directory: work/current-sprint

User: Create a new project called feature-analysis for researching and documenting the new feature
Agent: ✓ Project created: work/current-sprint/feature-analysis

User: (uploads documents, creates drafts, iterates)

User: What's my current project context?
Agent: Working directory: work/current-sprint
```

When switching to a different area:

```
User: Switch context to research/long-term
Agent: ✓ Working directory: research/long-term

User: Create a project called exploration for technical exploration
Agent: ✓ Project created: research/long-term/exploration
```

Each channel remembers its working directory independently, across platforms.

## Technical Details

**Storage:** `~/.openclaw/project-context/` (git monorepo)

**State:** `~/.openclaw/project-context/.state/channel-contexts.json` (gitignored, per-channel working directories)

**Requirements:**
- Git (required for commits and history)
- jq (required for JSON state management)
- Bash

**Git commits** are authored by the agent running the skill. Configure git user info on the host if you want to customize commit authorship.

## Platform Support

This skill works with any OpenClaw-supported chat platform (Discord, Slack, etc.). Each platform's channels are treated identically — they each get their own working directory stored by channel ID. Switch between Discord and Slack, and each maintains its own context.

## How It Works

1. **Channel-aware state:** Each channel stores its working directory in `.state/channel-contexts.json` (keyed by channel ID)
2. **Default behavior:** Projects are created in the current working directory if set
3. **Override:** Specify a full path to create anywhere without changing channel context
4. **Commits:** Every new project is committed to monorepo with `git add && git commit`
5. **Organization:** Projects grouped by context folder, so you can see all related work together
6. **Platform-agnostic:** The skill doesn't care which platform — it just uses the channel ID it receives

## Development

Skill location: `/workspace/skills/project-context/`

Main script: `project-context.sh`

To test locally:
```bash
# Set channel ID and test
export OPENCLAW_CHANNEL_ID="test-channel"
./project-context.sh cd work/active-project
./project-context.sh create test-project "Test project"
./project-context.sh pwd
./project-context.sh list
./project-context.sh info work/active-project/test-project
```

Clean up:
```bash
cd ~/.openclaw/project-context
git log --oneline | head  # See what you created
git reset --hard HEAD~N   # Undo N commits if needed
```

## Future Enhancements

- Auto-commit with smarter messages
- Extract text from PDFs/Word/Excel (context-optimizer feature)
- Project status tracking
- Archive/cleanup workflows
- Push monorepo to GitHub for backup
- Integration with completion skill for project-based tasks
