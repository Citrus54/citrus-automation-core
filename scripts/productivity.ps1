$logFile = "C:\NodeRED\logs\productivity-run.log"

function Log {
    param([string]$Message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$timestamp`t$Message" | Out-File -FilePath $logFile -Append -Encoding UTF8
}

Write-Output "=== Productivity Mode start ==="
Log "=== Productivity Mode start ==="

# scripts/productivity.ps1
# "Productivity Mode" automation script for Windows PC.
# Called by Node-RED via an Exec node.

# --- 1. Launch browser (DuckDuckGo) ---

# NOTE: Adjust this path if DuckDuckGo is installed elsewhere.
$duckduckgoPath = "C:\Users\Curtis\AppData\Local\Microsoft\WindowsApps\DuckDuckGo.exe"
Log "Checking for DuckDuckGo at '$duckduckgoPath'"

if (Test-Path $duckduckgoPath) {
    Log "Starting DuckDuckGo..."
    try {
    	Start-Process $duckduckgoPath
	Log "DuckDuckGo launched successfully."
    }
    catch {
	Log "ERROR: Failed to start DuckDuckGo:  $($_.Exception.Message)"
    }
} else {
    Log "DuckDuckGo not found at $duckduckgoPath"
}

# ---------------------------
# 2. Launch Apple Music
# ---------------------------
$appleMusic = "shell:AppsFolder\AppleInc.AppleMusicWin_nzyj5cx40ttqa!App"

Log "Starting Apple Music using target '$appleMusic'..."

try {
    Start-Process $appleMusic
    Log "Apple Music launch requested successfully."
}
catch {
    Log "ERROR: Failed to start Apple Music: $($_.Exception.Message)"
}

# --- 3. Future extensions (placeholders) ---

# Example: open a notes app
# $notesPath = "C:\Windows\System32\notepad.exe"
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
Write-Output "=== Productivity Mode done ==="
Log "=== Productivity Mode done ==="
