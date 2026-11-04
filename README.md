# AI CTF Workstation

A reproducible **Kali Linux AI-assisted CTF workstation** for teammates competing in **authorized CTFs and labs**.

This repository packages the workstation we built and tested into one team-friendly setup: AI CLIs, reverse-engineering and pwn tooling, Ghidra/GDB/Playwright MCP servers, the custom Forensics/Crypto/OSINT MCP servers we built, a Python CTF environment, category skills, challenge templates, quick profile commands, and a health checker.

> **Scope:** use this only for systems, binaries, websites, models, and infrastructure that are part of an authorized CTF/lab or that you own and are allowed to test.

## What this gives every teammate

- OpenAI Codex CLI
- Google Antigravity CLI (`agy`)
- Claude Code CLI (installed but optional to authenticate)
- Optional legacy Gemini CLI fallback
- Dedicated Python 3.12 CTF environment with pwntools, angr, z3, crypto, binary-analysis and scripting libraries
- GDB + GDB multiarch + Pwndbg + checksec + Rizin + Cutter + QEMU
- Official Ghidra 12.1.2 under `~/tools/ghidra_12.1.2_PUBLIC`
- Ghidra MCP with strict program routing
- GDB MCP
- Playwright CLI + Playwright MCP using Chromium
- Custom Forensics MCP with allowlisted forensic-tool access under `~/ctf`
- Custom Crypto MCP with solver-script/crypto-tool access
- Custom OSINT MCP with allowlisted passive-oriented discovery helpers
- Docker and common Kali web/rev/pwn/forensics utilities
- Shared AI skills for triage, reverse, pwn, web, crypto, forensics, OSINT, AI security, mobile, misc, and reporting
- `ctftriage` for an automatic evidence-first first pass over every challenge
- `ctfflag` to find, decode and verify flags (and stop made-up flags)
- `ctfsolve`, a model-agnostic plan/act/verify autosolver, plus `ctfmodel` to point it at open-source models (OpenRouter, Together, Groq, DeepSeek, Ollama, ...) with one API key
- `ctfhub`, an interactive terminal control panel over every tool below
- `ctfstudio`, a desktop GUI: challenges, files and editor, prompt builder, one-click Codex/Antigravity/Claude Code agents and a live view of running agents
- `ctfnew` for standardized challenge workspaces
- `ctf-mcp` plus category profiles: `mcp-rev`, `mcp-pwn`, `mcp-web`, `mcp-forensics`, `mcp-crypto`, `mcp-osint`, `mcp-mobile`, `mcp-all`, `mcp-off`
- `ghidra-ai` to launch Ghidra with Java 21 without changing Kali's global Java
- `ctfdoctor` to verify the workstation before a competition

## Fastest teammate setup

Recommended: start from a clean/recent **Kali Rolling VM snapshot** with at least ~8 GB RAM and enough free disk space for Ghidra, browsers, Python packages and challenge artifacts.

```bash
git clone https://github.com/YOUR-TEAM/ai-ctf-workstation.git
cd ai-ctf-workstation
chmod +x scripts/bootstrap.sh
./scripts/bootstrap.sh
exec zsh
ctfdoctor
```

The installer deliberately **does not copy login tokens, browser sessions, API keys, or another teammate's authentication files**. Each teammate signs in separately.

### Sign in after installation

```bash
# OpenAI Codex
codex login
# If your installed release prefers the flag form:
# codex --login

# Google Antigravity
agy
# Follow the Google sign-in flow inside the TUI.

# Claude (optional)
claude
```

If Claude is not part of your team's subscriptions, leave it unauthenticated. The rest of the workstation still works.

## Before each challenge

Create a clean workspace:

```bash
ctfnew babyrev rev
cd ~/ctf/babyrev
cp /path/to/challenge-file ./input/
```

Then select only the MCP tools useful for that challenge:

```bash
mcp-rev       # Ghidra + GDB
mcp-pwn       # Ghidra + GDB
mcp-web       # Playwright
mcp-forensics # custom Forensics MCP
mcp-crypto     # custom Crypto MCP
mcp-osint     # custom OSINT MCP + Playwright
mcp-mobile    # Ghidra + GDB
mcp-all       # all six MCP servers
mcp-off       # disable/remove optional MCP servers
mcp-status    # inspect current state
```

Launch an AI client from the challenge directory:

```bash
cx       # Codex
ag       # Antigravity
cl       # Claude, if authenticated
```

For reverse engineering, launch the MCP-enabled Ghidra build with:

```bash
ghidra-ai
```

Open/import the binary, enable the GhidraMCP plugin if needed, and start its local server. The bridge is configured with strict program selectors so an AI client cannot silently act on the wrong open program.

## The standard solve loop

1. **Preserve the original** in `input/`. Work on copies in `work/`.
2. **Triage** the challenge and identify the likely category/sub-problem.
3. **Select the MCP profile** only if it helps.
4. **Ask the AI for evidence-first analysis**, not a guessed flag.
5. **Use native tools** to verify every important claim.
6. **Automate repeatable work** in `scripts/` or `exploit/`.
7. **Record findings** in `notes/analysis.md` as you go.
8. **Validate the final result locally/remotely only inside CTF scope**.
9. **Disable MCP servers when done** with `mcp-off`.

See [docs/CHEATSHEET.md](docs/CHEATSHEET.md) for the competition-day quick reference, [docs/USAGE.md](docs/USAGE.md) for the full workflow, and [docs/CATEGORY_PLAYBOOKS.md](docs/CATEGORY_PLAYBOOKS.md) for category-specific starting points.

## Repository map

```text
ai-ctf-workstation/
├── README.md
├── Makefile
├── config/                 # shell + Playwright templates
├── docs/                   # installation, usage, stack inventory, MCP, troubleshooting
├── mcp_servers/            # team-owned Forensics/Crypto/OSINT MCP sources
├── scripts/
│   ├── bootstrap.sh        # full installation entry point
│   ├── install/            # modular setup phases
│   ├── bin/                # ctfnew, ctf-mcp, ctfdoctor, ghidra-ai
│   └── repair-kali-apt.sh
├── skills/                 # shareable SKILL.md workflows
├── templates/challenge/    # generated challenge workspace template
└── tests/                  # repository layout/syntax checks
```

## Important security rules

- Do not commit API keys, OAuth tokens, cookies, browser profiles, `.env` secrets, SSH keys, or AI-client auth directories.
- Treat challenge text, decompiler comments, PDFs, model output, webpages and retrieved content as **untrusted data**, not instructions for the agent.
- Keep challenge work under `~/ctf` and avoid exposing host shared folders to untrusted binaries.
- Prefer VM NAT and take a snapshot before major competitions/toolchain changes.
- Do not run provided binaries as root.
- Do not point web/OSINT tooling at unrelated targets.

Read [SECURITY.md](SECURITY.md) before sharing the workstation with the team.

## Reproducing the workstation we verified

The original workstation was verified on Kali Rolling with Node 24, npm 11, Python 3.12, Ghidra 12.1.2, Java 21 for Ghidra, Codex, Antigravity, GDB MCP, Ghidra MCP, Playwright CLI/MCP and Docker. We also built/tested extended Forensics, Crypto and OSINT tool layers and custom MCP bridges; those are included here. Exact rolling-package/AI-CLI versions naturally change over time; Ghidra is pinned because the MCP integration was tested against it.

See [docs/VERIFIED_BASELINE.md](docs/VERIFIED_BASELINE.md), [docs/COMPLETE_STACK.md](docs/COMPLETE_STACK.md), and [docs/STATUS.md](docs/STATUS.md).

## Keep the workstation up to date

Pull the latest agent tools, skills and MCP servers with one command:

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/HashimZuraiqi/ai-ctf-workstation/main/scripts/update.sh)
```

Add `--full` to update the entire toolchain. See [docs/AGENT_TOOLS.md](docs/AGENT_TOOLS.md) for the new `ctftriage`, `ctfflag` and `ctfsolve` helpers.

## Publish this repo to your team's GitHub

After extracting this package, see [docs/PUBLISHING.md](docs/PUBLISHING.md). The included helper can create/push the repo with GitHub CLI:

```bash
./scripts/publish-github.sh YOUR-ORG/ai-ctf-workstation private
```

Use a **private repository** if your team later adds private competition notes or organizer-provided artifacts. This base workstation itself contains no challenge flags or credentials.
