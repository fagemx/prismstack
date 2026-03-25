#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"

# --- Mode detection ---
MODE="${1:-}"
case "$MODE" in
  --global)
    # Flat install: each skill as independent entry in ~/.claude/skills/
    TARGET="${TARGET:-${HOME}/.claude/skills}"
    INSTALL_MODE="global"
    ;;
  --project)
    # Nested install: all skills under .claude/skills/prismstack/ (project-level)
    PROJECT_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
    TARGET="${TARGET:-${PROJECT_ROOT}/.claude/skills/prismstack}"
    INSTALL_MODE="project"
    ;;
  *)
    echo "Prismstack Installer"
    echo ""
    echo "Usage:"
    echo "  bash install.sh --project    Install to current project (recommended)"
    echo "                               → .claude/skills/prismstack/"
    echo "                               → All skills discoverable via recursive scan"
    echo ""
    echo "  bash install.sh --global     Install to global ~/.claude/skills/"
    echo "                               → Each skill as independent global skill"
    echo "                               → Works across all projects"
    echo ""
    echo "  TARGET=/path bash install.sh --project   Override install target"
    exit 0
    ;;
esac

echo "Installing Prismstack (${INSTALL_MODE} mode) to ${TARGET}..."
echo ""

# --- Copy skills ---
copy_skill() {
  local skill_dir="$1"
  local dest="$2"

  mkdir -p "$dest"
  [ -f "$skill_dir/SKILL.md" ] && cp "$skill_dir/SKILL.md" "$dest/"
  if [ -d "$skill_dir/references" ]; then
    rm -rf "$dest/references"
    cp -r "$skill_dir/references" "$dest/references"
  fi
  if [ -d "$skill_dir/scripts" ]; then
    rm -rf "$dest/scripts"
    cp -r "$skill_dir/scripts" "$dest/scripts"
  fi
}

if [ "$INSTALL_MODE" = "project" ]; then
  # --- Project mode: nested under prismstack/ ---
  mkdir -p "$TARGET"

  for skill_dir in "$REPO_DIR"/skills/*/; do
    skill_name=$(basename "$skill_dir")
    [ "$skill_name" = "shared" ] && continue
    copy_skill "$skill_dir" "$TARGET/$skill_name"
    echo "  ✓ $skill_name"
  done

  # Root SKILL.md = routing entry point (Claude Code discovers this)
  cp "$REPO_DIR/skills/prism-routing/SKILL.md" "$TARGET/SKILL.md"
  echo "  ✓ root SKILL.md (routing entry point)"

  # Shared resources
  mkdir -p "$TARGET/shared"
  cp -r "$REPO_DIR/skills/shared/"* "$TARGET/shared/" 2>/dev/null || true
  echo "  ✓ shared resources"

  SKILL_COUNT=$(find "$TARGET" -name "SKILL.md" | wc -l | tr -d ' ')

else
  # --- Global mode: flat, each skill is independent ---
  # Each skill gets its own directory in ~/.claude/skills/
  # Prefix with "prism-" to avoid namespace conflicts (except prism-routing → prismstack)

  for skill_dir in "$REPO_DIR"/skills/*/; do
    skill_name=$(basename "$skill_dir")
    [ "$skill_name" = "shared" ] && continue

    if [ "$skill_name" = "prism-routing" ]; then
      # Routing skill → ~/.claude/skills/prismstack/
      dest="$TARGET/prismstack"
    else
      # Other skills → ~/.claude/skills/{skill-name}/
      dest="$TARGET/$skill_name"
    fi

    copy_skill "$skill_dir" "$dest"
    echo "  ✓ $skill_name → $(basename "$dest")/"
  done

  # Shared resources → ~/.claude/skills/prismstack/shared/
  mkdir -p "$TARGET/prismstack/shared"
  cp -r "$REPO_DIR/skills/shared/"* "$TARGET/prismstack/shared/" 2>/dev/null || true
  echo "  ✓ shared resources → prismstack/shared/"

  SKILL_COUNT=$(ls -d "$TARGET"/domain-plan "$TARGET"/domain-build "$TARGET"/skill-check "$TARGET"/skill-gen "$TARGET"/skill-edit "$TARGET"/source-convert "$TARGET"/tool-builder "$TARGET"/domain-upgrade "$TARGET"/workflow-edit "$TARGET"/prismstack 2>/dev/null | wc -l | tr -d ' ')
fi

echo ""
echo "Prismstack installed successfully (${INSTALL_MODE} mode)."
echo "Skills installed: ${SKILL_COUNT}"

if [ "$INSTALL_MODE" = "project" ]; then
  echo ""
  echo "Skills will be available in this project after restarting Claude Code."
  echo "Sub-skills (domain-plan, domain-build, etc.) are auto-discovered via recursive scan."
elif [ "$INSTALL_MODE" = "global" ]; then
  echo ""
  echo "Skills will be available globally after restarting Claude Code."
  echo "Each skill is independently discoverable as a slash command."
fi
