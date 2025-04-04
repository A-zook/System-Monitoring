# ================================
# LOG ANALYSIS SCRIPT
# ================================

# Get Current Date
$date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

# Define Output Log File
$logFile = "C:\Logs\log_analysis_$((Get-Date).ToString('yyyyMMdd')).csv"

# Create Directory if it doesn't exist
if (!(Test-Path "C:\Logs")) {
    New-Item -ItemType Directory -Path "C:\Logs"
}

# -------------------------
# 1. Failed Login Attempts
# -------------------------
#Searches for failed login attempts (Event ID 4625) in the Windows Security log.
#Extracts the timestamp (TimeGenerated), username (UserName), and event message (Message).
#Sorts results in descending order (latest failures first).

Write-Host "`n[+] Analyzing Failed Login Attempts..." -ForegroundColor Cyan
$failedLogins = Get-EventLog -LogName Security -InstanceId 4625 -ErrorAction SilentlyContinue | 
                Select-Object TimeGenerated, UserName, Message | 
                Sort-Object TimeGenerated -Descending

if ($failedLogins) {
    $failedLogins | Format-Table -AutoSize
} else {
    Write-Host "No Failed Login Attempts Found." -ForegroundColor Green
} #Displays the results in a table format if failures exist.  Otherwise, prints a success message in green.

# -------------------------
# 2. Successful Login Attempts
# -------------------------
#Looks for successful logins (Event ID 4624) in the security log.
#Retrieves the timestamp, username, and message.
#Sorts results by latest first.

Write-Host "`n[+] Analyzing Successful Login Attempts..." -ForegroundColor Cyan
$successfulLogins = Get-EventLog -LogName Security -InstanceId 4624 -ErrorAction SilentlyContinue | 
                    Select-Object TimeGenerated, UserName, Message | 
                    Sort-Object TimeGenerated -Descending

if ($successfulLogins) {
    $successfulLogins | Format-Table -AutoSize
} else {
    Write-Host "No Successful Login Attempts Found." -ForegroundColor Green
} #Displays successful logins if found, otherwise prints a green message.

# -------------------------
# 3. Service Failures
# -------------------------
#Gets all Windows services and filters for those that are stopped.
#Extracts service name, display name, and status.

Write-Host "`n[+] Analyzing Service Failures..." -ForegroundColor Cyan
$failedServices = Get-Service | Where-Object { $_.Status -eq 'Stopped' } |
                  Select-Object Name, DisplayName, Status

if ($failedServices) {
    $failedServices | Format-Table -AutoSize
} else {
    Write-Host "No Failed Services Found." -ForegroundColor Green
} #Displays stopped services or prints a green success message.

# -------------------------
# 4. Firewall Rule Violations
# -------------------------
#Retrieves all active firewall rules.
#Filters for rules that block traffic.
#Extracts display name, direction (inbound/outbound), and action (block/allow).

Write-Host "`n[+] Analyzing Firewall Rule Violations..." -ForegroundColor Cyan
$firewallRules = Get-NetFirewallRule -Enabled True | 
                 Where-Object { $_.Action -eq 'Block' } |
                 Select-Object DisplayName, Direction, Action

if ($firewallRules) {
    $firewallRules | Format-Table -AutoSize
} else {
    Write-Host "No Firewall Violations Detected." -ForegroundColor Green
} #Displays blocked rules if found, otherwise prints a green message.

# -------------------------
# 5. Save Logs to File
# -------------------------
Write-Host "`n[+] Saving Log Data to File..." -ForegroundColor Cyan
if (!(Test-Path $logFile)) {
    "Date,Failed_Logins,Successful_Logins,Failed_Services,Firewall_Violations" | Out-File -FilePath $logFile -Encoding UTF8
} #Checks if the log file exists. If not, it creates it with column headers:

$data = "$date,$($failedLogins.Count),$($successfulLogins.Count),$($failedServices.Count),$($firewallRules.Count)"
$data | Out-File -FilePath $logFile -Append -Encoding UTF8  #Formats the collected data into a CSV row. Appends it to the log file.

Write-Host "`n[+] Log Analysis Completed! Data saved to $logFile" -ForegroundColor Green
#Prints a completion message in green.
# ================================
# END OF SCRIPT
# ================================
