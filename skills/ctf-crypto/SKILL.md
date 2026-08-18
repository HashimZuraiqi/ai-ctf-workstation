---
name: ctf-crypto
description: Solve authorized CTF cryptography challenges with reproducible mathematical experiments.
---

Use for CTF cryptography/math/encoding challenges.

- Identify the exact primitive, encoding, parameters, key/nonce sizes and oracle behavior.
- Distinguish encoding/compression from cryptography before attacking assumptions.
- Preserve known plaintext/ciphertext/signature samples.
- Use Python, PyCryptodome, SymPy and Z3 for small reproducible experiments.
- Add assertions to solver code so incorrect assumptions fail loudly.
- Track equations and derivations in notes rather than relying on opaque model reasoning.
- Verify the recovered value by re-encryption/re-signing/replaying the challenge check when possible.
