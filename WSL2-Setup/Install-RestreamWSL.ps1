# WSL2 installation and initialisation
$distroName = "Ubuntu-22.04"
$wslUserName = "clone"
$scriptPath = $MyInvocation.MyCommand.Path
$scriptDir = Split-Path $scriptPath
$projectRootInWindows = Split-Path $scriptDir
$projectRootInWSL = "/mnt/" + ($projectRootInWindows -replace ':\\', '/' -replace '\\', '/')
$setupScriptPathInWSL = "$projectRootInWSL/UNIX-Scripts/setup-restream.sh"
$masterEnvPathInRealEnvWSL = "$projectRootInWSL/real.env/master.env"
$nginxConfPathInRealEnvWSL = "$projectRootInWSL/real.env/nginx.conf"
$stunnelConfPathInRealEnvWSL = "$projectRootInWSL/real.env/stunnel.conf"
$exampleMasterEnvPathInWindows = Join-Path $projectRootInWindows "example.env\master.env"
$exampleNginxConfPathInWindows = Join-Path $projectRootInWindows "example.env\nginx.conf"
$exampleStunnelConfPathInWindows = Join-Path $projectRootInWindows "example.env\stunnel.conf"
$realEnvDirInWindows = Join-Path $projectRootInWindows "real.env"
$realMasterEnvPathInWindows = Join-Path $realEnvDirInWindows "master.env"
$realNginxConfPathInWindows = Join-Path $realEnvDirInWindows "nginx.conf"
$realStunnelConfPathInWindows = Join-Path $realEnvDirInWindows "stunnel.conf"
function Invoke-WSLCommand {
    param(
        [string]$Command,
        [switch]$AsRoot
    )
    $wslCmd = "wsl -d $distroName"
    if ($AsRoot) {
        $wslCmd += " -u root"
    }
    $wslCmd += " -- $Command"
    Write-Host "Executing in WSL: $wslCmd"
    Invoke-Expression $wslCmd
}
function Check-WSLFeature {
    Write-Host "Checking if WSL feature is enabled..."
    $wslFeature = Get-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux
    if ($wslFeature.State -ne 'Enabled') {
        Write-Host "WSL feature is not enabled. Enabling..."
        Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux -NoRestart
        Write-Host "Virtual Machine Platform feature is not enabled. Enabling..."
        Enable-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform -NoRestart
        Write-Host "Please restart your computer to complete WSL installation and then re-run this script."
        exit
    } else {
        Write-Host "WSL feature is already enabled."
    }
}
function Install-Distro {
    Write-Host "Checking if $distroName is installed..."
    $installedDistros = wsl --list --quiet
    if ($installedDistros -notcontains $distroName) {
        Write-Host "$distroName is not installed. Attempting to install..."
        wsl --install -d $distroName --no-launch
        Write-Host "$distroName installation initiated. This may take some time."
        Write-Host "After installation, WSL might prompt you to create a user. You can use '$wslUserName' or set it up manually."
    } else {
        Write-Host "$distroName is already installed."
    }
}
function Ensure-RealEnvFiles {
    Write-Host "Ensuring real.env directory and configuration files exist..."
    if (-not (Test-Path $realEnvDirInWindows)) {
        Write-Host "Creating $realEnvDirInWindows directory."
        New-Item -ItemType Directory -Path $realEnvDirInWindows -Force | Out-Null
    }
    if (-not (Test-Path $realMasterEnvPathInWindows)) {
        Write-Host "$realMasterEnvPathInWindows not found. Copying from example.env..."
        Copy-Item -Path $exampleMasterEnvPathInWindows -Destination $realMasterEnvPathInWindows -Force
        Write-Host "IMPORTANT: Copied example master.env. Please edit $realMasterEnvPathInWindows with your actual stream keys and settings."
    }
    if (-not (Test-Path $realNginxConfPathInWindows)) {
        Write-Host "$realNginxConfPathInWindows not found. Copying from example.env..."
        Copy-Item -Path $exampleNginxConfPathInWindows -Destination $realNginxConfPathInWindows -Force
        Write-Host "IMPORTANT: Copied example nginx.conf. Please review and edit $realNginxConfPathInWindows if necessary."
    }
    if (-not (Test-Path $realStunnelConfPathInWindows)) {
        Write-Host "$realStunnelConfPathInWindows not found. Copying from example.env..."
        Copy-Item -Path $exampleStunnelConfPathInWindows -Destination $realStunnelConfPathInWindows -Force
        Write-Host "IMPORTANT: Copied example stunnel.conf. Please review and edit $realStunnelConfPathInWindows if necessary."
    }
    Write-Host "Please ensure all files in $realEnvDirInWindows are correctly configured before proceeding with the setup script inside WSL."
    Read-Host -Prompt "Press Enter to continue after verifying real.env files, or Ctrl+C to abort"
}
Write-Host "Starting WSL2 Restream Server Setup Utility..."
Check-WSLFeature
wsl --update
Install-Distro
Ensure-RealEnvFiles
Write-Host "Running the restream server setup script inside $distroName..."
Write-Host "This will require sudo privileges within WSL."
Invoke-WSLCommand -Command "chmod +x $setupScriptPathInWSL" -AsRoot
Invoke-WSLCommand -Command "sudo bash $setupScriptPathInWSL"
Write-Host "WSL Restream Server setup script execution finished."
Write-Host "Please check the output above for any errors or warnings."
Write-Host "You may need to configure Windows Firewall using wsl2UFW.ps1 if you haven't already."
Write-Host "Use WSL2-mgr.ps1 for backing up or restoring your WSL instance."
