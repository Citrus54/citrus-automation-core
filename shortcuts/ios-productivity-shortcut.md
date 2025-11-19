# iOS Shortcut – Productivity NFC Automation

This document explains how the iPhone Shortcut works and how to recreate it from scratch. This Shortcut acts as the physical trigger in the automation pipeline:


## NFC Tag → iPhone Shortcut → Raspberry Pi → Windows PC
The shortcut sends an HTTP POST request to the Pi, which then forwards the command to the PC.

---

## **🔹 Purpose**

Activate “Productivity Mode” by tapping an NFC tag with the iPhone.  
Currently opens a browser on the PC; later will launch a full workflow.

---

## **🔹 Shortcut Trigger**

- Trigger Type: **NFC**
- Tag Example Name: `Productivity Tag`
- Requires: Shortcut Automation enabled in iOS

This allows hands-free activation without opening the Shortcuts app manually.

---

## **🔹 Shortcut Actions (Step-by-Step)**

1. Open **Shortcuts**
2. Tap **Automation**
3. Tap **+**
4. Tap **Create Personal Automation**
5. Select **NFC**
6. Tap **Scan** and hold the phone to the tag
7. Name the tag → e.g. `Productivity Tag`
8. Tap **Next**
9. Tap **Add Action**
10. Add action: **Get Contents of URL**
11. Configure:

| Setting | Value |
|--------|-------|
| URL | `http://<PI_IP>:1880/trigger/productivity` |
| Method | `POST` |
| Request Body | None |


12. Tap **Next**
13. Toggle OFF **Ask Before Running** (optional)
14. Tap **Done**

---

## **🔹 Expected Behavior**

| Step | Device | Behavior |
|------|--------|----------|
| Tap NFC tag | iPhone | Shortcut fires |
| Shortcut sends POST | Pi | Node-RED receives trigger |
| Pi forwards request | PC | Node-RED endpoint executes |
| PC executes script | Windows | DuckDuckGo opens |

---

## **🔹 Exporting the Shortcut (for repo upload)**

1. Open **Shortcuts → Shortcuts tab**
2. Tap **…** on your Productivity shortcut
3. Tap **Share**
4. Tap **Options**
5. Change from **iCloud Link** → **File**
6. Save to Files or send to your PC
7. Upload the file to the repo here:
   shortcuts/Productivity Tag.shortcut

This file contains the actual automation logic; this `.md` file documents how it works.

---

## **🔹 Future Enhancements**

- Trigger multiple modes based on time of day
- Send payload JSON to Pi (e.g., `{ "mode": "work" }`)
- Add Shortcut actions before/after HTTP request:
  - Start playlist
  - Toggle Focus Mode
  - Read back confirmation with Siri


