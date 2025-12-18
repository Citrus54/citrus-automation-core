$logFile = "C:\NodeRED\logs\gaming-run.log"

function Log {
    param([string]$Message)

    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $line = "$timestamp`t$Message"
    $line | Out-File -FilePath $logFile -Append -Encoding UTF8
    Write-Output $line
}

Log "=== Gaming Mode start ==="

# ---------------------------
# Helper: stop app if running
# ---------------------------
function Stop-AppIfRunning {
    param ([string]$ProcessName)

    try {
        $procs = Get-Process -Name $ProcessName -ErrorAction SilentlyContinue
    } catch {
        Log ("Error querying processes for {0}. {1}" -f $ProcessName, $_.Exception.Message)
        return
    }

    if ($procs) {
        foreach ($p in $procs) {
            try {
                Log ("Stopping {0} PID={1}" -f $p.ProcessName, $p.Id)
                Stop-Process -Id $p.Id -Force -ErrorAction Stop
            } catch {
                Log ("Failed stopping {0}: {1}" -f $p.ProcessName, $_.Exception.Message)
            }
        }
    } else {
        Log ("{0} not running." -f $ProcessName)
    }
}

# ---------------------------
# Close work apps
# ---------------------------
Stop-AppIfRunning "notepad"

# ---------------------------
# Launch Steam
# ---------------------------
$steamPath = "C:\Program Files (x86)\Steam\steam.exe"

if (Test-Path $steamPath) {
    Log "Launching Steam..."
    Start-Process -FilePath $steamPath
} else {
    Log "Steam not found at $steamPath"
}

# ---------------------------
# Launch Discord
# ---------------------------
$discordRoot = Join-Path $env:LOCALAPPDATA "Discord"

if (Test-Path $discordRoot) {
    $discordExe = Get-ChildItem $discordRoot -Recurse -Filter "Discord.exe" -ErrorAction SilentlyContinue |
                  Sort-Object LastWriteTime -Descending |
                  Select-Object -First 1

    if ($discordExe) {
        Log "Launching Discord..."
        Start-Process -FilePath $discordExe.FullName
    } else {
        Log "Discord.exe not found"
    }
} else {
    Log "Discord folder not found"
}

# ---------------------------
# Post-launch check
# ---------------------------
Start-Sleep 5

Get-Process steam, discord -ErrorAction SilentlyContinue |
ForEach-Object {
    Log ("Running: {0} PID={1}" -f $_.ProcessName, $_.Id)
}

Log "=== Gaming Mode done ==="
