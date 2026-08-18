#!/usr/bin/env python3
"""CTF OSINT MCP: allowlisted, evidence-oriented helpers for authorized challenges.

This server intentionally defaults to lightweight/passive queries and does not
provide arbitrary shell execution.
"""
from __future__ import annotations

import os
import re
import shutil
import subprocess
from pathlib import Path
from typing import Any

from mcp.server.fastmcp import FastMCP

mcp=FastMCP("ctf-osint")
ROOT=Path(os.environ.get("CTF_ROOT",str(Path.home()/"ctf"))).expanduser().resolve()
MAX_OUTPUT=int(os.environ.get("CTF_MCP_MAX_OUTPUT","40000"))

TOOLS={
    "whois":["whois"], "dig":["dig"], "host":["host"], "nslookup":["nslookup"],
    "dnsrecon":["dnsrecon"], "dnsenum":["dnsenum"], "massdns":["massdns"],
    "amass":["amass"], "subfinder":["subfinder"], "assetfinder":["assetfinder"],
    "theHarvester":["theHarvester"], "sherlock":["sherlock"], "maigret":["maigret"],
    "spiderfoot":["spiderfoot"], "recon-ng":["recon-ng"], "metagoofil":["metagoofil"],
    "waybackpy":["waybackpy"], "instaloader":["instaloader"], "photon":["photon"],
    "exiftool":["exiftool"], "curl":["curl"],
}
# Options that turn normally passive discovery into explicitly active behavior.
DENIED_ARGS={"-active","--active","-brute","--brute","-p","--ports"}
DOMAIN_RE=re.compile(r"^(?=.{1,253}$)(?:[A-Za-z0-9](?:[A-Za-z0-9-]{0,61}[A-Za-z0-9])?\.)+[A-Za-z]{2,63}$")


def _run(argv:list[str], timeout:int=45)->dict[str,Any]:
    try:
        cp=subprocess.run(argv,cwd=ROOT,text=True,capture_output=True,timeout=timeout,env=os.environ.copy())
        out=(cp.stdout or "") + (("\n[stderr]\n"+cp.stderr) if cp.stderr else "")
        return {"argv":argv,"exit_code":cp.returncode,"output":out[:MAX_OUTPUT],"truncated":len(out)>MAX_OUTPUT}
    except subprocess.TimeoutExpired as e:
        return {"argv":argv,"timeout":True,"output":((e.stdout or "") if isinstance(e.stdout,str) else "")[:MAX_OUTPUT]}


@mcp.tool()
def osint_inventory()->dict[str,Any]:
    """Report which allowlisted OSINT tools are installed."""
    return {"ctf_root":str(ROOT),"tools":{n:shutil.which(c[0]) for n,c in TOOLS.items()}}


@mcp.tool()
def osint_run(tool:str,args:list[str]|None=None,timeout:int=45)->dict[str,Any]:
    """Run one allowlisted OSINT tool. Use only organizer-approved CTF targets."""
    if tool not in TOOLS: raise ValueError(f"Tool not allowlisted: {tool}")
    vals=[str(a) for a in (args or [])]
    if any(a.lower() in DENIED_ARGS for a in vals):
        raise ValueError("Active/brute-force option blocked by the team OSINT MCP profile")
    if shutil.which(TOOLS[tool][0]) is None: raise FileNotFoundError(TOOLS[tool][0])
    return _run(TOOLS[tool]+vals,min(max(timeout,1),180))


@mcp.tool()
def osint_domain_snapshot(domain:str)->dict[str,Any]:
    """Collect a small passive DNS/WHOIS snapshot for an authorized CTF domain."""
    d=domain.strip().rstrip(".")
    if not DOMAIN_RE.match(d): raise ValueError("Expected a normal DNS domain name")
    return {
        "domain":d,
        "whois":_run(["whois",d],30) if shutil.which("whois") else {"missing":"whois"},
        "a":_run(["dig","+short","A",d],15) if shutil.which("dig") else {"missing":"dig"},
        "aaaa":_run(["dig","+short","AAAA",d],15) if shutil.which("dig") else {"missing":"dig"},
        "mx":_run(["dig","+short","MX",d],15) if shutil.which("dig") else {"missing":"dig"},
        "txt":_run(["dig","+short","TXT",d],15) if shutil.which("dig") else {"missing":"dig"},
        "ns":_run(["dig","+short","NS",d],15) if shutil.which("dig") else {"missing":"dig"},
    }


if __name__=="__main__":
    ROOT.mkdir(parents=True,exist_ok=True)
    mcp.run()
