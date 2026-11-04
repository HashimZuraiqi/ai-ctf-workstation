---
name: ctf-web
description: Analyse authorized CTF web challenges methodically with evidence capture.
---

Use for authorized web challenges, against the organizer-provided target only.

**Map first:**
- `curl -is` the target: status, headers, cookies, `Server`, CSP, redirects. View source and linked JS.
- Enumerate routes from the app itself (comments, JS, sitemap, robots). Use `mcp-web` / Playwright to drive the app and capture requests.
- Identify the stack (framework, templating, DB) from errors and fingerprints.

**Decision tree by signal:**
- Reflected/stored input -> test XSS and template injection (SSTI: try the framework's expression syntax).
- Query-driven pages -> SQL injection (error-based, boolean, time-based); use sqlmap only within scope.
- Tokens/cookies -> inspect JWT (alg confusion, weak secret), session structure, IDOR by changing IDs.
- File/URL params -> path traversal, LFI, SSRF to internal services.
- Deserialization markers (PHP `O:`, Python pickle, Java `rO0`) -> object-injection analysis.
- Auth flows -> logic flaws, race conditions, password reset weaknesses.

**Capture evidence:** save each request/response pair that changes behaviour. Build a reproducible request (curl or a Python `requests` script) that produces the flag. Keep a provenance log in `notes/analysis.md`.
