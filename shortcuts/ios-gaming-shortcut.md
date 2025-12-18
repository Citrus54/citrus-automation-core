# iOS Shortcut – Gaming NFC Automation

This document explains how the Gaming iPhone Shortcut works and how to recreate it from scratch.
This Shortcut acts as the physical trigger in the automation pipeline:

NFC Tag → iPhone Shortcut → Raspberry Pi → Windows PC

The shortcut sends an HTTP POST request to the Pi, which then forwards the command to the PC to activate Gaming Mode.

## 🔹 Purpose

Activate “Gaming Mode” by tapping an NFC tag with the iPhone.

Current behavior:

Launches Steam

Launches Discord

Closes selected “work” apps (via PowerShell)

Future behavior:

Game-specific profiles

Audio / lighting modes

Focus / Do Not Disturb toggles

## 🔹 Shortcut Trigger

Trigger Type: NFC

Tag Example Name: Gaming Tag
 
Requires: Shortcut Automations enabled in iOS

This allows hands-free activation without opening the Shortcuts app.

## 🔹 Shortcut Actions (Step-by-Step)

Open Shortcuts

Tap Automation

Tap +

Tap Create Personal Automation

Select NFC

Tap Scan and hold the phone to the NFC tag

Name the tag → Gaming Tag

Tap Next

Tap Add Action

Add action: Get Contents of URL

Configure the action:

Setting	Value
URL	http://<PI_IP>:1880/trigger/gaming
Method	POST
Request Body	None

Tap Next

Toggle OFF Ask Before Running (recommended)

Tap Done

## 🔹 Expected Behavior
Step	Device	Behavior
Tap NFC tag	iPhone	Shortcut fires
Shortcut sends POST	Pi	Node-RED receives /trigger/gaming
Pi forwards request	PC	Node-RED calls /pc/gaming
PC executes script	Windows	Steam + Discord launch
## 🔹 Exporting the Shortcut (for repo upload)

Open Shortcuts → Shortcuts tab

Tap … on your Gaming Tag shortcut

Tap Share

Tap Options

Change from iCloud Link → File

Save to Files or send to your PC

Upload the file to:

shortcuts/Gaming Tag.shortcut


This .shortcut file contains the actual automation logic.
This .md file documents how it works.

## 🔹 Future Enhancements

Send payload JSON (e.g. { "mode": "gaming" })

Game-specific launch profiles

Discord status auto-set

PC audio / mic routing

Smart lights + RGB sync

Steam Big Picture auto-launch

If you want, next we can:

Add payload-based mode switching (single endpoint, multiple modes)

Lock productivity apps when gaming mode runs

Normalize both shortcuts into one reusable template
