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
