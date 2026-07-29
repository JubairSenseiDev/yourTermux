#!/usr/bin/env python3
"""
yourTermux - Standalone banner script (Python)
Author: JubairSenseiDev

Uses ANSI escape codes for color (graceful fallback to plain text
when stdout is not a TTY or when NO_COLOR is set).

Usage:
    ./banner.py                  # default cyan banner
    python3 banner.py --color green
    python3 banner.py --no-color
    python3 banner.py --help
"""

from __future__ import annotations

import argparse
import os
import sys
from datetime import datetime

VERSION = "1.0.0"
BUILD_DATE = datetime.now().strftime("%d %B %Y")
AUTHOR = "JubairSenseiDev"
TAGLINE = "Termux setup for new users"

# ANSI color codes
ANSI = {
    "red":     "\033[1;31m",
    "green":   "\033[1;32m",
    "yellow":  "\033[1;33m",
    "blue":    "\033[1;34m",
    "magenta": "\033[1;35m",
    "cyan":    "\033[1;36m",
    "white":   "\033[1;37m",
    "dim":     "\033[2m",
    "reset":   "\033[0m",
}

BANNER_ART = [
    "    __   __ _______ _______ _______ ___   _______ ",
    "    \\ \\ / /|  ___  |  ___  |  ___  |   | |  _____|",
    "     \\ V / | |   | | |   | | |   | |   | | |_____ ",
    "      | |  | |   | | |   | | |   | |   | |_____  |",
    "      | |  | |___| | |___| | |___| |___| |_____| |",
    "      |_|  |_______|_______|_______|_______|_____|",
]


def colors_disabled(args) -> bool:
    if args.no_color:
        return True
    if os.environ.get("NO_COLOR"):
        return True
    if not sys.stdout.isatty():
        return True
    return False


def main() -> int:
    parser = argparse.ArgumentParser(
        prog="banner.py",
        description="yourTermux banner (Python)",
        formatter_class=argparse.RawDescriptionHelpFormatter,
    )
    parser.add_argument(
        "--color",
        choices=["red", "green", "yellow", "blue", "magenta", "cyan", "white"],
        default="cyan",
        help="Banner color (default: cyan)",
    )
    parser.add_argument(
        "--no-color",
        action="store_true",
        help="Disable ANSI colors",
    )
    args = parser.parse_args()

    if colors_disabled(args):
        c = y = w = g = m = b = d = r = ""
    else:
        c = ANSI[args.color]
        y = ANSI["yellow"]
        w = ANSI["white"]
        g = ANSI["green"]
        m = ANSI["magenta"]
        b = ANSI["blue"]
        d = ANSI["dim"]
        r = ANSI["reset"]

    # Banner art
    for line in BANNER_ART:
        print(f"{c}{line}{r}")

    # Info block
    print(f"    {y}Version {w}: {g}{VERSION}")
    print(f"    {y}Build   {w}: {g}{BUILD_DATE}")
    print(f"    {y}Author  {w}: {m}{AUTHOR}")
    print(f"    {y}Tagline {w}: {b}{TAGLINE}")
    print()
    print(f"    {d}Quick keys : F1=help  ESC=back  TAB=complete  CTRL+T=new session{r}")
    print(f"    {d}Commands   : chcolor  chfont  chzsh  pacupg  sd  pf{r}")
    print()

    return 0


if __name__ == "__main__":
    sys.exit(main())
