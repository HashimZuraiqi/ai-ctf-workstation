# Team Workflow

## One workstation repo, separate challenge repos/branches

Keep this repo focused on environment/tooling. For actual competitions, use either a separate private team repository or one private repo per event.

Recommended challenge structure is always generated with `ctfnew` so everyone sees the same layout.

## What teammates should commit

Good to commit when competition rules permit:

- `notes/analysis.md`
- solver/exploit scripts
- helper scripts
- small generated data needed to reproduce the solve
- sanitized screenshots or diagrams

Do not commit:

- AI/API credentials
- auth/browser profiles
- core dumps unless explicitly needed
- huge extracted tool directories
- organizer-provided files when redistribution is prohibited
- flags/writeups before disclosure rules permit it

## Handoff checklist

When handing a challenge to another teammate, include:

1. current hypothesis
2. strongest evidence
3. commands already tried
4. exact failure/blocker
5. any local/remote differences
6. which MCP profile was used
7. how to reproduce the latest state

The running evidence log in `notes/analysis.md` should make the handoff possible without a voice call.

## Keep solves reproducible

Prefer:

```bash
python scripts/solve.py
```

or:

```bash
python exploit/exploit.py LOCAL=1
python exploit/exploit.py HOST=<ctf-host> PORT=<ctf-port>
```

over undocumented manual sequences.

## New teammate onboarding checklist

A teammate should be competition-ready after this sequence:

```bash
git clone <team-repo-url>
cd ai-ctf-workstation
./scripts/bootstrap.sh
exec zsh
codex --login
agy
ctfdoctor
mcp-status
ctfnew onboarding-test misc
```

Then they should read, in order:

1. `README.md`
2. `docs/USAGE.md`
3. `docs/CATEGORY_PLAYBOOKS.md`
4. `docs/MCP.md`
5. `SECURITY.md`

If `ctfdoctor` has only warnings for tools the team intentionally skipped, record those differences in the team chat before the event rather than discovering them mid-challenge.
