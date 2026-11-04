---
name: ctf-reverse
description: Statically and dynamically analyse authorized CTF reverse-engineering targets.
---

Use for authorized reverse-engineering challenges.

**Identify (decision tree):**
- `file` + `rz-bin -I`: ELF/PE/Mach-O? arch? stripped? static vs dynamic? packed (high entropy, UPX)? If packed, unpack first (`upx -d`, or dump from memory).
- .NET or Mono -> ILSpy/dnSpy decompile. Java -> JADX/CFR. Python (pyinstaller/pyc) -> pyinstxtractor + decompyle3/pycdc. Go/Rust -> expect large static binaries; use symbol-recovery scripts.
- Native -> Ghidra (`ghidra-ai`) for decompilation; headless mode for scripted analysis.

**Find the check logic:**
- Locate `main` and any function comparing user input (strcmp/memcmp/custom loop).
- Look for hard-coded secrets, XOR loops, lookup tables, time/anti-debug checks.
- A "serial/license" check is usually a transformation you can invert or brute in Python.

**Confirm with evidence:**
- Reproduce behaviour dynamically in GDB/Pwndbg: breakpoint the comparison, inspect the expected value.
- For symbolic work, angr can solve input constraints; keep the state space small.
- Write a reproducible solver in `scripts/`; assert the recovered value.

Record arch, key functions, and the exact command/offset that revealed the answer in `notes/analysis.md`.
