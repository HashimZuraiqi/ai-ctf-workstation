# Reproduction Status

The goal of this repo is to preserve the workstation we actually built, while being clear about which areas received dedicated MCP integrations.

| Category | Native/tooling setup | Shared skill | Dedicated MCP path |
|---|---|---|---|
| Reverse | yes | yes | Ghidra + GDB |
| Pwn | yes | yes | Ghidra + GDB |
| Web | yes | yes | Playwright |
| Forensics | yes | yes | custom Forensics MCP |
| Crypto | yes | yes | custom Crypto MCP |
| OSINT | yes | yes | custom OSINT MCP + Playwright |
| Mobile | baseline JADX/apktool/rev tools | yes | uses Ghidra/GDB profile; no separate mobile MCP was built |
| AI Security | general Python/browser foundation | yes | no dedicated AI-security MCP was built yet |
| Misc/file | triage + general file/forensics tools | yes | no separate misc MCP was built |
| Reporting | notes/template workflow | yes | not needed |

This distinction is intentional: the repo should not pretend that we completed integrations that were not actually built/tested during the workstation session.
