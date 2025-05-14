# Set Windows Firewall rules and port proxy settings for WSL2
function EnableRules {
    @(19351, 1935, 19352, 19353) | % { netsh interface portproxy add v4tov4 listenport=$_ listenaddress=0.0.0.0 connectport=$_ connectaddress=172.17.170.168 }
    New-NetFirewallRule -DisplayName "Allow WSL2 Outbound" -Direction Outbound -LocalPort 1935 -Protocol TCP -Action Allow
    New-NetFirewallRule -DisplayName "Allow WSL2 Inbound" -Direction Inbound -LocalPort 1935 -Protocol TCP -Action Allow -RemoteAddress LocalSubnet
}
function DisableRules {
    @(19351, 1935, 19352, 19353) | % { netsh interface portproxy delete v4tov4 listenport=$_ listenaddress=0.0.0.0 }
    Get-NetFirewallRule -DisplayName "Allow WSL2 Outbound" | Remove-NetFirewallRule
    Get-NetFirewallRule -DisplayName "Allow WSL2 Inbound" | Remove-NetFirewallRule
}
$userInput = Read-Host -Prompt 'Enter 1 to Enable or 2 to Disable'
if ($userInput -eq '1') {
    EnableRules
} elseif ($userInput -eq '2') {
    DisableRules
} else {
    Write-Host 'Invalid input. Please enter 1 to Enable or 2 to Disable.'
}
shutdown.exe /r /t 0