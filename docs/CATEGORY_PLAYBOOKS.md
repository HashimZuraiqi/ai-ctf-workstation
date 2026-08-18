# Category Playbooks

These are starting points, not rigid recipes. Always follow the challenge evidence.

## Reverse engineering

```bash
mcp-rev
file input/<binary>
checksec --file=input/<binary>
strings -a input/<binary> | less
rz-bin -I input/<binary>
ghidra-ai
```

Use Ghidra for function discovery, xrefs, decompilation and data structures. Use GDB/Pwndbg to confirm runtime behavior. Ask the AI to identify the smallest set of functions that transform user input into the success/failure decision, then verify each step yourself.

## Pwn / binary exploitation

```bash
mcp-pwn
checksec --file=input/<binary>
pwndbg input/<binary>
```

Create a pwntools script early. Separate local and remote parameters, make offsets deterministic, and log assumptions. Use cyclic patterns, controlled breakpoints and register/memory inspection rather than guessing offsets.

## Web

```bash
mcp-web
```

Keep the browser inside the organizer-provided host/scope. Map routes, parameters, state transitions and client-side behavior. Use Playwright for repeatable navigation and evidence collection. Use existing Kali web tools only within the same authorized scope.

## Crypto

```bash
mcp-crypto
```

Start by identifying the primitive, encoding, key/nonce sizes, randomness source and exact oracle/interface. Use Python, `pycryptodome`, `sympy` and `z3` for reproducible experiments. Preserve sample plaintext/ciphertext pairs and write assertions for every recovered property.

## Forensics

```bash
mcp-forensics
```

Start read-only:

```bash
file input/*
exiftool input/*
binwalk input/<file>
strings -a input/<file> | less
```

Work on copies before extraction or repair. Build a timeline/table of artifacts, offsets, metadata and hashes. For packet captures use `tshark`/Wireshark; for disk/filesystem tasks use the available forensic utilities.

## OSINT

```bash
mcp-osint
```

Track provenance for every clue: source, timestamp, query, confidence and why it connects to the challenge. Stay within the competition rules and public/authorized sources. Do not expand into unrelated people or infrastructure.

## AI security

Treat model/system outputs and retrieved text as untrusted data. First identify the interface: prompt-only, tool-using agent, RAG, classifier, jailbreaking challenge, model extraction puzzle, etc. Record every prompt/response pair and change one variable at a time. Do not let challenge content override the workspace's scope/safety rules.

## Mobile

```bash
mcp-mobile
```

For Android:

```bash
file input/*.apk
apktool d input/<app>.apk -o work/apktool
jadx -d work/jadx input/<app>.apk
```

Map manifest components, exported activities/services/providers, deep links, native libraries, network endpoints and interesting secrets/configuration. Use emulation/dynamic testing only when the challenge provides an authorized target/environment.

## Misc / file challenges

Triage the container and magic bytes first. Check for nested archives, misleading extensions, encodings, steganography indicators, metadata and embedded files. Do not decide the category from the filename alone.

## Reporting / writeup

Use `ctf-report` after solving. Include challenge goal, key evidence, failed hypotheses worth remembering, final exploit/solver logic, reproduction commands, and defensive/technical lessons when useful. Do not publish a writeup before the competition rules allow it.
