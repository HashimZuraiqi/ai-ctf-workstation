---
name: ctf-misc
description: Triage unusual authorized CTF file and puzzle challenges without assuming the category too early.
---

Use for misc/file/puzzle challenges that do not yet fit another category.

- Inspect magic bytes and actual file type instead of trusting extensions.
- Check metadata, nested containers, compression, encodings and embedded files.
- Keep a transformation log so every decode/extraction step can be reversed/reproduced.
- Avoid executing embedded content unless the challenge requires it and the environment is isolated.
- Reclassify into reverse/crypto/forensics/etc. once evidence supports it, then switch skills.
