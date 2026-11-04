---
name: ctf-pwn
description: Analyse and develop validated solutions for authorized CTF binary-exploitation challenges.
---

Use for authorized binary-exploitation challenges, against the organizer-provided service only.

**Characterise the target:**
- `checksec`: record arch, PIE, NX, canary, RELRO, and the libc version/file provided.
- Identify the input path and the vulnerable primitive class (unbounded copy, format string, off-by-one, UAF/double-free, integer issue). `ctftriage` flags unbounded-input functions during static triage.
- Note any `seccomp` filter (dump with seccomp-tools) and whether a `win`/backdoor function exists.

**Build evidence-first:**
- Reproduce the crash locally before theorising. Use Pwndbg to inspect registers, stack and heap state.
- Derive offsets from evidence (cyclic patterns), not guesses.
- Write a pwntools script early with separate local/remote settings; assert leak lengths and ranges so wrong assumptions fail loudly.
- For heap work, match the exact libc; model allocator behaviour step by step.

**Validate:**
- Confirm the solution works locally, then only against the organizer endpoint.
- Record remote differences and the required loader/libc. Keep the final script reproducible in `exploit/`.

Stay strictly within CTF scope; never reuse techniques on unrelated systems.
