# Citrus Automation Core – End-to-End Setup

This guide shows how to rebuild the entire NFC → iPhone → Raspberry Pi → Windows PC automation system from scratch.

It covers both Productivity and Gaming modes, exactly as currently implemented.

Follow it linearly. No assumptions.

## What the system does (big picture)
### Goal demos

Productivity mode

Tap Productivity NFC tag →
iPhone Shortcut →
Raspberry Pi →
Windows PC →
Runs productivity.ps1 (opens DuckDuckGo, etc.)


Gaming mode

Tap Gaming NFC tag →
iPhone Shortcut →
Raspberry Pi →
Windows PC →
Runs gaming.ps1 (Steam + Discord)

### High-level flow
```
[NFC Tag tapped on iPhone]
        ↓
[iOS Shortcut: POST /trigger/{mode} → Pi]
        ↓
[Raspberry Pi Node-RED: validates + forwards]
        ↓
[POST /pc/{mode} → Windows PC]
        ↓
[Windows Node-RED: exec PowerShell script]
```

### Key properties

No exposed internet ports

LAN + optional Tailscale only

Pi = orchestrator

PC = execution agent

iPhone = trigger / UX

## What you are building

You will set up:

### On Raspberry Pi

Node-RED running as a systemd service

HTTP endpoints:

POST /trigger/productivity

POST /trigger/gaming

Forwarding logic to the PC

### On Windows PC

Node-RED running as an NSSM service

HTTP endpoints:

POST /pc/productivity

POST /pc/gaming

PowerShell execution:

productivity.ps1

gaming.ps1

### On iPhone

Two NFC-bound Shortcuts:

Productivity Tag

Gaming Tag

## Prerequisites

### You need:

Raspberry Pi (any model that runs Node-RED reliably)

Raspberry Pi OS

Windows 11 PC

iPhone with NFC + Shortcuts app

### Tools:

SSH (Windows Terminal / PowerShell)

Browser on Windows

Admin access on Windows (for NSSM)

##  Raspberry Pi – Node-RED setup
### 1 SSH into the Pi
ssh pi@raspberrypi.local


Or use the IP:

ssh pi@<PI_IP_ADDRESS>


Verify:

hostname
``` 
raspberrypi
```
### 2 Ensure Node-RED is running as a service
sudo systemctl status nodered


If not running:

sudo systemctl enable nodered
sudo systemctl start nodered


Confirm:

sudo systemctl status nodered
Active: active (running)

### 3 Open Node-RED editor (Pi)
http://raspberrypi.local:1880


or

http://<PI_IP_ADDRESS>:1880

## Windows PC – Node-RED as a service
### 1 Install Node.js + Node-RED

Install Node.js LTS

Then:

npm install -g --unsafe-perm node-red
node-red --version

### 2 Create Node-RED working directory
New-Item -ItemType Directory -Path "C:\NodeRED" -Force
New-Item -ItemType Directory -Path "C:\NodeRED\logs" -Force
New-Item -ItemType Directory -Path "C:\NodeRED\scripts" -Force


Copy:

C:\Users\<YOU>\.node-red\settings.js
→ C:\NodeRED\settings.js

### 3 Create start script

C:\NodeRED\start-node-red.bat

@echo off
cd /d C:\NodeRED

set LOGFILE=C:\NodeRED\logs\nodered.log

"C:\Users\<YOU>\AppData\Roaming\npm\node-red.cmd" ^
 --settings C:\NodeRED\settings.js ^
 -u C:\NodeRED ^
 -p 1880 >> "%LOGFILE%" 2>&1


Test:

C:\NodeRED\start-node-red.bat


Verify:

http://localhost:1880

### 4 Run Node-RED as a Windows service (NSSM)

Admin PowerShell:

nssm install NodeRED


Application

Path: C:\Windows\System32\cmd.exe

Arguments: /c C:\NodeRED\start-node-red.bat

Startup dir: C:\NodeRED

Log On

Run as your user account (required for GUI apps)

Start service:

nssm start NodeRED
nssm status NodeRED

## Windows Node-RED flows (PC endpoints)
Endpoints

POST /pc/productivity

POST /pc/gaming

### Exec commands

Productivity

powershell.exe -ExecutionPolicy Bypass -File "C:\NodeRED\scripts\productivity.ps1"


Gaming

powershell.exe -ExecutionPolicy Bypass -File "C:\NodeRED\scripts\gaming.ps1"

Flow wiring (both modes)
[http in] → [exec] → [change: {"status":"ok"}] → [http response]

Test locally
curl -X POST http://localhost:1880/pc/productivity
curl -X POST http://localhost:1880/pc/gaming

## Raspberry Pi Node-RED flows (trigger endpoints)
Endpoints

POST /trigger/productivity

POST /trigger/gaming

Behavior

Log trigger

Forward to PC

Return fast 200 OK to iPhone

### Flow wiring
[http in /trigger/{mode}]
 → [function: log trigger]
 → [http request → PC]
 → [change: {"status":"accepted"}]
 → [http response]

## iPhone NFC Shortcuts

Create two NFC automations:

### Productivity Tag

URL:

http://<PI_IP>:1880/trigger/productivity


Method: POST

Ask Before Running: OFF

### Gaming Tag

URL:

http://<PI_IP>:1880/trigger/gaming


Method: POST

Ask Before Running: OFF

## End-to-end verification checklist

✔ Pi Node-RED service running
✔ PC Node-RED service running
✔ Manual PowerShell scripts work
✔ curl to PC endpoints works
✔ curl to Pi trigger endpoints works
✔ NFC tags trigger correct mode

If manual + NFC both work, the system is healthy.

## Repo artifacts to keep in sync

flows/pi/productivity.json

flows/pi/gaming.json

flows/pc/productivity.json

flows/pc/gaming.json

scripts/productivity.ps1

scripts/gaming.ps1

shortcuts/*.shortcut
