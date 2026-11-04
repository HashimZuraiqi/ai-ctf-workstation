---
name: ctf-mobile
description: Analyse authorized CTF mobile (APK/IPA) challenges.
---

Use for authorized mobile challenges.

**Android (APK):**
- Unpack: `apktool d` (resources/smali), `jadx -d` (Java source). Read `AndroidManifest.xml` for components, permissions, exported activities, and the main entry.
- Look for hard-coded secrets in strings.xml, resources, assets/, and the code; check for native `.so` libraries (analyse in Ghidra).
- Inspect custom crypto, API endpoints, certificate pinning, and any local check logic you can invert.
- Dynamic (if in scope): run in an emulator, use Frida to hook methods and observe/patch behaviour.

**iOS (IPA):** unzip, inspect the Mach-O (`rz-bin`, Ghidra), Info.plist, embedded resources and strings; look for hard-coded keys and endpoints.

Reproduce the check in a small script where possible and record the exact file/method that held the answer. Use the `mcp-mobile` profile (Ghidra + GDB).
