param(
    [string]$ServerHost = 'zyst.taila65c71.ts.net',
    [int]$ServerPort = 4040
)

$ErrorActionPreference = 'Stop'
$tailscale = Join-Path $env:ProgramFiles 'Tailscale\tailscale.exe'
if (-not (Test-Path -LiteralPath $tailscale -PathType Leaf)) {
    throw 'Tailscale was installed, but tailscale.exe is missing. Restart Windows and run the installer again.'
}

function Get-TailscaleStatus {
    try { $json = & $tailscale status --json 2>$null }
    catch { return $null }
    if ($LASTEXITCODE -ne 0 -or -not $json) { return $null }
    try { return ($json | Out-String | ConvertFrom-Json) }
    catch { return $null }
}

$status = Get-TailscaleStatus
if ($null -eq $status -or $status.BackendState -ne 'Running') {
    Write-Host 'Connecting Tailscale. Complete sign-in in the browser if prompted.'
    & $tailscale up
    if ($LASTEXITCODE -ne 0) { throw 'Tailscale sign-in did not complete.' }

    for ($attempt = 0; $attempt -lt 30; $attempt++) {
        $status = Get-TailscaleStatus
        if ($null -ne $status -and $status.BackendState -eq 'Running') { break }
        Start-Sleep -Seconds 2
    }
    if ($null -eq $status -or $status.BackendState -ne 'Running') {
        throw 'Tailscale did not reach Connected state.'
    }
}

$tailnet = ([string]$status.MagicDNSSuffix).TrimEnd('.')
$expectedTailnet = $ServerHost.Substring($ServerHost.IndexOf('.') + 1)
if ($tailnet -ne $expectedTailnet) {
    throw "This PC is connected to '$tailnet', but Brainok uses '$expectedTailnet'. Join the Brainok Tailnet, then rerun setup. The existing Tailscale login was preserved."
}

& $tailscale set --accept-dns=true
if ($LASTEXITCODE -ne 0) { throw 'Could not enable Tailscale DNS on this PC.' }
try { Clear-DnsClientCache -ErrorAction Stop }
catch { ipconfig.exe /flushdns | Out-Null }

$health = "http://${ServerHost}:${ServerPort}/health"
for ($attempt = 1; $attempt -le 5; $attempt++) {
    try { & curl.exe --fail --silent --show-error --noproxy '*' --max-time 10 $health 2>$null | Out-Null }
    catch { }
    if ($LASTEXITCODE -eq 0) {
        Write-Host "Brainok server is reachable: $health"
        exit 0
    }
    if ($attempt -lt 5) { Start-Sleep -Seconds 3 }
}

try {
    $magicDns = Resolve-DnsName -Name $ServerHost -Server 100.100.100.100 -Type A -ErrorAction Stop |
        Where-Object { $_.IPAddress } | Select-Object -First 1 -ExpandProperty IPAddress
} catch { $magicDns = $null }
if (-not $magicDns) {
    throw "Tailscale MagicDNS cannot resolve $ServerHost. Verify the PC's Brainok Tailnet membership."
}
throw "MagicDNS resolved $ServerHost to $magicDns, but Windows could not reach $health. Check Windows DNS and network policy."
