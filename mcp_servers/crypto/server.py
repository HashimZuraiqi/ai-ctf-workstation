#!/usr/bin/env python3
"""CTF Crypto MCP: controlled access to crypto/math tools and scripts under ~/ctf."""
from __future__ import annotations

import os
import shutil
import subprocess
from pathlib import Path
from typing import Any

from mcp.server.fastmcp import FastMCP

mcp = FastMCP("ctf-crypto")
ROOT = Path(os.environ.get("CTF_ROOT", str(Path.home() / "ctf"))).expanduser().resolve()
VENV_PY = Path(os.environ.get("CTF_PYTHON", str(Path.home() / ".venvs/ctf-core/bin/python"))).expanduser()
SAGE = os.environ.get("CTF_SAGE", str(Path.home() / ".local/bin/sage"))
MAX_OUTPUT = int(os.environ.get("CTF_MCP_MAX_OUTPUT", "40000"))

TOOLS = {
    "openssl": ["openssl"], "john": ["john"], "hashcat": ["hashcat"],
    "hashid": ["hashid"], "nth": ["nth"], "hash-identifier": ["hash-identifier"],
    "gp": ["gp"], "ccrypt": ["ccrypt"], "aesfix": ["aesfix"],
    "aeskeyfind": ["aeskeyfind"], "stegsnow": ["stegsnow"], "xortool": ["xortool"],
    "RsaCtfTool": ["RsaCtfTool"], "sage": [SAGE],
}


def _inside_root(value: str) -> Path:
    p=Path(value).expanduser()
    if not p.is_absolute(): p=ROOT/p
    p=p.resolve(strict=False)
    if p != ROOT and ROOT not in p.parents:
        raise ValueError(f"Path is outside CTF_ROOT ({ROOT}): {p}")
    return p


def _safe_arg(arg: str) -> str:
    if arg.startswith(("/", "~", "./", "../")):
        return str(_inside_root(arg))
    return arg


def _run(argv: list[str], timeout: int = 60) -> dict[str, Any]:
    try:
        cp=subprocess.run(argv,cwd=ROOT,text=True,capture_output=True,timeout=timeout,env=os.environ.copy())
        out=(cp.stdout or "") + (("\n[stderr]\n"+cp.stderr) if cp.stderr else "")
        return {"argv":argv,"exit_code":cp.returncode,**_summarize(out, argv[0] if argv else "run")}
    except subprocess.TimeoutExpired as e:
        return {"argv":argv,"timeout":True,"output":((e.stdout or "") if isinstance(e.stdout,str) else "")[:MAX_OUTPUT]}


def _summarize(out: str, source: str = "output") -> dict[str, Any]:
    """Compact long tool output: keep head+tail, flag-like and interesting lines,
    and save the full text to CTF_ROOT/artifacts/mcp/ for later grep. This keeps
    small-context models from drowning in raw output."""
    lines = out.splitlines()
    if len(out) <= 6000 and len(lines) <= 120:
        return {"output": out, "truncated": False}
    import hashlib, re as _re, time as _time
    saved = None
    try:
        d = ROOT / "artifacts" / "mcp"
        d.mkdir(parents=True, exist_ok=True)
        name = f"{_re.sub(r'[^A-Za-z0-9._-]','_',source)[:40]}-{hashlib.sha1(out.encode()).hexdigest()[:8]}.txt"
        (d / name).write_text(out)
        saved = str(d / name)
    except Exception:
        pass
    pat = _re.compile(r"(flag|ctf|key|secret|password|error|fail|denied|0x[0-9a-f]+|\{[^}]{2,}\})", _re.I)
    interesting = [l for l in lines if pat.search(l)][:40]
    head = lines[:40]
    tail = lines[-15:]
    body = "\n".join(head)
    if interesting:
        body += "\n... [interesting lines] ...\n" + "\n".join(interesting)
    body += "\n... [tail] ...\n" + "\n".join(tail)
    return {"output": body[:MAX_OUTPUT], "truncated": True, "total_lines": len(lines),
            "full_output_saved_to": saved,
            "note": "Output summarized. grep the saved file for detail."}


@mcp.tool()
def crypto_inventory() -> dict[str, Any]:
    """Report crypto CLI, Python environment and Sage availability."""
    return {"ctf_root":str(ROOT),"python":str(VENV_PY) if VENV_PY.exists() else None,"tools":{n:shutil.which(c[0]) or (c[0] if Path(c[0]).exists() else None) for n,c in TOOLS.items()}}


@mcp.tool()
def crypto_list_files(relative_dir: str = ".", max_entries: int = 300) -> list[dict[str, Any]]:
    """List files under the CTF workspace."""
    base=_inside_root(relative_dir)
    rows=[]
    for p in sorted(base.iterdir(), key=lambda x:x.name)[:max_entries]:
        st=p.stat(); rows.append({"name":p.name,"path":str(p),"type":"dir" if p.is_dir() else "file","size":st.st_size})
    return rows


@mcp.tool()
def crypto_file_info(path: str) -> dict[str, Any]:
    """Return basic file metadata for a challenge artifact."""
    p=_inside_root(path); st=p.stat()
    cp=_run(["file","-b",str(p)],10)
    return {"path":str(p),"size":st.st_size,"file":cp.get("output","").strip()}


@mcp.tool()
def crypto_run(tool: str, args: list[str] | None = None, timeout: int = 60) -> dict[str, Any]:
    """Run an allowlisted crypto CLI with challenge-scoped path arguments."""
    if tool not in TOOLS: raise ValueError(f"Tool not allowlisted: {tool}")
    exe=TOOLS[tool][0]
    if shutil.which(exe) is None and not Path(exe).exists(): raise FileNotFoundError(exe)
    return _run(TOOLS[tool]+[_safe_arg(str(a)) for a in (args or [])], min(max(timeout,1),300))


@mcp.tool()
def crypto_python_script(path: str, args: list[str] | None = None, timeout: int = 60) -> dict[str, Any]:
    """Run a Python solver script stored inside the authorized CTF workspace."""
    if not VENV_PY.exists(): raise FileNotFoundError(VENV_PY)
    script=_inside_root(path)
    if script.suffix != ".py": raise ValueError("Expected a .py solver script")
    return _run([str(VENV_PY), str(script)] + [_safe_arg(str(a)) for a in (args or [])], min(max(timeout,1),180))


@mcp.tool()
def crypto_sage_script(path: str, args: list[str] | None = None, timeout: int = 120) -> dict[str, Any]:
    """Run a Sage solver script stored inside the authorized CTF workspace."""
    sage=Path(SAGE).expanduser()
    if shutil.which(str(sage)) is None and not sage.exists(): raise FileNotFoundError(SAGE)
    script=_inside_root(path)
    if script.suffix not in {".sage", ".py"}: raise ValueError("Expected a .sage or .py Sage script")
    return _run([str(sage), str(script)] + [_safe_arg(str(a)) for a in (args or [])], min(max(timeout,1),300))


if __name__ == "__main__":
    ROOT.mkdir(parents=True,exist_ok=True)
    mcp.run()
