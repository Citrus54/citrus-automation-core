# scripts/productivity.ps1
# "Productivity Mode" automation script for Windows PC.
# Called by Node-RED via an Exec node.

# --- 1. Launch browser (DuckDuckGo) ---

# NOTE: Adjust this path if DuckDuckGo is installed elsewhere.
$duckduckgoPath = "C:\Program Files\DuckDuckGo\DuckDuckGo.exe"

if (Test-Path $duckduckgoPath) {
    Start-Process $duckduckgoPath
} else {
    Write-Output "DuckDuckGo not found at $duckduckgoPath"
}

# --- 2. Future extensions (placeholders) ---

# Example: open a notes app
# $notesPath = "C:\Program Files\SomeNotesApp\Notes.exe"
# if (Test-Path $notesPath) {
#     Start-Process $notesPath
# }

# Example: open a specific website in default browser
# Start-Process "https://todoist.com/app"

# Example: start a local editor / IDE
# $codePath = "C:\Users\Curtis\AppData\Local\Programs\Microsoft VS Code\Code.exe"
# if (Test-Path $codePath) {
#     Start-Process $codePath
# }

# End of script
``` 
When you want Node-RED to use this script instead of a raw command, the PC Exec node’s Command will become:
powershell.exe -ExecutionPolicy Bypass -File "C:\NodeRED\scripts\productivity.ps1"
