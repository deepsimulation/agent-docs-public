---
name: draft-pr-description
description: Draft a PR description for the current branch. Use when the user says "draft PR description", "write PR description", "PR description", or wants to summarize their branch changes for a pull request.
---

# Draft PR Description

Generate a PR description for the current branch by studying the user's preferred format, reviewing all changes, and frontloading results.

## Steps

1. **Study PR style.** Fetch recent PRs from two sources to learn the conventions:

```bash
# User's own recent PRs (personal style)
gh pr list --author="@me" --state=merged --limit=5 --json title,body,url

# Repo's recent PRs (repo-level conventions)
gh pr list --state=merged --limit=10 --json title,body,url,author
```

Read through the titles and bodies from both sets. Pay attention to:
- The structure and sections used (e.g., summary, test plan, results)
- Tone and level of detail
- How results/benchmarks are presented
- Any repo-specific conventions (labels, templates, required sections)

2. **Sync with remote and get the diff.** Pull latest changes and diff against `origin/main`:

```bash
git pull
git diff origin/main --stat
git diff origin/main
```

Also review the commit history on this branch:

```bash
git log origin/main..HEAD --oneline
```

3. **Read all relevant files.** Read any files that were changed (especially new files, config changes, benchmark results, eval outputs, and `progress.md`) to fully understand what the branch does.

4. **Draft the PR description.** Write `PR_DESCRIPTION.md` in the repo root.

**Formatting priorities (in order):**
- **Frontload results first and foremost.** Benchmark numbers, e2e lifts, eval results, latency improvements, throughput gains — put these at the very top. If there are tables or charts, include them prominently. When summarizing results inline, also include the full comprehensive results (complete benchmark tables, full eval output, raw numbers) under a `<details>` dropdown so reviewers can dig into the details.
- **Include test output when available.** Paste relevant test output (pass/fail summaries, test run logs) to show the changes are validated. Show a concise summary inline, then include the full untruncated output under a `<details>` dropdown.
- **Describing the changes is secondary.** A brief summary of what was done comes after the results. Keep it concise.
- Match the style and structure observed from the user's recent PRs.

5. **Handle existing PR_DESCRIPTION.md.** Before writing, check if `PR_DESCRIPTION.md` already exists. If it does, rename it:

```bash
# Find the next available number
N=1
while [ -f "PR_DESCRIPTION_${N}.md" ]; do
  N=$((N + 1))
done
mv PR_DESCRIPTION.md "PR_DESCRIPTION_${N}.md"
```

Then create the new `PR_DESCRIPTION.md`.

## Rules

- **Results first, description second.** The most important thing in the PR description is quantitative results — benchmarks, eval scores, performance numbers. The explanation of what changed is supporting context.
- Do not fabricate numbers. Only include results you can find in the diff, `progress.md`, or other files in the repo.
- Keep the description concise. Prefer tables and bullet points over prose.
- If no benchmark/eval results exist in the branch, note that and focus on the change description instead.
