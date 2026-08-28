$ErrorActionPreference = 'Stop'
$packageRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$tailscaleInstaller = Join-Path $packageRoot 'Tailscale.msi'
$networkSetup = Join-Path $packageRoot 'Brainok-Network-Setup.exe'
$clientSource = Join-Path $packageRoot 'Client'
$clientExecutable = Join-Path $clientSource 'SmartDicomClient.Win.exe'
$installRoot = Join-Path $env:LOCALAPPDATA 'Brainok\SMART DICOM Client'

function Require-File([string]$path) {
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
        throw "Required installation file is missing: $path"
    }
}

Require-File $tailscaleInstaller
Require-File $networkSetup
Require-File $clientExecutable

Write-Host ''
Write-Host 'SMART DICOM Client installation' -ForegroundColor Cyan
Write-Host ''

if (-not (Test-Path -LiteralPath "$env:ProgramFiles\Tailscale\tailscale.exe" -PathType Leaf)) {
    Write-Host 'Installing Tailscale...'
    $tailscale = Start-Process -FilePath 'msiexec.exe' -ArgumentList @('/i', "`"$tailscaleInstaller`"", '/norestart') -Wait -PassThru
    if ($tailscale.ExitCode -notin 0, 3010) {
        throw "Tailscale installation failed. Exit code: $($tailscale.ExitCode)"
    }
}

Write-Host 'Connecting this PC to Brainok...'
$network = Start-Process -FilePath $networkSetup -Wait -PassThru
if ($network.ExitCode -ne 0) {
    throw "Brainok Network Setup was not completed. Exit code: $($network.ExitCode)"
}

Write-Host 'Installing SMART DICOM Client...'
New-Item -ItemType Directory -Path $installRoot -Force | Out-Null
Copy-Item -LiteralPath (Join-Path $clientSource '*') -Destination $installRoot -Recurse -Force

$shortcutPath = Join-Path $env:APPDATA 'Microsoft\Windows\Start Menu\Programs\SMART DICOM Client.lnk'
$shell = New-Object -ComObject WScript.Shell
$shortcut = $shell.CreateShortcut($shortcutPath)
$shortcut.TargetPath = Join-Path $installRoot 'SmartDicomClient.Win.exe'
$shortcut.WorkingDirectory = $installRoot
$shortcut.Description = 'SMART DICOM Client'
$shortcut.Save()

Write-Host 'Installation complete.' -ForegroundColor Green
Start-Process -FilePath (Join-Path $installRoot 'SmartDicomClient.Win.exe') -WorkingDirectory $installRoot
