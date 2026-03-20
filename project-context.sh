#!/bin/bash

###############################################################################
# project-context.sh
# Creates and manages project workspaces for focused work
# Supports working directories per Discord channel
###############################################################################

set -e

PROJECTS_DIR="${HOME}/.openclaw/project-context"
STATE_DIR="${PROJECTS_DIR}/.state"
STATE_FILE="${STATE_DIR}/channel-contexts.json"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

###############################################################################
# State Management
###############################################################################

init_state() {
  mkdir -p "$STATE_DIR"
  if [[ ! -f "$STATE_FILE" ]]; then
    echo "{}" > "$STATE_FILE"
  fi
}

# Get channel ID from environment or argument
get_channel_id() {
  if [[ -n "$OPENCLAW_CHANNEL_ID" ]]; then
    echo "$OPENCLAW_CHANNEL_ID"
  elif [[ -n "$1" ]]; then
    echo "$1"
  else
    echo "unknown-channel"
  fi
}

# Get working directory for current channel
get_working_dir() {
  local channel_id="$1"
  init_state
  jq -r ".\"$channel_id\" // \"\"" "$STATE_FILE"
}

# Set working directory for current channel
set_working_dir() {
  local channel_id="$1"
  local path="$2"
  init_state
  
  # Validate path exists
  if [[ ! -d "$PROJECTS_DIR/$path" ]]; then
    echo -e "${RED}Error: Directory does not exist: $PROJECTS_DIR/$path${NC}"
    return 1
  fi
  
  # Update state
  local temp_file=$(mktemp)
  jq ".\"$channel_id\" = \"$path\"" "$STATE_FILE" > "$temp_file"
  mv "$temp_file" "$STATE_FILE"
  
  echo -e "${GREEN}✓ Working directory: $path${NC}"
}

# Clear working directory for current channel
clear_working_dir() {
  local channel_id="$1"
  init_state
  local temp_file=$(mktemp)
  jq "del(.\"$channel_id\")" "$STATE_FILE" > "$temp_file"
  mv "$temp_file" "$STATE_FILE"
  echo -e "${GREEN}✓ Working directory cleared${NC}"
}

###############################################################################
# Usage
###############################################################################

show_usage() {
  cat <<EOF
Usage: project-context [command] [options]

Commands:
  create "<description>"           Create a new project in current working directory
  create <path> "<description>"    Create a project at specified path
  cd <path>                        Set working directory for this channel
  pwd                              Show current working directory
  list                             List all projects
  info <path>                      Show project info
  help                             Show this help

Working Directory:
  Each channel has its own working directory. Use 'cd' to set it.
  When you 'create' without a path, it creates in the current working directory.

Examples:
  /project-context cd personal/taxes/2025
  /project-context create taxes-2026 "Prepare 2026 tax return"
  /project-context cd simny/taxes/2025
  /project-context pwd
  /project-context list
  /project-context info simny/taxes/2025

EOF
}

###############################################################################
# Change Working Directory
###############################################################################

change_dir() {
  local path="$1"
  local channel_id="$2"

  if [[ -z "$path" ]]; then
    echo -e "${RED}Error: Path required${NC}"
    show_usage
    return 1
  fi

  # Normalize path (remove leading/trailing slashes)
  path="${path#/}"
  path="${path%/}"

  set_working_dir "$channel_id" "$path"
}

###############################################################################
# Print Working Directory
###############################################################################

print_wd() {
  local channel_id="$1"
  local wd=$(get_working_dir "$channel_id")
  
  if [[ -z "$wd" ]]; then
    echo -e "${YELLOW}No working directory set. Use 'cd' to set one.${NC}"
  else
    echo -e "${BLUE}Working directory: ${wd}${NC}"
  fi
}

###############################################################################
# Create Project
###############################################################################

create_project() {
  local name_or_path="$1"
  local description_or_empty="$2"
  local channel_id="$3"

  # Determine if we have path and description, or just description
  local project_path
  local project_description
  local project_name

  if [[ -z "$name_or_path" ]]; then
    echo -e "${RED}Error: Project description required${NC}"
    show_usage
    return 1
  fi

  # Check if this looks like a path (contains /)
  if [[ "$name_or_path" == */* ]]; then
    # Explicit path provided
    project_path="$name_or_path"
    project_description="$description_or_empty"
    project_name=$(basename "$project_path")
  else
    # Just name provided, use working directory
    project_name="$name_or_path"
    project_description="$description_or_empty"
    local wd=$(get_working_dir "$channel_id")
    
    if [[ -z "$wd" ]]; then
      echo -e "${RED}Error: No working directory set${NC}"
      echo -e "${YELLOW}Use 'cd <path>' to set working directory first${NC}"
      echo -e "${YELLOW}Or specify full path: create <path>/<name> \"description\"${NC}"
      return 1
    fi
    
    project_path="$wd/$project_name"
  fi

  if [[ -z "$project_description" ]]; then
    echo -e "${RED}Error: Project description required${NC}"
    show_usage
    return 1
  fi

  # Validate project name
  local name_part=$(basename "$project_path")
  if [[ ! "$name_part" =~ ^[a-z0-9_-]+$ ]]; then
    echo -e "${RED}Error: Project name must be lowercase alphanumeric, hyphens, or underscores${NC}"
    return 1
  fi

  # Create full path
  local full_path="${PROJECTS_DIR}/${project_path}"
  
  # Check if project already exists
  if [[ -d "$full_path" ]]; then
    echo -e "${YELLOW}Project already exists at: ${project_path}${NC}"
    return 1
  fi

  # Create directory structure
  echo -e "${BLUE}Creating project: ${project_path}${NC}"
  mkdir -p "$full_path"

  # Create README with project context
  cat > "${full_path}/README.md" <<EOF
# $(basename "$project_path")

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
*Project: ${project_path}*
EOF

  # Create initial subdirectories
  mkdir -p "${full_path}/docs" "${full_path}/drafts" "${full_path}/final"

  # Commit to repository
  echo -e "${BLUE}Committing to repository...${NC}"
  cd "$PROJECTS_DIR"
  git add "${project_path}/"
  git commit -m "feat: create project ${project_path}"

  # Push to GitHub
  if git remote get-url origin &>/dev/null; then
    echo -e "${BLUE}Pushing to GitHub...${NC}"
    if git push origin main 2>/dev/null; then
      echo -e "${GREEN}✓ Project created: ${project_path}${NC}"
      echo -e "${GREEN}✓ Committed and pushed to GitHub${NC}"
    else
      echo -e "${GREEN}✓ Project created: ${project_path}${NC}"
      echo -e "${GREEN}✓ Committed to repository${NC}"
      echo -e "${YELLOW}⚠ Push to GitHub failed (may need manual push)${NC}"
    fi
  else
    echo -e "${GREEN}✓ Project created: ${project_path}${NC}"
    echo -e "${GREEN}✓ Committed to repository${NC}"
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

  local projects=($(find "$PROJECTS_DIR" -maxdepth 3 -type d ! -path "*/.git*" ! -path "*/.state*" -mindepth 2 | sort))

  if [[ ${#projects[@]} -eq 0 ]]; then
    echo "No projects found."
    return
  fi

  echo -e "${BLUE}Projects in repository:${NC}"
  for proj_path in "${projects[@]}"; do
    # Get relative path
    local rel_path="${proj_path#$PROJECTS_DIR/}"
    
    # Skip if it's just a directory with subdirs but no README
    if [[ ! -f "$proj_path/README.md" ]]; then
      continue
    fi
    
    local file_count=$(find "$proj_path" -type f ! -path '*/.git/*' ! -path '*/.state/*' 2>/dev/null | wc -l)
    printf "  %-40s %s files\n" "$rel_path" "$file_count"
  done
}

###############################################################################
# Project Info
###############################################################################

project_info() {
  local path="$1"

  if [[ -z "$path" ]]; then
    echo -e "${RED}Error: Project path required${NC}"
    return 1
  fi

  # Normalize path
  path="${path#/}"
  path="${path%/}"

  local full_path="${PROJECTS_DIR}/${path}"

  if [[ ! -d "$full_path" ]]; then
    echo -e "${RED}Project not found: ${path}${NC}"
    return 1
  fi

  echo -e "${BLUE}Project: ${path}${NC}"
  echo "Path: ${full_path}"
  echo ""

  # Git info (from repository)
  echo -e "${BLUE}Git History:${NC}"
  cd "$PROJECTS_DIR"
  git log --oneline -- "$path" | head -5 || echo "  (no commits yet)"
  echo ""

  # Files
  echo -e "${BLUE}Files:${NC}"
  find "$full_path" -type f ! -path '*/.git/*' ! -path '*/.state/*' | head -20 | sed "s|^${PROJECTS_DIR}/||"
}

###############################################################################
# Main
###############################################################################

main() {
  # Get channel ID from environment or use fallback
  local channel_id=$(get_channel_id "$OPENCLAW_CHANNEL_ID")
  
  local command="${1:-help}"

  case "$command" in
    create)
      create_project "$2" "$3" "$channel_id"
      ;;
    cd)
      change_dir "$2" "$channel_id"
      ;;
    pwd)
      print_wd "$channel_id"
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
      return 1
      ;;
  esac
}

main "$@"
