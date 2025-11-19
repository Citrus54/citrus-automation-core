# Citrus Automation Core

**Citrus Automation Core** is a local, NFC-powered automation system that connects:

- **iPhone + NFC tags**
- **Raspberry Pi (Node-RED)**
- **Windows PC (Node-RED + PowerShell)**

Core demo:

> Tap an NFC tag → iPhone Shortcut calls the Pi →  
> Pi calls the PC → PC opens a “Productivity” routine (currently DuckDuckGo).

No exposed internet ports. All traffic stays on LAN / Tailscale.

---

## What this project demonstrates

For employers and for my future self, this repo shows:

- I can:
  - Configure a Raspberry Pi, SSH, and systemd services.
  - Install and run Node-RED on **both** Linux and Windows.
  - Use **NSSM** to run Node-RED as a Windows service.
  - Build HTTP-based automation between devices.
  - Use iOS Shortcuts + NFC tags to trigger automations.
- I can design:
  - A small distributed system (Phone → Pi → PC).
  - Clean separation of roles:
    - Phone = trigger / UX
    - Pi = orchestrator
    - PC = automation agent
- I can document:
  - How to rebuild everything step-by-step.
  - How it works internally, for someone reading the repo cold.

---

## Repo layout

```text
citrus-automation-core/
│
├── README.md                      # Overview (this file)
├── .gitignore                     # Ignore logs and junk
│
├── docs/
│   ├── architecture.md            # High-level system architecture
│   ├── setup-end-to-end.md        # Step-by-step setup from scratch
│   ├── future-work.md             # Planned improvements
│
├── flows/
│   ├── pi/
│   │   └── productivity.json      # Exported Pi Node-RED flow
│   └── pc/
│       └── productivity.json      # Exported PC Node-RED flow
│
├── shortcuts/
│   ├── Productivity Tag.shortcut          # Exported iOS Shortcut (binary)
│   └── ios-productivity-shortcut.md       # Human-readable Shortcut description
│
└── scripts/
    └── productivity.ps1           # PowerShell script for PC productivity routine
