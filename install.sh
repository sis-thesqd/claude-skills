#!/bin/bash

# Claude Code Skills Installer — The Squad
# Usage: curl -sL https://raw.githubusercontent.com/sis-thesqd/claude-skills/main/install.sh | bash

set -e

BASE_URL="https://raw.githubusercontent.com/sis-thesqd/claude-skills/main/skills"
DEST="$HOME/.claude/commands"

# List of all skills to install
SKILLS=(
  "squad-app-audit.md"
)

echo ""
echo "🤖 Claude Code Skills Installer — The Squad"
echo "============================================"
echo ""

# Create commands directory if it doesn't exist
mkdir -p "$DEST"
echo "📁 Install directory: $DEST"
echo ""

# Install each skill
INSTALLED=0
FAILED=0

for SKILL in "${SKILLS[@]}"; do
  echo -n "  Installing $SKILL ... "
  if curl -sfL "$BASE_URL/$SKILL" -o "$DEST/$SKILL"; then
    echo "✅"
    INSTALLED=$((INSTALLED + 1))
  else
    echo "❌ (failed to download)"
    FAILED=$((FAILED + 1))
  fi
done

echo ""
echo "============================================"
echo "✅ Installed: $INSTALLED skill(s)"
if [ $FAILED -gt 0 ]; then
  echo "❌ Failed: $FAILED skill(s)"
fi
echo ""
echo "Skills are now available globally in Claude Code."
echo "Try running: /squad-app-audit"
echo ""
