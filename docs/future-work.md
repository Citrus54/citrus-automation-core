#  Citrus Automation Core — Future Work

This document tracks planned upgrades to the system, new automations, improved security, and next-phase architecture. It exists so the project remains extensible and future contributors (or employers) can see a roadmap.

---

## 1. Expand Productivity Mode (Phase 2)**

Current behavior:
- Launches DuckDuckGo browser.

Planned upgrades:
- Open Notes or Obsidian for journaling
- Start Apple Music playlist
- Enable Do Not Disturb or Focus Mode
- Open specific browser tabs based on context (work vs research)
- Launch terminal + multiple apps via a PowerShell script

All changes will go inside:

scripts/productivity.ps1


---

## 2. Additional NFC Modes (Multi-Mode System)**

Planned tags:

| Mode | Example Trigger | Example Action |
|------|----------------|----------------|
| **Gaming** | NFC tag on controller | Launch Steam / Discord / LED scene |
| **Streaming** | Tag on desk mount | Open OBS, mic routing, scene profile |
| **Sleep Mode** | Tag on nightstand | Dim lights, lock PC, play music |
| **Kitchen Mode** | Tag on fridge | Open recipes, smart plug appliances |

Each will follow the pattern:
iPhone → Pi: /trigger/<mode>
Pi → PC: /pc/<mode>


---

## 3. Wake-on-LAN (Turn On PC)**

Goal: Tap NFC → Pi sends WOL packet → PC boots.

Steps planned:
- Enable WOL in BIOS + NIC settings
- Install tool:

```bash
sudo apt install wakeonlan
New endpoint:
/pc/wake
Example Pi command:
wakeonlan <PC_MAC_ADDRESS>
```
## 4. Smart Lighting & IR Expansion

Future integrations:

LED strips

Zigbee/Z-Wave hubs

IR blasting via Flipper Zero or USB IR transmitter

Desk peripheral automation

Flow direction remains:
iPhone → Pi → PC → Devices
Goal: No cloud services, local-only.

## 5. Security Hardening (Future)

Planned improvements:

Move off HTTP → HTTPS internal certificates

Add secret tokens to endpoints

Move PC Node-RED behind private subnet

Add firewall rules per-flow instead of wide-open

Also planned:

Remove plaintext paths from logs

Enforce execution policies on PowerShell scripts

## 6. Documentation & Portfolio Polish

Add:

Screenshots of Node-RED flows

Architecture diagrams

Video demo

Wiki-format docs

Troubleshooting section
## 7. Stretch Goals

Custom desktop app UI for controlling flows

ESP32 presence detection

RFID/NFC desk coaster controller

Cloudflare Tunnel + OAuth for remote access

Dockerize Node-RED on both Pi + PC

### Status Tracking
| Feature                   | Status            | Notes               |
| ------------------------- | ----------------- | ------------------- |
| Initial Productivity Mode | ✔ Working         | Opens DuckDuckGo    |
| Windows Service via NSSM  | ✔ Done            | Auto-starts on boot |
| iPhone NFC → Pi → PC      | ✔ Fully working   | No timeouts         |
| Wake-on-LAN               | ⏳ Not implemented | Requires config     |
| Multi-mode NFC            | ⏳ Planned         | New flows required  |
| Smart Lighting            | ⏳ Planned         | Needs devices       |
