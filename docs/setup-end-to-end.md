# Citrus Automation Core – End-to-End Setup

This guide shows how to rebuild the **entire NFC → iPhone → Raspberry Pi → Windows PC** automation from scratch.

It’s written so that you can follow it step by step.


---

## 1. What the system does (big picture)

**Goal demo:**

> Tap NFC tag on iPhone → iPhone calls Pi → Pi calls PC → PC runs “Productivity mode” (currently: opens DuckDuckGo; later: full routine).

High-level flow:

```text
[NFC Tag tapped on iPhone]
       ↓
[iOS Shortcut: POST /trigger/productivity → Pi]
       ↓
[Raspberry Pi Node-RED: POST /pc/productivity → PC]
       ↓
[Windows Node-RED: runs PowerShell → opens apps]
```
You will set up:

Node-RED on the Raspberry Pi (as a systemd service)

Node-RED on Windows (as an NSSM service)

HTTP flow on the Pi: /trigger/productivity

HTTP flow on Windows: /pc/productivity

iOS Shortcut bound to an NFC tag that calls the Pi

## 2. Prerequisites

You need:

Raspberry Pi

Raspberry Pi OS installed

Connected to your home Wi-Fi

Windows 11 PC

iPhone

Supports NFC

Has the Shortcuts app

Basic tools:

SSH client on Windows (PowerShell or Windows Terminal)

Browser on Windows (Edge, Chrome, etc.)

## 3. Raspberry Pi – Node-RED setup
### 3.1 SSH into the Pi

On your Windows PC:

Open Windows Terminal or PowerShell.

Run:

ssh pi@raspberrypi.local


If that doesn’t work, find the Pi’s IP address from your router and run:

ssh pi@<PI_IP_ADDRESS>


When prompted:

Default username: pi

Default password: raspberry (or whatever you set).

Check that you are on the Pi:

hostname
Expected: raspberry

### 3.2 Ensure Node-RED is installed and running as a service

Most modern Raspberry Pi OS images come with Node-RED pre-installed and a service already defined.

Check status:

sudo systemctl status nodered


If you see Active: active (running) → good.

If it’s not active:

Enable and start it:

sudo systemctl enable nodered
sudo systemctl start nodered


Confirm again:

sudo systemctl status nodered


You should see it active (running).

### 3.3 Open Node-RED editor on the Pi

On your Windows PC:

Open your browser.

Go to:

http://raspberrypi.local:1880


If that fails, use the Pi’s IP:

http://<PI_IP_ADDRESS>:1880


You should see the Node-RED web editor.

The Pi side is now ready.

## 4. Windows PC – Node-RED and service setup
### 4.1 Install Node.js and Node-RED

Install Node.js LTS from the official website (nodejs.org).

After Node.js is installed, open PowerShell and run:

npm install -g --unsafe-perm node-red


Verify:

node-red --version

### 4.2 Create a dedicated Node-RED directory on Windows

You’ll keep Node-RED’s runtime files in C:\NodeRED so it’s clean and easy to manage.

In PowerShell:

New-Item -ItemType Directory -Path "C:\NodeRED" -Force
New-Item -ItemType Directory -Path "C:\NodeRED\logs" -Force


Now copy the default Node-RED settings file:

Open File Explorer.

Go to:

C:\Users\<YOUR_WINDOWS_USERNAME>\.node-red\


Copy settings.js.

Paste it into:

C:\NodeRED\


Now C:\NodeRED\settings.js exists.

### 4.3 Create start-node-red.bat

This batch file will:

Change into C:\NodeRED

Start Node-RED pointing at C:\NodeRED

Log output to C:\NodeRED\logs\nodered.log

In Notepad, paste this:

@echo off
cd /d C:\NodeRED

set LOGFILE=C:\NodeRED\logs\nodered.log

"C:\Users\<YOUR_WINDOWS_USERNAME>\AppData\Roaming\npm\node-red.cmd" ^
  --settings C:\NodeRED\settings.js ^
  -u C:\NodeRED ^
  -p 1880 >> "%LOGFILE%" 2>&1


Replace <YOUR_WINDOWS_USERNAME> with your actual Windows username.

Keep the ^ line breaks as they are.

Save the file as:

C:\NodeRED\start-node-red.bat


Test it:

Open PowerShell.

Run:

C:\NodeRED\start-node-red.bat


Wait a few seconds.

In your browser, go to:

http://localhost:1880


If the Node-RED editor loads, the script works.

Stop Node-RED for now by closing the PowerShell window if it’s still running interactively.

### 4.4 Run Node-RED as a Windows service with NSSM

You want Node-RED to:

Start when Windows starts

Run in the background

Not require you to open a terminal

You use NSSM (Non-Sucking Service Manager) for this.

Download NSSM and ensure nssm.exe is on your PATH (or place it in a folder like C:\Windows\System32 if you know what you’re doing).

Open PowerShell as Administrator (Run as admin).

Run:

nssm install NodeRED


In the NSSM GUI:

Application tab:

Path:
C:\Windows\System32\cmd.exe

Startup directory:
C:\NodeRED

Arguments:
/c C:\NodeRED\start-node-red.bat

Log on tab:

Select “This account”

Enter your Windows username and password
(so Node-RED runs as you, and can open GUI apps like browsers).

(Optional) I/O tab:

Stdout: C:\NodeRED\logs\nodered-out.log

Stderr: C:\NodeRED\logs\nodered-err.log

Click Install service.

Back in admin PowerShell:

nssm start NodeRED
nssm status NodeRED


Status should show: SERVICE_RUNNING.

Confirm Node-RED is reachable:

In browser:

http://localhost:1880


Now Node-RED runs as a service and starts with Windows.

## 5. Windows Node-RED flow – /pc/productivity

This is the endpoint the Pi will call.

### 5.1 Create the flow

In a browser on Windows, open:

http://localhost:1880


In Node-RED, create a new flow tab (or use the default).

Drag in these nodes from the left sidebar:

http in

exec

change

http response

### 5.2 Configure HTTP In node (PC endpoint)

Double-click the HTTP In node.

Set:

Method: POST

URL: /pc/productivity

Name: PC Productivity (POST)

Click Done.

### 5.3 Configure Exec node (launch DuckDuckGo or script)

For the simple version (direct browser launch):

Double-click the Exec node.

Set:

Command:

powershell.exe -Command "Start-Process 'C:\Program Files\DuckDuckGo\DuckDuckGo.exe'"


Append: unchecked

Output: “when the command is started” (or “none”)

Later, you can change this to call a PowerShell script:

powershell.exe -ExecutionPolicy Bypass -File "C:\NodeRED\scripts\productivity.ps1"

### 5.4 Configure Change node (set JSON response)

Double-click the Change node.

Rule:

Set msg.payload

To (JSON):

{"status":"ok"}


Click Done.

### 5.5 Configure HTTP Response node

Default settings are fine (status 200).

Just leave it as is.

### 5.6 Wire the nodes

Connect them in this order:

[http in /pc/productivity] → [exec] → [change set payload] → [http response]

### 5.7 Deploy and test

Click the Deploy button (top right).

In Windows PowerShell, run:

curl -X POST http://localhost:1880/pc/productivity


Expected behavior:

DuckDuckGo browser opens.

Node-RED shows a successful request in the debug logs (if you added debug nodes).

This confirms the PC endpoint works.

## 6. Raspberry Pi Node-RED flow – /trigger/productivity

This is what the iPhone calls. The Pi forwards the request to the PC.

### 6.1 Create the Pi flow

On your Windows PC, open:

http://raspberrypi.local:1880


or

http://<PI_IP_ADDRESS>:1880


In Node-RED on the Pi, create a new flow (or use one tab).

Drag in:

http in

function

http request

change

http response

### 6.2 Configure HTTP In node (Pi endpoint)

Double-click HTTP In.

Set:

Method: POST

URL: /trigger/productivity

Name: Trigger Productivity

Click Done.

### 6.3 Configure Function node (log / basic validation)

Double-click function node.

Paste:

node.warn("Productivity trigger received from iPhone");
return msg;


Click Done.

### 6.4 Configure HTTP Request node (send to PC)

Double-click http request node.

Set:

Method: POST

URL: http://<PC_IP_ADDRESS>:1880/pc/productivity

Return: a JSON object or UTF-8 string (either is fine).

Click Done.

### 6.5 Configure Change node (Pi → iPhone response)

Double-click change node.

Set:

Set msg.payload

To (JSON):

{"status":"accepted"}


Click Done.

### 6.6 Configure HTTP Response node

Leave as default (200 OK).

### 6.7 Wire the nodes

Connect in this order:

[http in /trigger/productivity]
    → [function: log]
    → [http request: Send to PC]
    → [change: set payload]
    → [http response]

### 6.8 Deploy and test

Click Deploy on the Pi Node-RED editor.

From the Pi terminal (SSH session), run:

curl -X POST http://localhost:1880/trigger/productivity


Expected:

Pi logs Productivity trigger received from iPhone in Node-RED logs.

PC Node-RED receives /pc/productivity.

DuckDuckGo opens on the PC.

Now the Pi → PC chain is working.

## 7. iPhone NFC Shortcut – calling the Pi

This is where the physical NFC tag gets tied into the system.

### 7.1 Create the NFC automation

On your iPhone:

Open the Shortcuts app.

Tap the Automation tab at the bottom.

Tap the + button in the top-right.

Tap Create Personal Automation.

Scroll and choose NFC.

Tap Scan, hold the top of your iPhone over your NFC tag.

When it detects the tag, give it a name (e.g. Productivity Tag).

Tap Next to move to the “Actions” screen.

### 7.2 Add “Get Contents of URL” action

Tap Add Action.

In the search bar, type Get Contents of URL.

Tap the Get Contents of URL action to add it.

Tap the URL field and enter:

http://<PI_IP_ADDRESS>:1880/trigger/productivity


Tap the small arrow / “Show More”:

Method: POST

Request Body: none (you don’t need to send anything yet)

Tap Next.

Optionally, turn off Ask Before Running so it triggers immediately when you tap the NFC tag.

Tap Done.

### 7.3 Test the full chain

Now test everything end to end:

Make sure:

Pi Node-RED service is running (sudo systemctl status nodered should be active (running)).

Windows Node-RED NodeRED service (NSSM) is running (nssm status NodeRED should be SERVICE_RUNNING).

On the iPhone, tap the NFC tag.

Expected behavior:

Shortcut runs automatically.

iPhone sends POST /trigger/productivity to Pi.

Pi logs the trigger and sends POST /pc/productivity to PC.

PC opens DuckDuckGo.

If this works, the pipeline from NFC tag → iPhone → Pi → Windows PC is fully working.

## 8. Export artifacts into this repo (for documentation)

To archive the actual configuration used:

Export Pi flow as JSON → save as flows/pi/productivity.json in this repository.

Export PC flow as JSON → save as flows/pc/productivity.json.

Export iOS Shortcut as a file:

Productivity Tag.shortcut → save in shortcuts/.

(See shortcuts/ios-productivity-shortcut.md for reminder instructions on exporting.)

At that point, anyone reading this repo can:

Follow this guide to rebuild the system.

Import the JSON flows into Node-RED.

Import the .shortcut file into Shortcuts.

Have the same NFC automation running.
