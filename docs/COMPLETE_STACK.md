# Complete Workstation Stack

This file is the inventory of what the repository attempts to reproduce from the workstation we built together.

## AI clients

- OpenAI Codex CLI
- Google Antigravity CLI (`agy`)
- Claude Code CLI (authentication optional)
- Legacy Gemini CLI only when `INSTALL_LEGACY_GEMINI=1`

No credentials, cookies, OAuth state or API keys are stored in this repository.

## Shared Python environment

Location: `~/.venvs/ctf-core`

Core packages include pwntools, angr, Z3, PyCryptodome, SymPy, Capstone, Unicorn, Keystone, LIEF, Ropper, ROPGadget, Requests, BeautifulSoup, lxml, Pillow and IPython.

Crypto additions include GMPY2, fpylll, cysignals, ECDSA, cryptography, pyasn1, base58 and bitarray.

## Reverse engineering / pwn

- GDB / GDB multiarch / gdbserver
- Pwndbg
- checksec, patchelf, strace, ltrace
- Rizin / rz-bin / Cutter
- QEMU user emulation
- JADX + apktool
- Official Ghidra 12.1.2 pinned under `~/tools/ghidra_12.1.2_PUBLIC`
- Java 21 used only for the pinned Ghidra/MCP launcher
- Ghidra MCP
- GDB MCP

## Browser / web

- Playwright CLI
- Playwright MCP
- Playwright-managed Chromium
- Burp Suite and common Kali web tooling when available
- nmap, ffuf, gobuster, feroxbuster, whatweb, sqlmap, nuclei, amass

## Forensics

The extended phase tries to install the tools we checked during setup, using Kali packages when available:

- file, strings, xxd, ExifTool, Binwalk
- Foremost, Scalpel, bulk_extractor
- YARA
- Sleuth Kit: mmls, fls, icat, fsstat, istat, mactime, tsk_recover
- TestDisk / PhotoRec
- hashdeep / ssdeep
- EWF/xmount and filesystem recovery helpers
- pdfid / pdf-parser
- oletools: oleid, olevba, oleobj, rtfobj
- tshark / Wireshark / tcpflow
- steghide / stegseek / zsteg / pngcheck / zbarimg
- Volatility 3 (`vol`)
- Plaso tools (`plaso-log2timeline`, `plaso-pinfo`, `plaso-psort`)
- the custom `ctf-forensics-mcp` server

Kali Rolling package names can change; the installer reports unavailable packages rather than inventing replacements.

## Crypto

- OpenSSL, John, Hashcat
- hashid, Name-That-Hash (`nth` when exposed by the package), hash-identifier
- PARI/GP
- ccrypt, aesfix, aeskeyfind, stegsnow
- xortool
- RsaCtfTool in its own Python environment
- SageMath in an isolated Miniforge environment, exposed as `~/.local/bin/sage`
- the custom `ctf-crypto-mcp` server

Sage is large. Set `CTF_SKIP_SAGE=1` before bootstrap only if the teammate intentionally wants a lighter install.

## OSINT

The OSINT phase attempts to install the toolkit used during our setup, subject to current Kali package availability:

- whois, dig/host/nslookup
- dnsrecon, dnsenum, massdns
- amass, subfinder, assetfinder
- theHarvester
- Sherlock, Maigret
- SpiderFoot / recon-ng
- metagoofil
- waybackpy
- instaloader
- Photon
- ExifTool
- Playwright browser tooling
- the custom `ctf-osint-mcp` server

## Skills

Eleven shared workflows are installed into Codex, Claude and Antigravity skill layouts:

1. ctf-triage
2. ctf-reverse
3. ctf-pwn
4. ctf-web
5. ctf-crypto
6. ctf-forensics
7. ctf-osint
8. ctf-ai-security
9. ctf-mobile
10. ctf-misc
11. ctf-report

## Helpers

- `ctfnew` — create a clean challenge workspace
- `ctf-mcp` — MCP profile manager
- `ctfdoctor` — health checker
- `ghidra-ai` — launch the pinned Ghidra with Java 21
- shell aliases `cx`, `ag`, `cl`, `ctf`, `pwnenv`, and the MCP profile aliases
