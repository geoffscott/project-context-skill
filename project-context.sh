#!/bin/bash

###############################################################################
# project-context.sh
# Creates and manages project workspaces for focused work
###############################################################################

set -e

PROJECTS_DIR="${HOME}/.openclaw/projects"
GITHUB_USER="geoffscott"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

###############################################################################
# Usage
###############################################################################

show_usage() {
  cat <<EOF
Usage: project-context [command] [options]

Commands:
  create <name> "<description>"   Create a new project
  list                             List all projects
  info <name>                      Show project info and status
  help                             Show this help

Examples:
  project-context create taxes-2026 "Prepare 2026 tax return. Upload W-2s, 1099s, deductions."
  project-context list
  project-context info taxes-2026

EOF
}

###############################################################################
# Create Project
###############################################################################

create_project() {
  local project_name="$1"
  local project_description="$2"

  if [[ -z "$project_name" ]]; then
    echo -e "${RED}Error: Project name required${NC}"
    show_usage
    exit 1
  fi

  if [[ -z "$project_description" ]]; then
    echo -e "${RED}Error: Project description required${NC}"
    show_usage
    exit 1
  fi

  # Validate project name (alphanumeric, hyphens, underscores)
  if [[ ! "$project_name" =~ ^[a-z0-9_-]+$ ]]; then
    echo -e "${RED}Error: Project name must be lowercase alphanumeric, hyphens, or underscores${NC}"
    exit 1
  fi

  local project_path="${PROJECTS_DIR}/${project_name}"

  # Check if project already exists
  if [[ -d "$project_path" ]]; then
    echo -e "${YELLOW}Project already exists at: ${project_path}${NC}"
    exit 1
  fi

  # Create directories
  echo -e "${BLUE}Creating project: ${project_name}${NC}"
  mkdir -p "$project_path"
  cd "$project_path"

  # Initialize git
  echo -e "${BLUE}Initializing git repository...${NC}"
  git init
  git config user.name "ananda-bot"
  git config user.email "ananda@growthscience.co"

  # Create README with project context
  cat > README.md <<EOF
# ${project_name}

## Project Context
${project_description}

## Structure
- \`/docs/\` — Raw input files (PDFs, uploads, etc.)
- \`/drafts/\` — Working documents and iterations
- \`/final/\` — Completed deliverables
- \`README.md\` — This file

## Workflow
1. Upload raw files to \`/docs/\`
2. Create drafts and iterate in \`/drafts/\`
3. Move finalized work to \`/final/\`
4. All changes are git-tracked

---

*Created: $(date -u +%Y-%m-%dT%H:%M:%SZ)*
*Project: ${project_name}*
EOF

  # Create initial subdirectories
  mkdir -p docs drafts final

  # Initial commit
  echo -e "${BLUE}Creating initial commit...${NC}"
  git add .
  git commit -m "chore: initialize project ${project_name}"

  echo -e "${GREEN}✓ Project created: ${project_path}${NC}"
  echo ""

  # Try to create GitHub repo
  create_github_repo "$project_name"
}

###############################################################################
# Create GitHub Repo
###############################################################################

create_github_repo() {
  local project_name="$1"
  local repo_name="project-${project_name}"

  echo -e "${BLUE}Attempting to create GitHub repo...${NC}"

  # Check if gh CLI is available
  if ! command -v gh &> /dev/null; then
    echo -e "${YELLOW}⚠ GitHub CLI (gh) not available. Skipping GitHub setup.${NC}"
    return
  fi

  # Attempt to create the repo
  if gh repo create "${GITHUB_USER}/${repo_name}" --private --source=. --remote=origin --push 2>&1; then
    echo -e "${GREEN}✓ GitHub repo created and pushed: https://github.com/${GITHUB_USER}/${repo_name}${NC}"
  else
    echo -e "${YELLOW}⚠ Could not auto-create GitHub repo (may need permissions or it might already exist)${NC}"
    echo ""
    echo -e "${YELLOW}Manual setup:${NC}"
    echo "1. Create a new private repo here:"
    echo "   https://github.com/new?name=${repo_name}&visibility=private&owner=${GITHUB_USER}"
    echo ""
    echo "2. Once created, I can push to it with:"
    echo "   git remote add origin https://github.com/${GITHUB_USER}/${repo_name}.git"
    echo "   git branch -M main"
    echo "   git push -u origin main"
    return 1
  fi
}

###############################################################################
# List Projects
###############################################################################

list_projects() {
  if [[ ! -d "$PROJECTS_DIR" ]]; then
    echo "No projects directory found."
    return
  fi

  local projects=($(ls -1 "$PROJECTS_DIR" 2>/dev/null || true))

  if [[ ${#projects[@]} -eq 0 ]]; then
    echo "No projects found."
    return
  fi

  echo -e "${BLUE}Projects:${NC}"
  for project in "${projects[@]}"; do
    local path="${PROJECTS_DIR}/${project}"
    local commit_count=$(cd "$path" && git rev-list --count HEAD 2>/dev/null || echo "0")
    printf "  %-30s %s commits\n" "$project" "$commit_count"
  done
}

###############################################################################
# Project Info
###############################################################################

project_info() {
  local project_name="$1"

  if [[ -z "$project_name" ]]; then
    echo -e "${RED}Error: Project name required${NC}"
    exit 1
  fi

  local project_path="${PROJECTS_DIR}/${project_name}"

  if [[ ! -d "$project_path" ]]; then
    echo -e "${RED}Project not found: ${project_name}${NC}"
    exit 1
  fi

  cd "$project_path"

  echo -e "${BLUE}Project: ${project_name}${NC}"
  echo "Path: ${project_path}"
  echo ""

  # Git info
  echo -e "${BLUE}Git Status:${NC}"
  git log -1 --format="%h %s (%ar)" || echo "  (no commits yet)"
  echo ""
  echo -e "${BLUE}Commits:${NC}"
  git rev-list --count HEAD
  echo ""

  # Files
  echo -e "${BLUE}Files:${NC}"
  find . -type f ! -path './.git/*' | head -20 | sed 's/^\.\//  /'
}

###############################################################################
# Main
###############################################################################

main() {
  local command="${1:-help}"

  case "$command" in
    create)
      create_project "$2" "$3"
      ;;
    list)
      list_projects
      ;;
    info)
      project_info "$2"
      ;;
    help|--help|-h|"")
      show_usage
      ;;
    *)
      echo -e "${RED}Unknown command: ${command}${NC}"
      show_usage
      exit 1
      ;;
  esac
}

main "$@"
