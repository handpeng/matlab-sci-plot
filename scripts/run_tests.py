#!/usr/bin/env python3
"""Local-first validation entrypoint; MATLAB status is reported, never fabricated."""
from __future__ import annotations

import os
import shutil
import subprocess
import sys


def main() -> int:
    command = [sys.executable, "-m", "unittest", "discover", "-s", "tests", "-v"]
    result = subprocess.run(command, check=False)
    matlab = os.environ.get("MATLAB_BIN") or shutil.which("matlab") or shutil.which("matlab.exe")
    available = False
    if matlab:
        probe = subprocess.run([matlab, "-batch", "disp('MATLAB_AVAILABLE')"], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, check=False)
        available = probe.returncode == 0
    print(f"MATLAB_AVAILABLE={'YES' if available else 'NO'}")
    print(f"MATLAB_SMOKE_TESTS={'PENDING_LOCAL_RUN' if available else 'SKIPPED_UNAVAILABLE'}")
    return result.returncode


if __name__ == "__main__":
    raise SystemExit(main())
