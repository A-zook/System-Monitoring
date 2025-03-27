# =========================
# Automated System Management Script
# =========================

# Define log file location
$logFile = "C:\Monitoring\system_automation_log.txt"
$date = Get-Date -Format "yyyy.MM.dd_HH:mm:ss"

# Function to log messages
function Write-Log {
    param (
        [string]$message
    )
    $logEntry = "$date - $message"
    Add-Content -Path $logFile -Value $logEntry
    Write-Host $logEntry
}

# ------------------------------------
# Objective 1: System Monitoring
# ------------------------------------
function Monitor-System {
    Write-Log "Starting System Monitoring..."

    # CPU Usage
    $cpu = (Get-Counter '\Processor(_Total)\% Processor Time').CounterSamples.CookedValue
    $cpu = [math]::round($cpu,2)

    # Memory Usage
    $mem = (Get-Counter '\Memory\Available MBytes').CounterSamples.CookedValue

    # Disk Usage
    $disk = Get-WmiObject Win32_PerfRawData_PerfDisk_LogicalDisk | Where-Object { $_.Name -like "C*" }
    $diskQueue = $disk.CurrentDiskQueueLength
    $DBytes = $disk.DiskBytesPerSec
    $DRead = $disk.DiskReadBytesPerSec
    $DWrite = $disk.DiskWriteBytesPerSec

    # Log output
    Write-Log "CPU: $cpu%, Memory: $mem MB, Disk Queue: $diskQueue, Disk Read: $($DRead/1000) KB/s, Disk Write: $($DWrite/1000) KB/s"
}

# ------------------------------------
# Objective 2: Log Analysis
# ------------------------------------
function Analyze-Logs {
    Write-Log "Analyzing Event Logs for Failed Logins..."

    try {
        $failedLogins = Get-EventLog -LogName Security -InstanceId 4625 -ErrorAction SilentlyContinue
        if ($failedLogins) {
            $failedLogins | Select-Object TimeGenerated, Message | Format-Table -AutoSize | Out-String | Write-Log
        } else {
            Write-Log "No failed logins found."
        }
    } catch {
        Write-Log "Failed to analyze logs. Error: $_"
    }
}

# ------------------------------------
# Objective 3: Performance Optimization
# ------------------------------------
function Optimize-Performance {
    Write-Log "Optimizing System Performance..."

    # Clear Temp Files
    Write-Log "Cleaning up temporary files..."
    Remove-Item -Path "C:\Windows\Temp\*" -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item -Path "$env:TEMP\*" -Recurse -Force -ErrorAction SilentlyContinue

    # Restart Critical Services (Example: Spooler and Windows Update)
    Write-Log "Restarting necessary services..."
    Restart-Service -Name "Spooler" -Force -ErrorAction SilentlyContinue
    Restart-Service -Name "wuauserv" -Force -ErrorAction SilentlyContinue

    # Install Windows Updates
    Write-Log "Installing pending updates..."
    Install-Module PSWindowsUpdate -Force
    Get-WindowsUpdate -Install -AcceptAll -AutoReboot | Out-String | Write-Log
}

# ------------------------------------
# Objective 4: Security Hardening and Compliance
# ------------------------------------
function Harden-Security {
    Write-Log "Applying Security Hardening..."

    # Firewall Configuration
    Write-Log "Configuring Firewall Rules..."
    New-NetFirewallRule -DisplayName "Allow RDP Internal" -Direction Inbound -LocalPort 3389 -Protocol TCP -Action Allow -Profile Domain -ErrorAction SilentlyContinue

    # Remove Unauthorized Admins
    Write-Log "Checking Local Administrators..."
    $localAdmins = Get-LocalGroupMember -Group "Administrators"
    foreach ($admin in $localAdmins) {
        if ($admin.Name -notlike "*Administrator*" -and $admin.Name -ne "$env:COMPUTERNAME\$env:USERNAME") {
            Write-Log "Removing unauthorized admin: $($admin.Name)"
            Remove-LocalGroupMember -Group "Administrators" -Member $admin.Name -ErrorAction SilentlyContinue
        }
    }

    # Disable Unused Services
    Write-Log "Disabling unused services..."
    Stop-Service -Name 'wuauserv' -Force -ErrorAction SilentlyContinue
    Set-Service -Name 'wuauserv' -StartupType Disabled

    # Enforce Password Policy
    Write-Log "Setting password policies..."
    net accounts /maxpwage:60
    net accounts /lockoutthreshold:5
}

# ------------------------------------
# MAIN EXECUTION
# ------------------------------------
Write-Log "==== STARTING SYSTEM MANAGEMENT SCRIPT ===="
Monitor-System
Analyze-Logs
Optimize-Performance
Harden-Security
Write-Log "==== SYSTEM MANAGEMENT SCRIPT COMPLETED ===="

# ------------------------------------
# AUTOMATION (Schedule Task)
# ------------------------------------
# Create Scheduled Task using Task Scheduler:
# Example command to create a task:
# schtasks /create /tn "System_Monitoring" /tr "powershell.exe -ExecutionPolicy Bypass -File C:\Scripts\system_monitoring.ps1" /sc daily /st 00:00
