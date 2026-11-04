# Agent Tools: triage, flags and the autosolver

Three helpers turn the model from a chat box into a disciplined solver. They are
installed to `~/.local/bin` by bootstrap and by `scripts/update.sh`.

## ctftriage — automatic first pass

```bash
ctftriage --desc "paste the challenge text" [--url URL] [--nc host:port]
```

Run it at the start of every challenge, from inside the `ctfnew` workspace. It:

- hashes and identifies every file in `input/` (never modifies it),
- measures entropy, extracts strings, unpacks archives and carves embedded data into `work/extracted/`,
- runs type-specific checks (ELF/PE, images, PCAP, PDF, office, text),
- scans everything for flags and common encodings,
- ranks the likely category and suggests the next tests,
- writes `notes/triage.md` (read this first) with full raw output under `artifacts/triage/`.

Many easy challenges are solved here with no model at all.

## ctfflag — find, decode and verify flags

```bash
ctfflag scan [PATH ...]          # scan files/dirs (default: the workspace) for flags
ctfflag decode "<text>"          # peel layered encodings (base64/32/58/85, hex, binary,
                                 # morse, bigint, url, xor, caesar, rot, atbash, ...)
ctfflag verify "<flag>" --cmd "python3 scripts/solve.py"   # format + reproducibility check
ctfflag format "picoCTF"         # set the flag format for this workspace
```

The decoder searches chains of transforms and recovers XOR keys from the known flag
prefix. `verify` accepts a flag only if it matches the format **and** a solver command
reproduces it — this is what stops weaker models reporting made-up flags. Set the format
per workspace with `ctfflag format`, the `CTF_FLAG_REGEX` env var, or `--format`.

## ctfmodel - pick the model ctfsolve uses (open-source via API key)

`ctfsolve` works with any OpenAI-compatible endpoint. `ctfmodel` configures it for
you with ready presets for open-weight model hosts, so you only paste an API key.

```bash
ctfmodel list                       # see providers and default models
ctfmodel use openrouter --key sk-or-...      # one key, huge open-model catalog
ctfmodel use groq --key gsk_...              # very fast Llama/Qwen, free tier
ctfmodel use together "Qwen/Qwen2.5-Coder-32B-Instruct" --key ...
ctfmodel use deepseek --key sk-...           # cheap, strong at code
ctfmodel use ollama qwen2.5-coder            # local, no key (needs a GPU)
ctfmodel key <YOUR_KEY>             # set/replace the key later
ctfmodel show                       # current config (key masked)
ctfmodel test                       # 1-token request to confirm it works
```

Presets (all open-weight hosts unless noted): `openrouter`, `together`, `groq`,
`deepseek`, `fireworks`, `hyperbolic`, `nebius`, `openai` (not open), and local
`ollama` / `vllm` / `lmstudio`, plus `custom` for any other endpoint (`--base URL`).

The choice is saved to `~/.config/ctf-ai/ctfsolve.env` (git-ignored, chmod 600) and
loaded automatically by `ctfsolve` and by a new shell. A stronger planner model is
optional: `ctfmodel use <provider> <model> --planner <bigger-model>`.

Then just:

```bash
ctfmodel test && ctfsolve --desc "challenge text" --nc host:port
```

## ctfsolve — model-agnostic autosolver (optional)

```bash
export CTFSOLVE_API_BASE=https://api.openai.com/v1   # or a local server / proxy
export CTFSOLVE_MODEL=gpt-4o-mini                     # any chat model
# export CTFSOLVE_API_KEY=...                         # if the endpoint needs one
# export CTFSOLVE_PLANNER_MODEL=...                   # stronger model for planning / when stuck
ctfsolve --desc "challenge text" [--url URL] [--nc host:port] [--steps 25]
```

`ctfsolve` runs the plan → act → verify loop itself instead of trusting the model to.
It:

- drives **any** OpenAI-compatible endpoint — hosted (OpenAI, a Claude proxy, DeepSeek)
  or local (Ollama, vLLM, LM Studio, llama.cpp),
- gives the model a small, safe toolset (run_command, read/write_file, triage, decode,
  scan_flags, submit_flag), all scoped to the workspace,
- enforces a step budget, blocks destructive/out-of-scope commands, detects repeated
  actions, and escalates to the planner model when stuck,
- keeps `notes/state.json`, and only reports a flag once `ctfflag verify` passes.

It never submits flags to an external service. Use it only for authorized challenges.
Because the discipline lives in the harness, a cheap model used with a clear category
profile often solves what it could not in a plain chat.

## ctfhub - one menu for everything

`ctfhub` is an interactive terminal control panel. It shows your current model,
MCP profile and challenge workspaces, and runs every tool by number so you don't
have to remember commands. No network port is opened; it just runs the real CLIs
and shows their output, so it works over SSH too.

```bash
ctfhub            # open the menu
ctfhub --status   # one-shot status summary
```

Menu: select/create challenge, triage, scan flags, decode, verify, autosolve,
switch MCP profile, configure model, open notes, health check. It is a front end
over `ctfnew`, `ctftriage`, `ctfflag`, `ctfsolve`, `ctfmodel`, `ctf-mcp` and
`ctfdoctor` - nothing happens that you couldn't run by hand.

## ctfstudio - desktop GUI

`ctfstudio` is the same idea as `ctfhub` in a window, for the Kali desktop
(launch it from the app menu as **CTF Studio**, or run `ctfstudio`).

- **Challenges**: every workspace in `~/ctf`, old and new. `+ New challenge` runs `ctfnew`.
- **Challenge tab**: category, flag format, target URL, `nc` host/port and the
  description. Saved to `.ctf-meta.json` and `notes/description.md`.
- **Files & editor**: add files or folders to `input/` (sha256 logged to
  `notes/input-sha256.txt`), delete, open with the system app, or edit text files
  (solve scripts, notes) in the built-in editor.
- **Prompt**: builds a task prompt from the challenge: authorized-CTF context,
  category, in-scope targets, file list, triage summary and how to verify the flag.
  Edit it freely; it is saved to `notes/prompt.md` and copied to the clipboard on launch.
- **Agents**: launch Codex (`cx`), Claude Code (`cl`), Antigravity (`agy`) or
  `ctfsolve` on the selected challenge, in a terminal window or in the background
  with a log. Lists runs started here (stop, view log) and every
  codex/claude/agy/ctfsolve process on the machine with its challenge.
- **Tools**: triage, flag scan/decode/verify, MCP profile, model show/test, doctor,
  with live output.

`ctfstudio --check` prints what it found (agents, terminal, Tk) without opening a
window. Agent commands and the terminal can be overridden in
`~/.config/ctf-ai/ctfstudio.json`:

```json
{"terminal": "qterminal",
 "agents": {"Antigravity (agy)": {"interactive": ["agy", "{prompt}"]}}}
```
