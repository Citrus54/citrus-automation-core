# Citrus Automation Core

Citrus Automation Core is a fully local, NFC-triggered automation system that lets a phone trigger different computer “modes” (Productivity, Gaming, etc.) without cloud services, voice assistants, or exposed ports.

### Core stack:

iPhone + NFC tags (iOS Shortcuts)

Raspberry Pi 4 (Node-RED orchestrator)

Windows PC (Node-RED + PowerShell automation)

LAN + Tailscale for secure private networking

One tap → one mode → instant environment change.

## Core Demos
### Productivity Mode

Tap a Productivity NFC tag → PC launches a focused work environment.

Current behavior:

Opens DuckDuckGo (expandable to tabs, tools, notes, music)

### Gaming Mode

Tap a Gaming NFC tag → PC switches into a gaming-ready state.

Current behavior:

Closes work apps (example: Notepad)

Launches Steam

Launches Discord

Logs execution and verifies post-launch processes

## High-Level Flow
[NFC tag tapped on iPhone]
        ↓
[iOS Shortcut: HTTP POST → Raspberry Pi]
        ↓
[Pi Node-RED: validate + route]
        ↓
[Windows Node-RED: exec PowerShell]
        ↓
[PC launches mode-specific apps]


No public internet exposure

No cloud automation platforms

All traffic stays on LAN / Tailscale

iPhone receives fast 200 OK responses to avoid shortcut timeouts

## What This Project Demonstrates

This repo exists for employers and future me.

### I can build and operate:

Raspberry Pi systems (SSH, services, networking)

Node-RED on Linux and Windows

Windows services using NSSM

HTTP-based automation between devices

Secure private networking with Tailscale

OS-level automation with PowerShell

NFC-triggered workflows via iOS Shortcuts

### I can design:

A small distributed system:

Phone = trigger / UX

Pi = orchestration layer

PC = automation agent

Clear separation of responsibilities

Extensible “mode-based” automation (Productivity, Gaming, etc.)

### I can troubleshoot:

Cross-device communication issues

Script execution failures

Environment differences between manual vs service execution

Logging, validation, and recovery paths

### I can document:

How the system works end-to-end

How to rebuild it from scratch

How to extend it safely

## Repo Layout
citrus-automation-core/
│
├── README.md
├── .gitignore
│
├── docs/
│   ├── architecture.md
│   ├── setup-end-to-end.md
│   ├── future-work.md
│
├── flows/
│   ├── pi/
│   │   ├── productivity.json
│   │   └── gaming.json
│   │
│   └── pc/
│       ├── productivity.json
│       └── gaming.json
│
├── shortcuts/
│   ├── Productivity Tag.shortcut
│   ├── Gaming Tag.shortcut
│   ├── ios-productivity-shortcut.md
│   └── ios-gaming-shortcut.md
│
└── scripts/
    ├── productivity.ps1
    └── gaming.ps1

## Architecture Notes

### aspberry Pi

Runs Node-RED as a systemd service

Receives NFC-triggered HTTP requests

Performs validation and routing

Forwards requests to PC over Tailscale

### Windows PC

Runs Node-RED as a Windows service via NSSM

Uses exec nodes to call PowerShell scripts

PowerShell handles all OS-level logic

Writes detailed logs for troubleshooting

## Current Mode Behavior
### Productivity Mode

NFC tag tapped

iOS Shortcut sends POST /trigger/productivity

Pi Node-RED logs + forwards request

PC Node-RED runs productivity.ps1

Productivity apps launch

JSON { "status": "ok" } returned

### Gaming Mode

NFC tag tapped

iOS Shortcut sends POST /trigger/gaming

Pi Node-RED logs + forwards request

PC Node-RED runs gaming.ps1

Work apps closed

Steam and Discord launched

Post-launch verification logged

JSON { "status": "ok" } returned

## Rebuilding the System

A full, linear rebuild guide is here:

docs/setup-end-to-end.md


That guide covers:

Pi setup

Node-RED installation

Windows service configuration

NFC shortcut creation

End-to-end testing

## Future Work

Tracked in docs/future-work.md, including:

Productivity Mode v2:

Multiple browser tabs

Notes / editor

Music

Additional modes:

Streaming

Sleep

Wake

Wake-on-LAN from Pi → PC

Smart lights / plugs via Pi Node-RED

Centralized mode configuration
