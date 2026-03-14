# project-context Skill

Create and manage focused project workspaces for discrete deliverables.

## Quick Start

```bash
project-context create taxes-2026 "Prepare 2026 tax return. Upload W-2s, 1099s, deductions."
```

This creates:
- Folder: `~/.openclaw/projects/taxes-2026/`
- Git repo initialized
- README with project context
- Subdirectories: `docs/`, `drafts/`, `final/`
- Initial commit
- Optional: GitHub private repo

## Commands

### Create a Project
```bash
project-context create <name> "<description>"
```

Creates a new project workspace with git initialization and (optionally) a GitHub repo.

**Example:**
```bash
project-context create divorce-settlement "Work through divorce settlement. Legal docs, spreadsheets, negotiation notes."
```

### List Projects
```bash
project-context list
```

Shows all projects and commit counts.

### Project Info
```bash
project-context info <name>
```

Shows project path, git history, and file listing.

## Workflow

Each project folder has this structure:

```
~/.openclaw/projects/[project-name]/
├── README.md          # Project context and notes
├── docs/              # Raw input files (PDFs, uploads, etc.)
├── drafts/            # Working documents and iterations
├── final/             # Completed deliverables
└── .git/              # Full git history
```

**Typical workflow:**
1. Create project with context
2. Upload raw files to `docs/`
3. Reference them, create drafts in `drafts/`
4. Iterate on documents
5. Move finalized work to `final/`
6. All changes are git-tracked

## GitHub Integration

When you create a project, the skill attempts to create a private GitHub repo using the `gh` CLI.

**If successful:** You get a linked GitHub repo, auto-pushed
**If it fails:** You get a one-click link to create the repo manually, then I can push to it

GitHub is optional but recommended for backup.

## Technical Details

**Storage:** `~/.openclaw/projects/[name]/`

**Git Config:**
- User: `ananda-bot`
- Email: `ananda@growthscience.co`

**Requirements:**
- Git (required)
- GitHub CLI (`gh`) — optional, falls back to manual
- Bash

**No external dependencies:** Uses standard tools

## Implementation Notes

- Minimal by design — it's a wrapper around git + bash
- Each project is independent (own git repo, own history)
- All projects share the same GitHub user (`geoffscott`)
- Designed to iterate and grow based on usage

## Future Enhancements

- Auto-commit with context-aware messages
- List files in a project
- Extract text from PDFs/Excel/Word (requires additional skills)
- Project status/metadata
- Archive/cleanup
- Sync between local and GitHub
- Integration with completion skill for project-based tasks

## Development

Skill location: `/workspace/skills/project-context/`

Main script: `project-context.sh`

To test locally:
```bash
./project-context.sh create test-project "Test project"
./project-context.sh list
./project-context.sh info test-project
```

Clean up test projects:
```bash
rm -rf ~/.openclaw/projects/test-project*
```
