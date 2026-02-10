#!/bin/bash
set -euo pipefail

# Clone agent-docs and install AGENTS.md as a Cursor rule
# Run from the root of the fireworks repo

cd "$(pwd)"

if [ -d "agent-docs-public" ]; then
    echo "agent-docs-public/ already exists, pulling latest..."
    git -C agent-docs-public pull
else
    echo "Cloning agent-docs-public..."
    git clone https://github.com/deepsimulation/agent-docs-public.git agent-docs-public
fi

echo "Copying user skills to ~/.cursor/skills/"
mkdir -p ~/.cursor/skills/
cp -r agent-docs-public/user_skills/* ~/.cursor/skills/

echo "Copying user rules to ~/.cursor/rules/"
mkdir -p ~/.cursor/rules/
cp agent-docs-public/user_rules/*.mdc ~/.cursor/rules/
