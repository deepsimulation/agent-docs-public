```bash
# Setup - fireworks
(cd $FIREWORKS_DIR && gh api repos/aidando73/agent-docs/contents/scripts/setup.sh --jq '.content' | base64 -d | bash)

Other repos:
gh api repos/aidando73/agent-docs/contents/scripts/setup.sh --jq '.content' | base64 -d | bash
```
