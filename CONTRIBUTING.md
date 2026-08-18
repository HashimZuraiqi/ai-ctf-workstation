# Contributing

Keep changes reproducible and teammate-friendly.

- Never commit credentials or private competition artifacts.
- Keep installation phases modular and idempotent where possible.
- Do not silently change Kali's global Java; Ghidra is launched with Java 21 through `ghidra-ai`.
- Prefer pinned versions only when reproducibility requires them; document why.
- Test shell syntax with `make test` before pushing.
- Update `docs/VERIFIED_BASELINE.md` after a real end-to-end regression.

Suggested branch names: `docs/...`, `setup/...`, `tooling/...`, `skills/...`.
