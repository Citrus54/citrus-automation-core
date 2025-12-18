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

## Admin access on Windows (for NSSM)
. Connecting a Headless Raspberry Pi to the Internet (No Monitor / Keyboard)

Use this before Section 3 if the Pi has no display.

Option A (Preferred): Ethernet → Wi-Fi Setup via SSH

This is the fastest and least error-prone.

### 1 Connect via Ethernet

Plug the Raspberry Pi into your router with an Ethernet cable.

Power on the Pi.

Wait ~60 seconds.

### 2 SSH into the Pi

On your Windows PC:

ssh pi@raspberrypi.local


If that fails, find the IP from your router and use:

ssh pi@<PI_IP_ADDRESS>


Login credentials:

Username: pi

Password: whatever you set (default used to be raspberry)

Confirm:

hostname


Expected: raspberrypi

### 3 Connect Pi to Wi-Fi

Run:

sudo raspi-config


Navigate:

System Options
→ Wireless LAN
→ Enter Wi-Fi SSID
→ Enter Wi-Fi password


Exit raspi-config.

Restart networking or reboot:

sudo reboot


After reboot, unplug Ethernet.

Reconnect via Wi-Fi:

ssh pi@raspberrypi.local

Option B: Wi-Fi Preconfiguration (SD Card Method)

Use this before first boot.

### 1 Prepare SD Card

Insert the Raspberry Pi SD card into your PC.

Open the boot partition.

Create a file named:

wpa_supplicant.conf


Paste this (edit values):

country=US
ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev
update_config=1

network={
    ssid="YOUR_WIFI_NAME"
    psk="YOUR_WIFI_PASSWORD"
    key_mgmt=WPA-PSK
}


Save the file.

Create an empty file named:

ssh


(no extension)

Eject the SD card.

### 3 Boot and Connect

Insert SD card into Pi.

Power it on.

Wait ~1–2 minutes.

SSH in:

ssh pi@raspberrypi.local

### 4 Verify Internet Connectivity

On the Pi:

ip a


Confirm wlan0 has an IP.

Test outbound access:

ping -c 3 google.com


If this works, the Pi is online and ready.

0.5 Lock in Reliability (Recommended)

Ensure Wi-Fi reconnects automatically:

sudo systemctl enable dhcpcd
sudo systemctl restart dhcpcd

Optional but smart: assign the Pi a DHCP reservation in your router so its IP never changes.

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
