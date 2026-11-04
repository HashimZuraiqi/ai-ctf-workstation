---
name: ctf-osint
description: Conduct authorized, passive-first OSINT for CTF challenges with provenance.
---

Use only for organizer-approved CTF OSINT targets and public sources permitted by the rules.

**Principles:** passive first; stay within the stated scope; record provenance (source URL + timestamp) for every finding in a table in `notes/analysis.md`. Do not touch unrelated people, accounts, or infrastructure.

**Starting points by clue:**
- **Image:** full EXIF (exiftool) - GPS, device, timestamps, software; reverse image search; landmark/sign/language geolocation; shadow and signage analysis.
- **Username/handle:** Sherlock / Maigret across platforms; pivot to linked accounts, bios, old posts.
- **Domain/host:** `osint_domain_snapshot` (passive WHOIS/DNS); certificate transparency (crt.sh); subdomains (subfinder/amass passive mode); Wayback Machine for historical pages.
- **Person/org:** theHarvester for emails/subdomains; public records; social graph; metadata in published documents (metagoofil).
- **File:** document metadata, embedded author/revision data.

Use the `mcp-osint` profile; the team OSINT MCP blocks active/brute-force flags by design. Verify each claim against a second source before relying on it.
