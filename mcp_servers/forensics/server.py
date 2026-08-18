#!/usr/bin/env python3
"""CTF Forensics MCP: local, allowlisted wrappers for common forensic tools.

All file paths are restricted to ~/ctf by default. This server is intended for
challenge artifacts you are authorized to inspect.
"""
from __future__ import annotations

import os
import shlex
import shutil
import subprocess
from pathlib import Path
from typing import Any

from mcp.server.fastmcp import FastMCP

mcp = FastMCP("ctf-forensics")
ROOT = Path(os.environ.get("CTF_ROOT", str(Path.home() / "ctf"))).expanduser().resolve()
MAX_OUTPUT = int(os.environ.get("CTF_MCP_MAX_OUTPUT", "40000"))

TOOLS = {
    "file": ["file"], "strings": ["strings"], "xxd": ["xxd"],
    "exiftool": ["exiftool"], "binwalk": ["binwalk"], "foremost": ["foremost"],
    "scalpel": ["scalpel"], "bulk_extractor": ["bulk_extractor"], "yara": ["yara"],
    "mmls": ["mmls"], "fls": ["fls"], "icat": ["icat"], "fsstat": ["fsstat"],
    "istat": ["istat"], "mactime": ["mactime"], "tsk_recover": ["tsk_recover"],
    "testdisk": ["testdisk"], "photorec": ["photorec"], "hashdeep": ["hashdeep"],
    "ssdeep": ["ssdeep"], "ewfinfo": ["ewfinfo"], "xmount": ["xmount"],
    "ext4magic": ["ext4magic"], "extundelete": ["extundelete"],
    "recoverjpeg": ["recoverjpeg"], "magicrescue": ["magicrescue"],
    "pdfid": ["pdfid"], "pdf-parser": ["pdf-parser"], "oleid": ["oleid"],
    "olevba": ["olevba"], "oleobj": ["oleobj"], "rtfobj": ["rtfobj"],
    "tshark": ["tshark"], "tcpflow": ["tcpflow"], "steghide": ["steghide"],
    "stegseek": ["stegseek"], "zsteg": ["zsteg"], "pngcheck": ["pngcheck"],
    "zbarimg": ["zbarimg"], "dumpzilla": ["dumpzilla"],
    "grokevt-parselog": ["grokevt-parselog"], "vol": ["vol"],
    "plaso-log2timeline": ["plaso-log2timeline"], "plaso-pinfo": ["plaso-pinfo"],
    "plaso-psort": ["plaso-psort"],
}


def _inside_root(value: str) -> Path:
    p = Path(value).expanduser()
    if not p.is_absolute():
        p = ROOT / p
    p = p.resolve(strict=False)
    if p != ROOT and ROOT not in p.parents:
        raise ValueError(f"Path is outside CTF_ROOT ({ROOT}): {p}")
    return p


def _safe_arg(arg: str) -> str:
    # Convert existing or path-looking arguments to root-checked absolute paths.
    if arg.startswith(("/", "~", "./", "../")):
        return str(_inside_root(arg))
    return arg


def _run(argv: list[str], timeout: int = 60) -> dict[str, Any]:
    try:
        cp = subprocess.run(argv, cwd=ROOT, text=True, capture_output=True, timeout=timeout, env=os.environ.copy())
        out = (cp.stdout or "") + (("\n[stderr]\n" + cp.stderr) if cp.stderr else "")
        return {"argv": argv, "exit_code": cp.returncode, "output": out[:MAX_OUTPUT], "truncated": len(out) > MAX_OUTPUT}
    except subprocess.TimeoutExpired as e:
        return {"argv": argv, "timeout": True, "output": ((e.stdout or "") if isinstance(e.stdout, str) else "")[:MAX_OUTPUT]}


@mcp.tool()
def forensics_inventory() -> dict[str, Any]:
    """Report which allowlisted forensic tools are currently available."""
    return {"ctf_root": str(ROOT), "tools": {name: shutil.which(cmd[0]) for name, cmd in TOOLS.items()}}


@mcp.tool()
def forensics_list_files(relative_dir: str = ".", max_entries: int = 300) -> list[dict[str, Any]]:
    """List files/directories under the authorized CTF workspace."""
    base = _inside_root(relative_dir)
    if not base.exists():
        raise FileNotFoundError(base)
    rows=[]
    for p in sorted(base.iterdir(), key=lambda x: x.name)[:max_entries]:
        st=p.stat()
        rows.append({"name": p.name, "path": str(p), "type": "dir" if p.is_dir() else "file", "size": st.st_size})
    return rows


@mcp.tool()
def forensics_file_info(path: str) -> dict[str, Any]:
    """Return basic metadata and file(1) identification for a workspace file."""
    p = _inside_root(path)
    st=p.stat()
    ident=_run(["file", "-b", str(p)], timeout=10)
    return {"path": str(p), "size": st.st_size, "mode": oct(st.st_mode & 0o777), "file": ident.get("output", "").strip()}


@mcp.tool()
def forensics_run(tool: str, args: list[str] | None = None, timeout: int = 60) -> dict[str, Any]:
    """Run one allowlisted forensic CLI. File arguments must remain under CTF_ROOT."""
    if tool not in TOOLS:
        raise ValueError(f"Tool not allowlisted: {tool}")
    if shutil.which(TOOLS[tool][0]) is None:
        raise FileNotFoundError(f"Tool not installed: {TOOLS[tool][0]}")
    cleaned=[_safe_arg(str(a)) for a in (args or [])]
    return _run(TOOLS[tool] + cleaned, min(max(timeout, 1), 300))


if __name__ == "__main__":
    ROOT.mkdir(parents=True, exist_ok=True)
    mcp.run()
