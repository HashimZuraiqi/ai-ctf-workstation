# Troubleshooting

## Kali APT returns many `404 Not Found` errors

This commonly happens on Kali Rolling when package indexes reference versions that have already rolled off the mirror.

First run the included repair helper:

```bash
./scripts/repair-kali-apt.sh
```

It restores the standard Kali Rolling Deb822 source, clears stale package lists, refreshes metadata, configures unfinished packages and repairs broken dependencies.

A full rolling upgrade is intentionally separate because it can be large:

```bash
sudo apt full-upgrade -y
sudo reboot
```

After reboot:

```bash
sudo dpkg --audit
apt list --upgradable
```

## `npm` or `codex` is not found

```bash
node --version
npm --version
npm config get prefix
printf '%s\n' "$PATH" | tr ':' '\n' | grep "$HOME/.local/bin"
```

Expected npm prefix for this workstation:

```text
~/.local
```

Reload the shell:

```bash
exec zsh
```

Reinstall Codex if needed:

```bash
npm install -g @openai/codex
```

## Ghidra MCP build says `release version 21 not supported`

Kali may have a newer default Java runtime while Maven/javac selection is inconsistent. Build and run this integration specifically with Java 21:

```bash
export JAVA_HOME=/usr/lib/jvm/java-21-openjdk-amd64
export PATH="$JAVA_HOME/bin:$PATH"
hash -r
java -version
javac -version
```

Then rerun the Ghidra MCP build/deploy phase:

```bash
./scripts/install/50-ghidra-mcp.sh
```

Do not globally replace Kali's Java just to satisfy Ghidra.

## Ghidra MCP cannot see a program

Check:

1. You launched `ghidra-ai`, not a different Ghidra install.
2. A project is open and a program is loaded in CodeBrowser.
3. GhidraMCP plugin is enabled.
4. Its local server is started.
5. Health endpoint works:

```bash
curl -s http://127.0.0.1:8089/get_version | jq
```

6. `mcp-status` shows Ghidra enabled for your AI client.

Strict routing is intentional: requests should name the program.

## Antigravity shows only built-in skills

The global skill layout must be:

```text
~/.gemini/antigravity-cli/skills/<skill>/SKILL.md
```

Repair all workstation skills with:

```bash
./scripts/install/70-skills.sh
```

Then restart `agy` and inspect `/skills` inside the TUI.

## `playwright-cli open` asks for branded Chrome or fails dependency detection on Kali

Use the repo's Chromium configuration rather than the branded Chrome channel:

```bash
mkdir -p .playwright
cp ~/.config/ctf-ai/playwright-cli.json .playwright/cli.config.json
playwright-cli open https://example.com
```

If the browser payload is absent:

```bash
npx playwright install chromium
```

The distro dependency helper may not recognize Kali; the workstation installs the common runtime libraries through APT and uses Playwright-managed Chromium.

## Docker command works but daemon access is denied

```bash
sudo usermod -aG docker "$USER"
newgrp docker
```

Then verify:

```bash
docker version
```

Log out/in if the group change is not picked up.

## `ctf-mcp forensics|crypto|osint` points to a missing custom server

Reinstall the custom category servers:

```bash
./scripts/install/55-category-mcps.sh
ctf-mcp all
mcp-status
```

Each server should have:

```text
~/tools/ctf-forensics-mcp/.venv/bin/python
~/tools/ctf-crypto-mcp/.venv/bin/python
~/tools/ctf-osint-mcp/.venv/bin/python
```

## Sage takes a long time or too much disk

Sage is deliberately isolated through Miniforge and is a large component. To build the rest of the workstation without it:

```bash
CTF_SKIP_SAGE=1 ./scripts/bootstrap.sh
```

Later, install only the crypto phase without that variable when you have enough time/disk:

```bash
./scripts/install/36-crypto.sh
```

## An OSINT tool is installed but times out

That does not necessarily mean the installation is broken. Public OSINT sources can throttle, block automation, change endpoints, or simply respond slowly. First verify the executable is present with `ctfdoctor`, then test a lightweight organizer-approved query. Keep the custom OSINT MCP passive-oriented; do not add brute-force/active flags just to force a result.
