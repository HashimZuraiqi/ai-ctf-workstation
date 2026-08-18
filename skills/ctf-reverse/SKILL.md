---
name: ctf-reverse
description: Analyze an authorized CTF binary with static and dynamic reverse-engineering workflows.
---

Use for authorized reverse-engineering challenges.

- Preserve the original binary and work on copies.
- Start with `file`, `checksec`, strings, headers/imports/sections and `rz-bin`.
- In Ghidra, identify entry points, success/failure paths, interesting xrefs, data tables and input transformations.
- If Ghidra MCP is enabled, explicitly identify the target program for program-scoped calls.
- Use GDB/Pwndbg to confirm runtime behavior rather than trusting decompiler output alone.
- Translate important logic into small Python tests/solvers with assertions.
- Keep a map of function/address -> role -> evidence in the analysis notes.
- Do not claim a flag until the acceptance path is reproduced.
