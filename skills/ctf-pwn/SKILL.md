---
name: ctf-pwn
description: Develop and validate exploits for authorized CTF binary-exploitation challenges.
---

Use for authorized pwn/binary-exploitation challenges.

- Run `checksec` and document architecture, PIE, NX, canary, RELRO and libc assumptions.
- Reproduce the crash/primitive locally first.
- Use Pwndbg/GDB for breakpoints, registers, stack/heap state and backtraces.
- Create a pwntools script early; separate local/remote settings.
- Derive offsets with evidence (for example cyclic patterns), not guesses.
- Make leaks/parsing deterministic and assert expected lengths/ranges.
- Record remote differences and required loader/libc files.
- Stay on the organizer-provided service and do not reuse techniques on unrelated targets.
