// yourTermux - Standalone banner script (Go)
// Author: JubairSenseiDev
//
// Compile:
//   go build -o banner banner.go
//
// Run:
//   ./banner                  # default cyan banner
//   ./banner --color green
//   ./banner --no-color
//   ./banner --help
//
// No external dependencies — only the Go standard library.

package main

import (
	"flag"
	"fmt"
	"os"
	"strings"
	"time"
)

const (
	Version = "1.0.0"
	Author  = "JubairSenseiDev"
	Tagline = "Termux setup for new users"
)

var bannerArt = []string{
	"    __   __ _______ _______ _______ ___   _______ ",
	"    \\ \\ / /|  ___  |  ___  |  ___  |   | |  _____|",
	"     \\ V / | |   | | |   | | |   | |   | | |_____ ",
	"      | |  | |   | | |   | | |   | |   | |_____  |",
	"      | |  | |___| | |___| | |___| |___| |_____| |",
	"      |_|  |_______|_______|_______|_______|_____|",
}

type ansi struct {
	c, y, w, g, m, b, d, r string
}

func ansiCodes(color string, noColor bool) ansi {
	if noColor {
		return ansi{}
	}
	codes := map[string]string{
		"red":     "\033[1;31m",
		"green":   "\033[1;32m",
		"yellow":  "\033[1;33m",
		"blue":    "\033[1;34m",
		"magenta": "\033[1;35m",
		"cyan":    "\033[1;36m",
		"white":   "\033[1;37m",
	}
	dim := "\033[2m"
	reset := "\033[0m"
	c, ok := codes[color]
	if !ok {
		c = codes["cyan"]
	}
	return ansi{
		c: c,
		y: codes["yellow"],
		w: codes["white"],
		g: codes["green"],
		m: codes["magenta"],
		b: codes["blue"],
		d: dim,
		r: reset,
	}
}

func isTTY() bool {
	fi, err := os.Stdout.Stat()
	if err != nil {
		return false
	}
	return (fi.Mode() & os.ModeCharDevice) != 0
}

func main() {
	color := flag.String("color", "cyan", "Banner color: red, green, yellow, blue, magenta, cyan, white (default: cyan)")
	noColor := flag.Bool("no-color", false, "Disable ANSI colors")
	flag.Parse()

	disable := *noColor || os.Getenv("NO_COLOR") != "" || !isTTY()
	a := ansiCodes(*color, disable)

	buildDate := time.Now().Format("02 January 2006")

	for _, line := range bannerArt {
		fmt.Printf("%s%s%s\n", a.c, line, a.r)
	}

	fmt.Printf("    %sVersion %s: %s%s\n", a.y, a.w, a.g, Version)
	fmt.Printf("    %sBuild   %s: %s%s\n", a.y, a.w, a.g, buildDate)
	fmt.Printf("    %sAuthor  %s: %s%s\n", a.y, a.w, a.m, Author)
	fmt.Printf("    %sTagline %s: %s%s\n", a.y, a.w, a.b, Tagline)
	fmt.Println()
	fmt.Printf("    %sQuick keys : F1=help  ESC=back  TAB=complete  CTRL+T=new session%s\n", a.d, a.r)
	fmt.Printf("    %sCommands   : chcolor  chfont  chzsh  pacupg  sd  pf%s\n", a.d, a.r)
	fmt.Println()

	_ = strings.Builder{}
}
