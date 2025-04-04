# ================================
# PERFORMANCE OPTIMIZATION SCRIPT
# ================================

# Get Current Date
$date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

# Define Log File
$logFile = "C:\Logs\performance_optimization_$((Get-Date).ToString('yyyyMMdd')).log"

# Create Log Directory if it doesn't exist
if (!(Test-Path "C:\Logs")) {
    New-Item -ItemType Directory -Path "C:\Logs"
}

# -------------------------
# 1. Clean Temporary Files
# -------------------------
Write-Host "`n[+] Cleaning Temporary Files..." -ForegroundColor Cyan

# Clear Windows Temp Files
Remove-Item -Path "C:\Windows\Temp\*" -Recurse -Force -ErrorAction SilentlyContinue
Write-Host " - Windows Temp Files Cleaned"   #Deletes all files in C:\Windows\Temp*

# Clear User Temp Files
Remove-Item -Path "$env:TEMP\*" -Recurse -Force -ErrorAction SilentlyContinue
Write-Host " - User Temp Files Cleaned"   #Deletes all user temp files in $env:TEMP*

# Clear Recycle Bin
Clear-RecycleBin -Force -ErrorAction SilentlyContinue
Write-Host " - Recycle Bin Emptied"   #Clears the Recycle Bin

# -------------------------
# 2. Restart Critical Services
# -------------------------
Write-Host "`n[+] Restarting Critical Services..." -ForegroundColor Cyan

# Define Critical Services to Restart
$services = @("wuauserv", "bits", "lanmanserver", "cryptSvc")

foreach ($service in $services) {
    if ((Get-Service -Name $service).Status -eq 'Running') {
        Restart-Service -Name $service -Force -ErrorAction SilentlyContinue
        Write-Host " - Restarted $service" -ForegroundColor Green
    } else {
        Start-Service -Name $service -ErrorAction SilentlyContinue
        Write-Host " - Started $service" -ForegroundColor Green
    }
}   #Checks if each service is running. If running, Restart it. If stopped, Start it

# -------------------------
# 3. Install Patches (Windows Updates)
# -------------------------
#Installs all available updates
#Automatically accepts updates
#Auto-reboots if necessary

Write-Host "`n[+] Installing Windows Updates..." -ForegroundColor Cyan

# Install Windows Updates and Accept All
Install-Module PSWindowsUpdate -Force -ErrorAction SilentlyContinue
Get-WindowsUpdate -Install -AcceptAll -AutoReboot

Write-Host " - Windows Updates Installed" -ForegroundColor Green

# -------------------------
# 4. Log Results
# -------------------------
#Logs the optimization results into a file

Write-Host "`n[+] Saving Performance Data to File..." -ForegroundColor Cyan

$data = @"
Date: $date
Temporary Files Cleaned: Yes
Services Restarted: $($services -join ', ')
Windows Updates Installed: Yes
"@

$data | Out-File -FilePath $logFile -Append -Encoding UTF8

Write-Host "`n[+] Performance Optimization Completed! Log saved to $logFile" -ForegroundColor Green

# ================================
# END OF SCRIPT
# ================================
