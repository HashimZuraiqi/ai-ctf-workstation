# Publish to GitHub

The downloadable package is already a normal repository layout. It intentionally contains **no team credentials or provider login state**.

## Easiest method: GitHub CLI

Install/authenticate GitHub CLI on the one machine that will publish the workstation:

```bash
sudo apt update
sudo apt install -y gh
gh auth login
```

Then from the repo root:

```bash
./scripts/publish-github.sh YOUR-ORG/ai-ctf-workstation private
```

Use `public` only if your team intentionally wants the tooling repository public. Keep competition challenge data in a separate repository if organizer rules restrict redistribution.

## Manual Git method

Create an empty GitHub repository in the browser, then:

```bash
git init -b main
git add .
git commit -m "Initial AI CTF workstation"
git remote add origin https://github.com/YOUR-ORG/ai-ctf-workstation.git
git push -u origin main
```

## Teammate installation after publishing

```bash
git clone https://github.com/YOUR-ORG/ai-ctf-workstation.git
cd ai-ctf-workstation
./scripts/bootstrap.sh
exec zsh
ctfdoctor
```

Each teammate then authenticates their own Codex/Antigravity/Claude account. Never copy your local auth directories into the repo.
