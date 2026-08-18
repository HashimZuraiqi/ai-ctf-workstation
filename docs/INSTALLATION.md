# Installation Guide

## 1. Recommended VM baseline

Use a current Kali Rolling VM. The workstation was built on x86-64; 8 GB RAM is workable, and more RAM/disk helps for Ghidra, Sage, Chromium and Docker.

Recommended VM hygiene before a competition:

- NAT networking unless the event requires something else
- take a clean snapshot before major toolchain changes
- avoid exposing host shared folders to untrusted challenge binaries
- do not store provider secrets inside challenge folders

## 2. Clone and run

```bash
git clone https://github.com/YOUR-TEAM/ai-ctf-workstation.git
cd ai-ctf-workstation
chmod +x scripts/bootstrap.sh
./scripts/bootstrap.sh
exec zsh
ctfdoctor
```

The bootstrap reproduces the full stack and runs these phases:

```text
00-preflight.sh       OS/disk/basic checks
10-system.sh          Kali packages and common CTF utilities
20-ai-clis.sh         Codex, Antigravity, Claude, Playwright CLI
30-python.sh          uv + Python 3.12 + shared CTF environment
35-forensics.sh       extended forensics toolkit
36-crypto.sh          crypto/math toolkit + RsaCtfTool + isolated Sage
37-osint.sh           OSINT toolkit
40-native.sh          native reverse/pwn extras + Pwndbg
50-ghidra-mcp.sh      official Ghidra 12.1.2 + Ghidra MCP build/deploy
55-category-mcps.sh   custom Forensics/Crypto/OSINT MCP servers
60-browser.sh         Chromium + Playwright configs
70-skills.sh          11 shared CTF skills for supported AI clients
80-helpers.sh         ctfnew, ctf-mcp, ctfdoctor, ghidra-ai, aliases
90-mcp.sh             initializes workstation MCP entries, ending in OFF state
```

### Lighter install if Sage is intentionally not wanted

SageMath is by far the heaviest optional component:

```bash
CTF_SKIP_SAGE=1 ./scripts/bootstrap.sh
```

Everything else remains installed; `ctfdoctor` will report Sage as a warning rather than a fatal failure.

### Re-run individual phases

Every phase can be run directly, for example:

```bash
./scripts/install/35-forensics.sh
./scripts/install/36-crypto.sh
./scripts/install/55-category-mcps.sh
```

## 3. Authentication is per teammate

The repository never distributes another teammate's login state.

### Codex

```bash
codex --login
```

`codex login` may also be accepted by the installed CLI release.

### Antigravity

```bash
agy
```

Follow the Google sign-in flow in the TUI.

### Claude (optional)

```bash
claude
```

If the teammate has no Claude access/subscription, leave it unauthenticated.

## 4. Verify the workstation

```bash
ctfdoctor
mcp-status
```

Create a disposable workspace:

```bash
ctfnew workstation-test misc
cd ~/ctf/workstation-test
```

### Browser smoke test

```bash
playwright-cli open https://example.com
playwright-cli snapshot
playwright-cli close
```

If a display server is unavailable, change `headless` to `true` in the relevant Playwright config.

### GDB smoke test

```bash
cat > work/test.c <<'EOF_C'
#include <stdio.h>
int add(int a, int b) { return a + b; }
int main(void) { printf("result=%d\n", add(20, 22)); return 0; }
EOF_C
gcc -g -O0 -fno-omit-frame-pointer -no-pie -o work/test work/test.c
gdb -q ./work/test
```

### Ghidra MCP smoke test

1. `mcp-rev`
2. `ghidra-ai`
3. Create/open a Ghidra project and import a test binary.
4. Enable/start GhidraMCP in Ghidra.
5. Verify:

```bash
curl -s http://127.0.0.1:8089/get_version | jq
```

6. Start `cx` or `ag` from the challenge directory and first ask it to list the open Ghidra program before requesting analysis.

### Category MCP smoke tests

```bash
mcp-forensics
mcp-status

mcp-crypto
mcp-status

mcp-osint
mcp-status
```

Inside Codex/Antigravity, ask the relevant server for its `*_inventory` tool first. This checks tool visibility without modifying a challenge artifact.

## 5. Optional legacy Gemini CLI

Antigravity is the preferred Google terminal agent in this workstation. To also install the older Gemini CLI fallback:

```bash
INSTALL_LEGACY_GEMINI=1 ./scripts/install/20-ai-clis.sh
```
