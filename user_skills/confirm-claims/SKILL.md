---
name: confirm-claims
description: Switch to raw-evidence-only mode. Use when the user says "confirm claims", "show me the source", "don't make things up", or questions the accuracy of a previous response.
disable-model-invocation: true
---

# Confirm Claims Protocol

Aidan is asking you to back up your statements with primary sources. **Stop interpreting. Provide only verifiable evidence.**

## Steps

1. **Find evidence** — search the codebase, the web, or Cursor-indexed docs for primary sources that support each claim.
2. **For each claim**, provide one or more of the evidence types below. If you can't find evidence, say so.

## Gathering evidence from external repos

When you need to verify claims about code in an external repo (e.g., flashinfer, cutlass, vllm, pytorch):
- **Prefer cloning the repo** over navigating GitHub via web fetch. Cursor's code grep/search tools are far superior to scraping GitHub HTML.
- Clone the repo into the current workspace (NOT /tmp — Cursor tools can't reach /tmp). Then use Grep/Read/Glob to find the exact code.
- Don't clean up the clones — leave them for next time.
- When citing code from cloned repos, use Cursor's clickable code reference format (```startLine:endLine:filepath) so Aidan can click through to the source.
- This is especially useful when you need to verify multiple claims across the same repo.

## Evidence types

For every claim, provide one of:
- **Links:** URL to the specific doc page, GitHub file at a pinned commit, etc.
- **Exact quotes:** Copy-paste from docs so Aidan can search for it
- **Code snippets:** The actual code, not a summary
- **Raw NCU metrics:** Use exact counter names (e.g., `sm__warps_active.avg.pct_of_peak_sustained_active`, not "warp occupancy")

Rules:
- If you can't find evidence for a claim, say "I couldn't find a source for this" — don't fill the gap with reasoning
- No speculative explanations. Raw data only.

Good docs you might want to reference (for CUDA programming):
- [Nsight Compute Profiling Guide](https://docs.nvidia.com/nsight-compute/ProfilingGuide/index.html)
- [Blackwell Tuning Guide](https://docs.nvidia.com/cuda/blackwell-tuning-guide/index.html)
- "CUDA C++ Programming Guide" (Cursor indexed)
- "Programming Parallel Computers" (Cursor indexed)
