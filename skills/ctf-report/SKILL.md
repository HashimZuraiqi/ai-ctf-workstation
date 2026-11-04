---
name: ctf-report
description: Record and summarise an authorized CTF solve so it is reproducible and reusable.
---

Use when a challenge is solved or handed off.

Produce a short writeup in `notes/analysis.md` (and, if the team keeps one, append to the shared writeup store) with:

1. **Challenge:** name, category, points, organizer endpoint.
2. **Summary:** the vulnerability/technique in 1-2 sentences.
3. **Steps:** the exact reproducible path from `input/` to flag - commands, scripts, offsets, parameters.
4. **Flag:** the verified flag and how it was verified (`ctfflag verify ... --cmd ...`).
5. **Artifacts:** paths to the solver in `scripts/`/`exploit/`.
6. **Reusable technique:** one line naming the technique and key indicator, so it can be found again for a future challenge.

Keep it factual and reproducible. Do not include credentials or organizer-private material in anything shared outside the team.
