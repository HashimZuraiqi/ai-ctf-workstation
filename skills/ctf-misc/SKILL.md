---
name: ctf-misc
description: Work through authorized CTF misc/uncategorised challenges.
---

Use for misc/uncategorised challenges.

- Start with `ctftriage`; misc challenges often hide a known category (encoding, stego, simple rev).
- **Jails (pyjail/bashjail):** map the blocklist, find allowed builtins/characters, reconstruct capabilities (e.g. via available attributes), escape to read the flag file. Keep payloads minimal and documented.
- **Esolangs:** identify the language (Brainfuck, Ook, Malbolge, Piet, Whitespace) and use an interpreter.
- **QR/barcodes:** zbarimg; repair damaged codes if needed.
- **Encodings/ciphers:** `ctfflag decode`; CyberChef-style layered decoding.
- **Programming/PPC:** a server that demands fast automated answers - script the interaction with pwntools/requests and automate the solve loop.
- **Game/logic:** script the optimal strategy rather than playing by hand.

Always verify the recovered flag with `ctfflag verify`, and record the reproducible steps.
