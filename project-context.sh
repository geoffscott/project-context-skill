#!/bin/bash

###############################################################################
# project-context.sh
# Creates and manages project workspaces for focused work
###############################################################################

set -e

PROJECTS_DIR="${HOME}/.openclaw/project-context"

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

  # Initialize projects monorepo if needed
  if [[ ! -d "$PROJECTS_DIR/.git" ]]; then
    echo -e "${BLUE}Initializing projects monorepo...${NC}"
    mkdir -p "$PROJECTS_DIR"
    cd "$PROJECTS_DIR"
    git init
    git config user.name "ananda-bot"
    git config user.email "ananda@growthscience.co"
  fi

  # Create directories
  echo -e "${BLUE}Creating project: ${project_name}${NC}"
  mkdir -p "$project_path"

  # Create README with project context
  cat > "${project_path}/README.md" <<EOF
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
  mkdir -p "${project_path}/docs" "${project_path}/drafts" "${project_path}/final"

  # Commit to monorepo
  echo -e "${BLUE}Committing to monorepo...${NC}"
  cd "$PROJECTS_DIR"
  git add "${project_name}/"
  git commit -m "feat: create project ${project_name}"

  echo -e "${GREEN}✓ Project created: ${project_path}${NC}"
  echo -e "${GREEN}✓ Committed to monorepo${NC}"
}

###############################################################################
# List Projects
###############################################################################

list_projects() {
  if [[ ! -d "$PROJECTS_DIR" ]]; then
    echo "No projects directory found."
    return
  fi

  local projects=($(ls -1 "$PROJECTS_DIR" 2>/dev/null | grep -v '^\.' || true))

  if [[ ${#projects[@]} -eq 0 ]]; then
    echo "No projects found."
    return
  fi

  echo -e "${BLUE}Projects in monorepo:${NC}"
  for project in "${projects[@]}"; do
    local path="${PROJECTS_DIR}/${project}"
    if [[ -d "$path" && "$project" != ".git" ]]; then
      local file_count=$(find "$path" -type f ! -path '*/.git/*' 2>/dev/null | wc -l)
      printf "  %-30s %s files\n" "$project" "$file_count"
    fi
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

  echo -e "${BLUE}Project: ${project_name}${NC}"
  echo "Path: ${project_path}"
  echo ""

  # Git info (from monorepo)
  echo -e "${BLUE}Git History (monorepo):${NC}"
  cd "$PROJECTS_DIR"
  git log --oneline -- "$project_name/" | head -5 || echo "  (no commits yet)"
  echo ""

  # Files
  echo -e "${BLUE}Files:${NC}"
  find "$project_path" -type f ! -path '*/.git/*' | head -20 | sed "s|^${PROJECTS_DIR}/||"
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
