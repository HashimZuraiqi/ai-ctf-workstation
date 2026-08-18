# Shared AI Skills

The repo installs the same skill content into the supported user-skill layouts:

```text
Codex:        ~/.agents/skills/<skill>/SKILL.md
Claude:       ~/.claude/skills/<skill>/SKILL.md
Antigravity:  ~/.gemini/antigravity-cli/skills/<skill>/SKILL.md
```

Skills included:

- `ctf-triage`
- `ctf-reverse`
- `ctf-pwn`
- `ctf-web`
- `ctf-crypto`
- `ctf-forensics`
- `ctf-osint`
- `ctf-ai-security`
- `ctf-mobile`
- `ctf-misc`
- `ctf-report`

The skill files live in this repository under `skills/`, so the team can review and version them like normal source code.

Antigravity's skill layout is **directory based**. Do not install flat files such as:

```text
~/.gemini/antigravity-cli/skills/ctf-reverse.md
```

Use:

```text
~/.gemini/antigravity-cli/skills/ctf-reverse/SKILL.md
```

After changing skills, restart the AI client or use its skill-management UI/command to refresh discovery.
