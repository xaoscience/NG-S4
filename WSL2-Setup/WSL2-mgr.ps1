# Backup, restore, and reset WSL2 instances
$user = "clone"
$backUpFolder = "WSL2_Backup"
$location = "C:\Users\$user\$backUpFolder"
$cmd1 = "echo '[user]\ndefault=$user\n\n[boot]\nsystemd=true' > /etc/wsl.conf"
function Backup {
    $N1 = Read-Host -Prompt "Distro name"
    $N1R = $N1.Split("_")[0]
    $timestamp = Get-Date -Format "dd_MM"
    $backupFile = "$location\$($N1)_$timestamp.tar"
    wsl --export $N1R $backupFile
    Write-Output "Backup completed."
}
function Restore {
    $N1 = Read-Host -Prompt 'Filename'
    $N1R = $N1.Split("_")[0]
    $timestamp = Get-Date -Format "hh'h'_dd_MM"
    $folderPath = Join-Path $env:LOCALAPPDATA ("Packages\WSL2_Instance_{0}_{1}" -f $N1R, $timestamp)
    New-Item -ItemType Directory -Force -Path $folderPath
    wsl --import $N1R $folderPath "$location\$N1.tar" --version 2
    wsl -d $N1R -u root sh -c "`"$cmd1`""
    wsl --shutdown
    Write-Output "Installed new WSL2 environment as $N1R from backup."
}
function Reset {
    $N1 = Read-Host -Prompt 'File or distro name'
    $N1R = $N1.Split("_")[0]
    wsl --unregister $N1R
    $timestamp = Get-Date -Format "hh'h'_dd_MM"
    $folderPath = Join-Path $env:LOCALAPPDATA ("Packages\WSL2_Instance_{0}_{1}" -f $N1R, $timestamp)
    New-Item -ItemType Directory -Force -Path $folderPath
    wsl --import $N1R $folderPath "$location\$N1.tar" --version 2
    wsl -d $N1R -u root sh -c "`"$cmd1`""
    wsl --shutdown
    Write-Output "Reset WSL2 environment $N1R from backup."
}
$userInput = Read-Host -Prompt 'Do you want to 1) Backup (.tar), 2) Restore (new instance) or 3) Reset? '
if ($userInput -eq '1') { Backup }
elseif ($userInput -eq '2') { Restore }
elseif ($userInput -eq '3') { Reset }
