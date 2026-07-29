# yourTermux

> Menu-driven Termux setup — everything customizable from one script.
> Author: **JubairSenseiDev**

[![License: GPL-3.0](https://img.shields.io/badge/license-GPL--3.0-blue.svg)](./LICENSE)

## Quick start

```bash
pkg update && pkg upgrade
pkg i -y git

git clone --depth=1 https://github.com/JubairSenseiDev/yourTermux.git
cd yourTermux
./yourtermux.sh
```

That's it. A menu opens — pick what you want to customize. No file editing needed.

## The menu

```
  MAIN MENU
  ─────────────
  1. 🚀 Install         (Minimal or Full)
  2. 🎨 Banner          (create your own)
  3. ⌨  Keys            (customize bottom buttons)
  4. 💡 Suggestions     (command aliases + yt-help)
  5. 👀 Show banner     (preview current banner)
  6. ℹ️  About
  0. Exit
```

You can also jump straight to a sub-menu:

```bash
./yourtermux.sh install        # Minimal or Full install
./yourtermux.sh banner         # Banner customizer
./yourtermux.sh keys           # Key customizer
./yourtermux.sh suggestions    # Command suggestions manager
./yourtermux.sh about
./yourtermux.sh --help
```

## 1. Banner customizer

Create your own banner from the menu — no code editing.

**Presets:**
1. Block big (default)
2. Slant
3. Simple single-line
4. Boxed
5. Hacker green
6. Custom text (you type multi-line)

Pick a preset, pick a color (red/green/yellow/blue/magenta/cyan/white/none), done. The banner is saved to `~/.local/share/yourtermux/banner/banner-custom.sh` and the `yourtermux-banner` launcher auto-uses it.

Run `banner` anytime to see it.

## 2. Command suggestions

Enable/disable a set of newbie-friendly aliases + a `yt-help` cheat-sheet function. Also add your own aliases from the menu — no `~/.aliases` editing.

Included aliases: `banner`, `reload-termux`, `ipinfo`, `bigfiles`, `search`, `weather`, `sysupdate`, `ports`, `findfile`, `calc`, `today`, `path`, `topten`, `size`.

Type `yt-help` after enabling to see the full cheat-sheet.

## 3. Key customizer

Customize the bottom button row above the soft keyboard — **no `termux.properties` editing**.

**Presets:**
1. Minimal — `SHIFT TAB ENTER ⌨` (just the essentials)
2. Coder — brackets + arrows + ⌨
3. Power user — F1-F9 + CTRL/ALT + ⌨ + arrows + brackets
4. Default Termux — no extra keys
5. Build your own — type keys row by row

Special keys supported: `KEYBOARD` (⌨ toggle), `DRAWER`, `SHIFT`, `CTRL`, `ALT`, `ESC`, `TAB`, `ENTER`, arrows, `HOME`, `END`, `F1`-`F12`, all brackets/braces, `$`, `\`, `/`, `<`, `>`, `-`, `=`.

After applying, run `termux-reload-settings` (alias: `reload-termux`) to activate.

## Install modes

| Mode     | What it does                                                            | Time    |
|----------|-------------------------------------------------------------------------|---------|
| Minimal  | Banner + keys + suggestions only. Default Termux theme.                 | ~1 min  |
| Full     | Everything: zsh, oh-my-zsh, fonts, colorschemes, NvChad, music, toys.   | ~10 min |

Minimal is recommended for first-time users — you can always run Full later.

## Files this script manages

| Path                                              | Purpose                          |
|---------------------------------------------------|----------------------------------|
| `~/.config/yourtermux/`                           | Config dir                       |
| `~/.local/share/yourtermux/banner/`               | Banner scripts (incl. custom)    |
| `~/.local/bin/yourtermux-banner`                  | Banner launcher                  |
| `~/.termux/termux.properties`                     | Custom keys                      |
| `~/.aliases`                                      | Command suggestions              |

## License

GPL-3.0 — see [LICENSE](./LICENSE).
