#===================================
#SECURITY HARDENING AND COMPLIANCE
#=================================
#===================================
#Firewall Rules and Network Protection
#====================================
# List existing firewall rules
Write-Host "Checking Firewall Rules..."
Get-NetFirewallRule -Enabled True | Format-Table DisplayName, Direction, Action

# Ensure only specific ports are open (Example: RDP allowed internally only)
New-NetFirewallRule -DisplayName "Allow RDP Internal" -Direction Inbound -LocalPort 3389 -Protocol TCP -Action Allow -Profile Domain


#=====================================
#Local Administrator Accounts and Permissions
#============================================
# List Local Administrators
Write-Host "Checking Local Administrators..."
Get-LocalGroupMember -Group "Administrators" | Format-Table Name, PrincipalSource

# Remove unauthorized users from Admin group (Example: "TestUser")
Remove-LocalGroupMember -Group "Administrators" -Member "TestUser"


#======================================
#Disable Unused Services and Protocols
#========================================
# List running services
Write-Host "Listing Running Services..."
Get-Service | Where-Object { $_.Status -eq 'Running' } | Format-Table Name, DisplayName, Status

# Disable example service
Stop-Service -Name 'wuauserv' -Force
Set-Service -Name 'wuauserv' -StartupType Disabled


#============================================
#Enforce Password Policies and Account Lockouts
#=============================================
# Set password expiration policy (60 days)
net accounts /maxpwage:60

# Set lockout threshold (5 attempts)
net accounts /lockoutthreshold:5


#====================================
#System and Patch Compliance
#===================================
# Install security updates
Install-Module PSWindowsUpdate -Force
Get-WindowsUpdate -Install -AcceptAll -AutoReboot


#=========================================
#Audit Security Logs for Unusual Activity
#========================================
# List failed login attempts
Write-Host "Analyzing Failed Logins..."
Get-EventLog -LogName Security -InstanceId 4625 | Select-Object TimeGenerated, Message | Format-Table -AutoSize
#this code keeps generting errors for me tho
