---
name: ctf-crypto
description: Solve authorized CTF cryptography challenges with reproducible experiments.
---

Use for cryptography/math/encoding challenges.

**Classify before attacking:**
- Separate encoding/compression (base64/32/85, hex, URL, zlib) from real cryptography. Run `ctfflag decode "<text>"` to peel encoding layers automatically.
- Identify the exact primitive, parameters, key/nonce sizes, and any oracle behaviour. Preserve all known plaintext/ciphertext/signature samples.

**RSA checklist:** small e / cube root; e=1; N factorable (factordb, Fermat for close primes, Pollard); shared/duplicate primes across keys (GCD); common modulus; Wiener (small d); Hastad broadcast; partial-key / Coppersmith. RsaCtfTool automates many of these.

**Symmetric:** ECB (identical blocks -> cut-and-paste, byte-at-a-time decryption); CBC bit-flipping and padding-oracle; CTR/stream nonce reuse (keystream recovery by XOR); known-plaintext.

**Classical/other:** substitution/Vigenere (frequency analysis, quipqiup); XOR (single/multi-byte, crib-dragging); weak PRNG/LCG state recovery; ECC with small or known parameters; hash length-extension (hashpump).

**Work reproducibly:** use PyCryptodome/SymPy/Z3/Sage for small scripted experiments in `scripts/`. Add assertions so bad assumptions fail. Verify by re-encrypting/re-signing or replaying the challenge check.
