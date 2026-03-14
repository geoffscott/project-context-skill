# project-context Skill

Create and manage focused project workspaces for discrete deliverables in a unified monorepo.

## Quick Start

```bash
project-context create taxes-2026 "Prepare 2026 tax return. Upload W-2s, 1099s, deductions."
```

This creates:
- Folder: `~/.openclaw/project-context/taxes-2026/`
- README with project context
- Subdirectories: `docs/`, `drafts/`, `final/`
- Automatic commit to the projects monorepo

## Commands

### Create a Project
```bash
project-context create <name> "<description>"
```

Creates a new project workspace and commits it to the monorepo.

**Example:**
```bash
project-context create divorce-settlement "Work through divorce settlement. Legal docs, spreadsheets, negotiation notes."
```

### List All Projects
```bash
project-context list
```

Shows all projects in the monorepo and their file counts.

### Project Info
```bash
project-context info <name>
```

Shows project path, recent git history, and file listing.

## Monorepo Structure

```
~/.openclaw/project-context/       # Single monorepo for all projects
├── [project-name-1]/
│   ├── README.md                  # Project description
│   ├── docs/                      # Raw input files (PDFs, uploads, etc.)
│   ├── drafts/                    # Working documents and iterations
│   └── final/                     # Completed deliverables
├── [project-name-2]/
│   └── [similar structure]
└── .git/                          # Unified monorepo history
```

**Typical workflow:**
1. Create project with context
2. Upload raw files to `docs/`
3. Reference them, create drafts in `drafts/`
4. Iterate on documents
5. Move finalized work to `final/`
6. All changes committed to monorepo

## Why Monorepo?

- **Single clone** — all projects in one place
- **Unified history** — see all work together
- **No per-project overhead** — no separate GitHub repo per project
- **Easy search** — grep across all projects at once
- **Simpler management** — one git repo to push/pull

## Technical Details

**Storage:** `~/.openclaw/project-context/` (monorepo root)

**Git Config:**
- User: `ananda-bot`
- Email: `ananda@growthscience.co`

**Requirements:**
- Git (required)
- Bash

**No external dependencies:** Uses standard tools

## Implementation Notes

- Minimal by design — bash wrapper around git
- All projects share one git monorepo
- Folder structure keeps projects logically separate
- Designed to iterate and grow based on usage

## Future Enhancements

- Auto-commit with better commit messages
- List files in a project
- Extract text from PDFs, parse Excel/CSV/Word
- Project status/metadata tracking
- Archive/cleanup old projects
- Optional: push monorepo to GitHub for backup
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
rm -rf ~/.openclaw/project-context/test-project/
```

(Note: This removes from monorepo; you'd need to commit the deletion to git)
