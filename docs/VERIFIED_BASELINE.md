# Verified Baseline

The workstation this repository was derived from was tested end-to-end on a Kali Rolling VM in August 2026.

## Verified environment snapshot

- Kali GNU/Linux Rolling 2026.3, x86-64
- Node.js 24.18.0
- npm/npx 11.16.0
- Codex CLI 0.147.0, authenticated and working
- Google Antigravity CLI 1.1.14, authenticated and working
- Claude Code 2.1.234 installed; authentication intentionally optional
- Legacy Gemini CLI 0.55.1 installed as a fallback, not the primary Google client
- Docker 28.5.2 family, daemon accessible
- Python 3.12 managed by `uv`
- Official Ghidra 12.1.2
- Java 21 specifically for Ghidra/Ghidra MCP

## Python environment imports verified

- pwntools
- z3-solver
- pycryptodome
- sympy
- capstone
- unicorn
- keystone-engine
- lief
- ropper
- ROPGadget
- requests
- BeautifulSoup
- lxml
- Pillow
- IPython
- angr

## Native tools verified

- GDB / GDB multiarch
- Pwndbg
- patchelf
- strace / ltrace
- checksec
- Rizin / rz-bin
- Cutter
- QEMU user emulation for common architectures
- JADX / apktool
- common Kali web/forensics tools already present in the distribution

## MCP tests that passed

### Ghidra MCP

The AI client successfully read a test ELF open in Ghidra, including architecture/base/entry/function information. The local plugin endpoint responded on `127.0.0.1:8089` and strict program selectors were enabled.

### GDB MCP

A small `gcc -g -O0 -no-pie` test program was loaded, a breakpoint at `main` was hit, registers/backtrace were inspected, output `result=42` was observed, and the session terminated cleanly.

### Playwright MCP

The AI client navigated to `https://example.com`, read the page title and main heading, extracted the `Learn more` link target, and closed the browser session.

## Version policy in this repo

Kali Rolling and AI CLIs update frequently, so the bootstrap installs current packages/releases. Ghidra 12.1.2 is intentionally pinned because that was the tested Ghidra MCP target and requires Java 21. Run `ctfdoctor` after updates and refresh this document only after an end-to-end regression.

## Extended category layers also completed during setup

After the core workstation tests, we expanded the same VM with category-specific tooling.

### Forensics

The live inventory included ExifTool, Binwalk, YARA, Sleuth Kit utilities, PDF/OLE tooling, tshark, stego utilities, Volatility 3 and Plaso command variants. The custom Forensics MCP inventory test reported the requested forensic tools available.

### Crypto

The live core check covered OpenSSL, John, Hashcat, hash identification tools, PARI/GP, ccrypt, AES helpers, stegsnow, xortool and RsaCtfTool. The Python environment was expanded with number-theory/crypto packages, and SageMath was installed in an isolated Miniforge environment. A custom Crypto MCP was then created for structured access to this layer.

### OSINT

The live OSINT layer included DNS/WHOIS tools, amass/subfinder/assetfinder, theHarvester, Sherlock, Maigret, recon-ng/SpiderFoot-class tools, web/archive helpers and ExifTool. The custom OSINT MCP inventory/domain tests worked. Some public-data tools can legitimately time out depending on providers/network conditions, so availability and result retrieval are reported separately.

These custom category MCP implementations in this repository are cleaned-up, shareable versions of the local servers created during that setup.
