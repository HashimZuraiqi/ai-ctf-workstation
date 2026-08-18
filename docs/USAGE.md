# General CTF Workstation Tutorial

This is the category-independent routine every teammate can follow.

## Step 1 — Create a workspace

```bash
ctfnew <challenge-name> <category>
cd ~/ctf/<challenge-name>
```

Examples:

```bash
ctfnew babyrev rev
ctfnew heap-school pwn
ctfnew portal web
ctfnew mystery-file forensics
ctfnew model-jail ai-security
```

Generated layout:

```text
challenge/
├── input/             untouched organizer files
├── work/              copies and temporary analysis files
├── notes/analysis.md  running evidence log
├── exploit/           exploit/solver code
├── scripts/           helpers and automation
├── artifacts/         generated outputs
├── browser-artifacts/ browser screenshots/snapshots
├── AGENTS.md
├── GEMINI.md
└── CLAUDE.md
```

## Step 2 — Put originals in `input/`

Do not edit organizer-provided files in place.

```bash
cp /path/to/challenge/* ./input/
cp -a input/. work/
```

Hash important originals:

```bash
sha256sum input/* | tee notes/input-sha256.txt
```

## Step 3 — Triage before going deep

Useful first commands:

```bash
find input -maxdepth 2 -type f -printf '%p\n'
file input/*
exiftool input/* 2>/dev/null | less
strings -a input/<file> | head -n 100
```

For ELF binaries:

```bash
checksec --file=input/<binary>
readelf -hW input/<binary>
rz-bin -I input/<binary>
```

Record the important observations in `notes/analysis.md`.

## Step 4 — Pick the smallest useful MCP profile

```bash
mcp-rev     # reverse engineering
mcp-pwn     # binary exploitation
mcp-web        # web/browser interaction
mcp-forensics  # forensic artifacts
mcp-crypto      # crypto/math tooling
mcp-osint       # OSINT helpers + browser
mcp-mobile      # Ghidra + GDB for mobile/native analysis
mcp-all     # only when truly useful
mcp-off     # when MCP is unnecessary
```

A smaller tool surface is easier to reason about and reduces accidental actions.

## Step 5 — Start the AI from the challenge directory

```bash
cx   # Codex
# or
ag   # Antigravity
# or, if authenticated
cl   # Claude
```

A good first prompt:

```text
This is an authorized CTF challenge. Read AGENTS.md and the category skill.
Start with evidence-only triage of files under input/. Preserve originals.
Create/update notes/analysis.md with observations, hypotheses, commands run,
and next tests. Do not guess a flag. Ask before destructive operations or submission.
```

## Step 6 — Ask for a plan, then verify it

Good AI tasks include:

- summarize protections and entry points
- explain suspicious functions or protocol flows
- propose the next 3 experiments ranked by information gain
- write a solver harness with clear assertions
- compare static and dynamic evidence
- convert manual repetition into a script
- review your exploit/solver for assumptions and failure cases

Do not accept a conclusion merely because the model sounds confident. Reproduce it with the relevant native tool.

## Step 7 — Keep notes continuously

Use a simple evidence format:

```markdown
## Observation
- Command/tool:
- Result:
- Why it matters:

## Hypothesis
- Claim:
- Evidence for:
- Evidence against:
- Next test:
```

## Step 8 — Build a repeatable solve

Prefer `scripts/solve.py`, `exploit/exploit.py`, or another deterministic script over a one-off sequence of terminal commands.

A teammate should be able to clone/pull the challenge branch, place the permitted challenge files in `input/`, and reproduce the result from the notes and scripts.

## Step 9 — Final validation

Before treating a flag/result as solved:

- reproduce the result from a clean process/session
- confirm assumptions such as architecture, offsets, encodings, endpoints and expected input format
- verify the target is still the authorized CTF service/file
- record the final command or steps in notes

## Step 10 — Close the challenge cleanly

```bash
mcp-off
git status
```

Do not commit auth tokens, browser sessions, large cores, or private organizer files that your rules prohibit sharing.
