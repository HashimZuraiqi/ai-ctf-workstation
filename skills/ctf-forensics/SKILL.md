---
name: ctf-forensics
description: Recover hidden data from authorized CTF forensics artifacts with evidence tracking.
---

Use for forensics challenges (files, images, captures, memory, disk).

**Always:** `file`, `strings`, `exiftool`, `binwalk` on every artifact; check entropy and data appended after a file's logical end. `ctftriage` does this first pass automatically.

**By artifact type:**
- **Images (stego):** zsteg (PNG/BMP LSB), steghide/stegseek (JPG, try empty + wordlist passwords), compare colour planes, inspect for appended archives, zbarimg for QR/barcodes, check palette and least-significant bits.
- **Audio:** spectrogram (Sonic Visualiser / `sox` spectrogram), DTMF, Morse, LSB in samples, slowed/reversed playback.
- **PCAP/network:** `tshark -z io,phs` for protocol mix, follow TCP/HTTP streams, export objects, reassemble files, check DNS/ICMP for exfil, decode USB/HID keystrokes.
- **Memory dumps:** Volatility 3 - pslist/pstree, cmdline, netscan, filescan + dumpfiles, hashdump, look for injected regions.
- **Disk images:** Sleuth Kit (mmls, fls, icat, tsk_recover), carve deleted files (photorec/foremost), build a timeline (plaso/mactime).
- **Office/PDF:** oletools (olevba, oleobj), pdfid/pdf-parser for embedded JS/objects/files.

Record every command and what it revealed; carve into `work/extracted/` and re-run `ctftriage` on anything recovered.
