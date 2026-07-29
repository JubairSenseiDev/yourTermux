#!/usr/bin/env node
/**
 * yourTermux - Standalone banner script (Node.js)
 * Author: JubairSenseiDev
 *
 * Pure Node.js — no npm dependencies required.
 * Uses ANSI escape codes for color (graceful fallback to plain text
 * when stdout is not a TTY or when NO_COLOR is set).
 *
 * Usage:
 *   ./banner.js                  # default cyan banner
 *   node banner.js --color green
 *   node banner.js --no-color
 *   node banner.js --help
 */

'use strict';

const VERSION  = '1.0.0';
const AUTHOR   = 'JubairSenseiDev';
const TAGLINE  = 'Termux setup for new users';

const BUILD_DATE = new Date().toLocaleDateString('en-US', {
  day:   '2-digit',
  month: 'long',
  year:  'numeric',
});

const ANSI = {
  red:     '\x1b[1;31m',
  green:   '\x1b[1;32m',
  yellow:  '\x1b[1;33m',
  blue:    '\x1b[1;34m',
  magenta: '\x1b[1;35m',
  cyan:    '\x1b[1;36m',
  white:   '\x1b[1;37m',
  dim:     '\x1b[2m',
  reset:   '\x1b[0m',
};

const BANNER_ART = [
  '    __   __ _______ _______ _______ ___   _______ ',
  '    \\ \\ / /|  ___  |  ___  |  ___  |   | |  _____|',
  '     \\ V / | |   | | |   | | |   | |   | | |_____ ',
  '      | |  | |   | | |   | | |   | |   | |_____  |',
  '      | |  | |___| | |___| | |___| |___| |_____| |',
  '      |_|  |_______|_______|_______|_______|_____|',
];

function parseArgs(argv) {
  const args = { color: 'cyan', noColor: false, help: false };
  for (let i = 0; i < argv.length; i++) {
    const a = argv[i];
    if (a === '--color') {
      args.color = argv[++i] || 'cyan';
    } else if (a === '--no-color') {
      args.noColor = true;
    } else if (a === '--help' || a === '-h') {
      args.help = true;
    } else if (a.startsWith('--color=')) {
      args.color = a.slice(8);
    }
  }
  return args;
}

function printHelp() {
  console.log(`yourTermux banner (Node.js)

Usage: node banner.js [OPTIONS]

Options:
  --color COLOR   Banner color: red, green, yellow, blue, magenta, cyan, white (default: cyan)
  --no-color      Disable ANSI colors
  --help, -h      Show this help message

Environment:
  NO_COLOR        If set, colors are disabled (respects https://no-color.org)`);
}

function main() {
  const args = parseArgs(process.argv.slice(2));

  if (args.help) {
    printHelp();
    process.exit(0);
  }

  const validColors = ['red', 'green', 'yellow', 'blue', 'magenta', 'cyan', 'white'];
  if (!validColors.includes(args.color)) {
    process.stderr.write(`Unknown color: ${args.color}\n`);
    process.stderr.write(`Valid colors: ${validColors.join(', ')}\n`);
    process.exit(2);
  }

  const disableColor = args.noColor
    || process.env.NO_COLOR
    || !process.stdout.isTTY;

  const c = disableColor ? '' : ANSI[args.color];
  const y = disableColor ? '' : ANSI.yellow;
  const w = disableColor ? '' : ANSI.white;
  const g = disableColor ? '' : ANSI.green;
  const m = disableColor ? '' : ANSI.magenta;
  const b = disableColor ? '' : ANSI.blue;
  const d = disableColor ? '' : ANSI.dim;
  const r = disableColor ? '' : ANSI.reset;

  for (const line of BANNER_ART) {
    console.log(`${c}${line}${r}`);
  }

  console.log(`    ${y}Version ${w}: ${g}${VERSION}`);
  console.log(`    ${y}Build   ${w}: ${g}${BUILD_DATE}`);
  console.log(`    ${y}Author  ${w}: ${m}${AUTHOR}`);
  console.log(`    ${y}Tagline ${w}: ${b}${TAGLINE}`);
  console.log('');
  console.log(`    ${d}Quick keys : F1=help  ESC=back  TAB=complete  CTRL+T=new session${r}`);
  console.log(`    ${d}Commands   : chcolor  chfont  chzsh  pacupg  sd  pf${r}`);
  console.log('');
}

main();
