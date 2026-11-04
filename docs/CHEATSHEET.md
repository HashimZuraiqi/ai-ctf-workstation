# Competition-Day Cheat Sheet

## Auto-triage, flags and autosolver

```bash
ctftriage --desc "challenge text"      # first pass -> notes/triage.md (run this first)
ctfflag scan                           # find flags anywhere in the workspace
ctfflag decode "<encoded text>"        # peel encoding layers
ctfflag verify "<flag>" --cmd "python3 scripts/solve.py"   # confirm before submitting

# Optional any-model autosolver (set the endpoint first):
export CTFSOLVE_API_BASE=... CTFSOLVE_MODEL=...
ctfsolve --desc "challenge text" --nc host:port
```

See docs/AGENT_TOOLS.md for details.

## Start a challenge

```bash
ctfnew <name> <category>
cd ~/ctf/<name>
cp /path/to/challenge-files ./input/
sha256sum input/* | tee notes/input-sha256.txt
cp -a input/. work/
```

Categories: `rev`, `pwn`, `web`, `forensics`, `crypto`, `osint`, `mobile`, `ai-security`, `misc`.

## Enable the right AI tools

```bash
mcp-rev
mcp-pwn
mcp-web
mcp-forensics
mcp-crypto
mcp-osint
mcp-mobile
mcp-off
mcp-status
```

Use `mcp-all` only when the challenge genuinely spans several categories.

## Start an agent

```bash
cx   # Codex
ag   # Antigravity
cl   # Claude, optional if authenticated
```

First prompt pattern:

```text
Authorized CTF challenge. Read AGENTS.md and the relevant CTF skill.
Preserve input/ originals and work on copies. Start with evidence-only triage.
Update notes/analysis.md with observations, hypotheses, commands and next tests.
Do not guess a flag. Verify important conclusions with native tools.
```

## Reverse / pwn

```bash
file input/<binary>
checksec --file=input/<binary>
rz-bin -I input/<binary>
ghidra-ai
pwndbg work/<binary>
```

## Web

```bash
mcp-web
playwright-cli open <organizer-url>
playwright-cli snapshot
playwright-cli close
```

## Forensics

```bash
mcp-forensics
file input/*
exiftool input/*
binwalk input/<file>
tshark -r input/<capture.pcapng>
```

## Crypto

```bash
mcp-crypto
pwnenv
python
sage
```

Put reusable solvers in `scripts/` and assert recovered values instead of relying on manual calculations.

## OSINT

```bash
mcp-osint
```

Keep a source/provenance table in `notes/analysis.md`. Query only public/authorized challenge targets.

## Mobile

```bash
mcp-mobile
apktool d input/<app.apk> -o work/apktool
jadx -d work/jadx input/<app.apk>
```

## Health check

```bash
ctfdoctor
mcp-status
```

## Finish / handoff

```bash
mcp-off
git status
```

Make sure `notes/analysis.md` explains the current evidence, blocker, reproduction commands and next test so another teammate can continue immediately.
