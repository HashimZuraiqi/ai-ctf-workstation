# MCP Architecture and Profiles

MCP integrations are kept **profile-based** instead of leaving every powerful tool connected all the time. `ctf-mcp` updates both Codex and Antigravity so teammates get the same active toolset.

## Core MCP integrations

### Ghidra MCP

```text
AI client <-> MCP bridge (stdio) <-> local GhidraMCP plugin on 127.0.0.1:8089
```

The bridge is launched from `~/tools/ghidra-mcp` through `uv` and sets:

```text
GHIDRA_MCP_REQUIRE_PROGRAM_SELECTORS=1
```

This forces program-scoped calls to identify the intended open Ghidra program instead of silently using whichever GUI tab is current.

Launch the tested Ghidra distribution with:

```bash
ghidra-ai
```

### GDB MCP

Registered through:

```bash
npx -y mcp-gdb
```

Use it for controlled debugger sessions: breakpoints, stepping, registers, memory, variables and backtraces. Native GDB/Pwndbg remains available independently.

### Playwright MCP

Generated config:

```text
~/.config/ctf-ai/playwright-mcp.json
```

It uses Playwright-managed Chromium with isolated state and stores artifacts under `~/ctf/browser-artifacts`.

## Category MCP integrations we built

The repository also installs three small team-owned MCP servers. They live in the repo under `mcp_servers/` and are copied to `~/tools/` during bootstrap.

### Forensics MCP

Installed at:

```text
~/tools/ctf-forensics-mcp
```

It provides structured inventory, workspace file inspection, and an allowlisted interface to tools such as ExifTool, Binwalk, YARA, Sleuth Kit, PDF/OLE utilities, tshark, stego tools, Volatility and Plaso. File-oriented paths are restricted to `~/ctf` by default.

### Crypto MCP

Installed at:

```text
~/tools/ctf-crypto-mcp
```

It exposes an allowlisted crypto/math CLI inventory plus challenge-scoped Python and Sage solver-script execution. It is designed to work with the shared `~/.venvs/ctf-core` environment and isolated Sage installation.

### OSINT MCP

Installed at:

```text
~/tools/ctf-osint-mcp
```

It exposes an allowlisted set of OSINT commands plus a passive DNS/WHOIS domain snapshot. The team server blocks several explicit active/brute-force flags. Use it only for organizer-approved CTF targets and public sources permitted by the challenge rules.

## Profiles

```bash
ctf-mcp rev
ctf-mcp pwn
ctf-mcp web
ctf-mcp forensics
ctf-mcp crypto
ctf-mcp osint
ctf-mcp mobile
ctf-mcp all
ctf-mcp off
ctf-mcp status
```

Short aliases:

```bash
mcp-rev
mcp-pwn
mcp-web
mcp-forensics
mcp-crypto
mcp-osint
mcp-mobile
mcp-all
mcp-off
mcp-status
```

| Profile | Ghidra | GDB | Playwright | Forensics | Crypto | OSINT |
|---|---:|---:|---:|---:|---:|---:|
| `rev` | on | on | off | off | off | off |
| `pwn` | on | on | off | off | off | off |
| `web` | off | off | on | off | off | off |
| `forensics` | off | off | off | on | off | off |
| `crypto` | off | off | off | off | on | off |
| `osint` | off | off | on | off | off | on |
| `mobile` | on | on | off | off | off | off |
| `all` | on | on | on | on | on | on |
| `off` | off | off | off | off | off | off |

For Codex, profiles add/remove MCP server registrations. For Antigravity, the helper preserves its JSON and toggles the workstation servers with `disabled`.

## Why profiles matter

MCP servers can execute local tools and can expand the amount of context/actions available to an agent. Enable only what the current challenge needs, keep challenge data under `~/ctf`, inspect tool calls, and use `mcp-off` when finished.

## Verification

```bash
mcp-status
```

With Ghidra open and its plugin server started:

```bash
curl -s http://127.0.0.1:8089/get_version | jq
```
