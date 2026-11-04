# AI CTF Workstation shell helpers.
export PATH="$HOME/.local/bin:$PATH"

unalias cx ag cl ctf pwnenv mcp-rev mcp-pwn mcp-web mcp-forensics mcp-crypto mcp-osint mcp-mobile mcp-all mcp-off mcp-status 2>/dev/null || true

alias cx='codex'
alias ag='agy'
alias cl='claude'
alias ctf='cd "$HOME/ctf"'
alias pwnenv='source "$HOME/.venvs/ctf-core/bin/activate"'

alias mcp-rev='ctf-mcp rev'
alias mcp-pwn='ctf-mcp pwn'
alias mcp-web='ctf-mcp web'
alias mcp-forensics='ctf-mcp forensics'
alias mcp-crypto='ctf-mcp crypto'
alias mcp-osint='ctf-mcp osint'
alias mcp-mobile='ctf-mcp mobile'
alias mcp-all='ctf-mcp all'
alias mcp-off='ctf-mcp off'
alias mcp-status='ctf-mcp status'

# ctfsolve model configuration (managed by `ctfmodel`)
[[ -f "$HOME/.config/ctf-ai/ctfsolve.env" ]] && source "$HOME/.config/ctf-ai/ctfsolve.env"
