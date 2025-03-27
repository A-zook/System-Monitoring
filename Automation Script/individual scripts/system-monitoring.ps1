# ================================
# SYSTEM MONITORING SCRIPT
# ================================

# Get Current Date
$date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

# Get CPU Usage
$cpuUsage = (Get-Counter '\Processor(_Total)\% Processor Time').CounterSamples.CookedValue
$cpuUsage = [math]::round($cpuUsage,2)

# Get Memory Usage
$memory = Get-CimInstance -ClassName Win32_OperatingSystem
$totalMemory = $memory.TotalVisibleMemorySize / 1MB
$freeMemory = $memory.FreePhysicalMemory / 1MB
$memoryUsage = (($totalMemory - $freeMemory) / $totalMemory) * 100
$memoryUsage = [math]::round($memoryUsage,2)

# Get Disk Usage
$diskUsage = Get-PSDrive -PSProvider FileSystem | 
    Select-Object Name, @{Name="UsedPercent"; Expression={[math]::round(($_.Used/($_.Used + $_.Free) * 100), 2)}}

# Display Data
Write-Host "`n[System Monitoring - $date]" -ForegroundColor Cyan
Write-Host "CPU Usage: $cpuUsage %" -ForegroundColor Yellow
Write-Host "Memory Usage: $memoryUsage %" -ForegroundColor Yellow
Write-Host "`nDisk Usage:" -ForegroundColor Yellow

$diskUsage | Format-Table -AutoSize

# Save Data to CSV
$logFile = "C:\Monitoring\system_monitor.csv"

# Check if file exists, if not create headers
if (!(Test-Path $logFile)) {
    "Date,CPU_Usage,Memory_Usage,Disk_Usage" | Out-File -FilePath $logFile -Encoding UTF8
}

# Write data to CSV
$data = "$date,$cpuUsage,$memoryUsage," + ($diskUsage | ForEach-Object { "$($_.Name)=$($_.UsedPercent)%" }) -join ";"
$data | Out-File -FilePath $logFile -Append -Encoding UTF8

Write-Host "`nMonitoring Data Saved to $logFile" -ForegroundColor Green

# ================================
# END OF SCRIPT
# ================================