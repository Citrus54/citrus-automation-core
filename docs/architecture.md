#  Citrus Automation Core – Architecture

This document explains what the system is doing and how the components talk to each other.

---

## Big-picture flow

```text
[NFC Tag tapped]
       ↓
[iPhone Shortcut]
       ↓  HTTP POST
[Raspberry Pi Node-RED]
       ↓  HTTP POST
[Windows Node-RED]
       ↓
[PowerShell → apps / actions on PC]
```
## Roles

iPhone + NFC

Physical trigger.

Can also do phone-native actions (music, Focus, etc.).

Raspberry Pi (Node-RED)

Orchestrator / API gateway.

Exposes /trigger/productivity.

Forwards to PC via HTTP.

Returns fast response to iPhone.

Windows PC (Node-RED + PowerShell)

Automation agent.

Exposes /pc/productivity.

Actually launches apps/scripts.

## Raspberry Pi (Orchestrator)

Node-RED runs as a systemd service:

sudo systemctl enable nodered
sudo systemctl status nodered


Editor UI:

http://raspberrypi.local:1880


Key endpoint:

POST /trigger/productivity


Responsibilities:

Receive HTTP from iPhone.

Log the trigger.

Call http://<PC_IP>:1880/pc/productivity.

Return 200 OK ASAP to iOS.

## Windows PC (Automation Agent)

Node-RED installed via npm, run as a Windows service via NSSM.

All config isolated in:

C:\NodeRED\


The NSSM service:

Path: C:\Windows\System32\cmd.exe

Startup directory: C:\NodeRED

Arguments: /c C:\NodeRED\start-node-red.bat

Log on: runs under my user account (so it can open GUI apps).

start-node-red.bat:

Calls node-red with:

--settings C:\NodeRED\settings.js

-u C:\NodeRED

-p 1880

Logs to C:\NodeRED\logs\nodered.log.

Editor UI:

http://localhost:1880


Key endpoint:

POST /pc/productivity


Responsibilities:

Receive POST from Pi.

Launch apps via exec → PowerShell.

Return JSON response to Pi.

## iPhone + NFC (Trigger Layer)

Uses Shortcuts → Automation → NFC.

When the tag is tapped:

Shortcut runs automatically.

Uses Get Contents of URL:

URL: http://<PI_IP>:1880/trigger/productivity

Method: POST

Responsibilities:

Physical trigger (tap a sticker, things happen).

Optional local actions on phone (Music, Focus, etc.).

## Node-RED flows (concept level)
1. Pi flow (flows/pi/productivity.json)

Logical steps:

HTTP In: POST /trigger/productivity

Function node: log “Productivity trigger received”.

HTTP Request node:

Method: POST

URL: http://<PC_IP>:1880/pc/productivity

Change node:

Set msg.payload = {"status":"accepted"}

HTTP Response:

Returns 200 OK + JSON to iPhone.

2. PC flow (flows/pc/productivity.json)

Logical steps:

HTTP In: POST /pc/productivity

Exec node:

Runs PowerShell:

powershell.exe -Command "Start-Process 'C:\Program Files\DuckDuckGo\DuckDuckGo.exe'"


or later:

powershell.exe -ExecutionPolicy Bypass -File "C:\NodeRED\scripts\productivity.ps1"


Change node:

Set msg.payload = {"status":"ok"}

HTTP Response:

Returns 200 OK + JSON back to the Pi.

## Extensibility

Same pattern scales to:

New tags / flows:

/trigger/gaming → /pc/gaming

/trigger/streaming → /pc/streaming

/trigger/sleep → /pc/sleep

Wake-on-LAN:

Pi sends magic packet to PC NIC.

Home automation:

Pi talks to lights / plugs / IR devices from the same flow.
