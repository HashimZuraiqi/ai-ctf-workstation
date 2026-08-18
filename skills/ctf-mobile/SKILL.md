---
name: ctf-mobile
description: Analyze authorized mobile CTF applications with static-first Android workflows.
---

Use for authorized mobile CTF challenges.

- Hash/preserve the original APK/IPA and extract only into `work/`.
- For Android, inspect manifest/components with Apktool and source/decompiled code with JADX.
- Map exported components, intent/deep-link surfaces, network endpoints, native libraries and local storage/configuration.
- Search for validation logic and success conditions before dynamic testing.
- Use emulators/devices only as allowed by the challenge and never personal production accounts.
- Verify interesting code paths with a minimal reproducible test.
