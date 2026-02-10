param(
    [Parameter(Mandatory = $true)]
    [ValidateSet("enable", "disable", "status", "rollback")]
    [string]$Action,

    [int]$Port = 19876,
    [string]$ListenAddress = "127.0.0.1",
    [string]$Distro,
    [switch]$EnableFirewall,
    [string]$StatePath = "$PSScriptRoot/.state/wsl-localhost-bridge-state.json"
)

$ErrorActionPreference = "Stop"

function Test-IsAdmin {
    $current = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($current)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Ensure-Admin {
    if (-not (Test-IsAdmin)) {
        throw "This script requires an elevated PowerShell (Run as Administrator)."
    }
}

function Ensure-StateDir {
    $dir = Split-Path -Parent $StatePath
    if (-not (Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
    }
}

function Save-State($data) {
    Ensure-StateDir
    $data | ConvertTo-Json -Depth 5 | Set-Content -Path $StatePath -Encoding UTF8
}

function Load-State {
    if (-not (Test-Path $StatePath)) {
        throw "No state file found: $StatePath"
    }
    return Get-Content -Raw -Path $StatePath | ConvertFrom-Json
}

function Get-WslDistro {
    if ($Distro) {
        return $Distro
    }
    $default = (& wsl.exe -l -q 2>$null | Select-Object -First 1).Trim()
    if (-not $default) {
        throw "Could not detect a WSL distro. Pass -Distro explicitly."
    }
    return $default
}

function Get-WslIp([string]$targetDistro) {
    $raw = (& wsl.exe -d $targetDistro hostname -I 2>$null)
    if (-not $raw) {
        throw "Could not resolve WSL IP for distro '$targetDistro'."
    }
    $ips = $raw.Trim().Split(" ", [System.StringSplitOptions]::RemoveEmptyEntries)
    foreach ($ip in $ips) {
        if ($ip -match "^\d{1,3}(\.\d{1,3}){3}$") {
            return $ip
        }
    }
    throw "No IPv4 address found for distro '$targetDistro'."
}

function Get-BridgeRule {
    $output = & netsh interface portproxy show v4tov4
    $pattern = "^\s*$ListenAddress\s+$Port\s+(\S+)\s+(\d+)\s*$"
    foreach ($line in $output) {
        if ($line -match $pattern) {
            return [pscustomobject]@{
                ConnectAddress = $Matches[1]
                ConnectPort = [int]$Matches[2]
            }
        }
    }
    return $null
}

function Add-Or-UpdateBridge([string]$wslIp) {
    $existing = Get-BridgeRule
    if ($existing -and $existing.ConnectAddress -eq $wslIp -and $existing.ConnectPort -eq $Port) {
        Write-Host "Bridge already configured: $ListenAddress`:$Port -> $wslIp`:$Port"
        return
    }

    if ($existing) {
        & netsh interface portproxy delete v4tov4 listenaddress=$ListenAddress listenport=$Port | Out-Null
    }

    & netsh interface portproxy add v4tov4 listenaddress=$ListenAddress listenport=$Port connectaddress=$wslIp connectport=$Port | Out-Null
    Write-Host "Bridge enabled: $ListenAddress`:$Port -> $wslIp`:$Port"
}

function Remove-Bridge {
    $existing = Get-BridgeRule
    if (-not $existing) {
        Write-Host "No bridge found for $ListenAddress`:$Port"
        return
    }
    & netsh interface portproxy delete v4tov4 listenaddress=$ListenAddress listenport=$Port | Out-Null
    Write-Host "Bridge removed for $ListenAddress`:$Port"
}

function Get-FirewallRuleName {
    return "WSL OAuth Bridge TCP $Port"
}

function Ensure-FirewallRule {
    $name = Get-FirewallRuleName
    $existing = Get-NetFirewallRule -DisplayName $name -ErrorAction SilentlyContinue
    if (-not $existing) {
        New-NetFirewallRule -DisplayName $name -Direction Inbound -Protocol TCP -Action Allow -LocalPort $Port | Out-Null
        Write-Host "Firewall rule added: $name"
    } else {
        Write-Host "Firewall rule already exists: $name"
    }
}

function Remove-FirewallRule {
    $name = Get-FirewallRuleName
    $existing = Get-NetFirewallRule -DisplayName $name -ErrorAction SilentlyContinue
    if ($existing) {
        Remove-NetFirewallRule -DisplayName $name | Out-Null
        Write-Host "Firewall rule removed: $name"
    }
}

Ensure-Admin

switch ($Action) {
    "enable" {
        $d = Get-WslDistro
        $ip = Get-WslIp -targetDistro $d
        $before = Get-BridgeRule

        Save-State @{
            timestamp = (Get-Date).ToString("o")
            action = "enable"
            distro = $d
            listenAddress = $ListenAddress
            port = $Port
            previousRule = $before
            firewallManaged = [bool]$EnableFirewall
        }

        Add-Or-UpdateBridge -wslIp $ip
        if ($EnableFirewall) {
            Ensure-FirewallRule
        }
    }
    "disable" {
        $before = Get-BridgeRule
        Save-State @{
            timestamp = (Get-Date).ToString("o")
            action = "disable"
            listenAddress = $ListenAddress
            port = $Port
            previousRule = $before
            firewallManaged = $true
        }

        Remove-Bridge
        Remove-FirewallRule
    }
    "status" {
        $d = Get-WslDistro
        $ip = Get-WslIp -targetDistro $d
        $rule = Get-BridgeRule
        $fw = Get-NetFirewallRule -DisplayName (Get-FirewallRuleName) -ErrorAction SilentlyContinue

        if (-not $rule) {
            Write-Host "Status: disabled"
        } elseif ($rule.ConnectAddress -eq $ip -and $rule.ConnectPort -eq $Port) {
            Write-Host "Status: enabled"
        } else {
            Write-Host "Status: drifted"
        }

        Write-Host "WSL distro: $d"
        Write-Host "WSL IP: $ip"
        if ($rule) {
            Write-Host "Bridge: $ListenAddress`:$Port -> $($rule.ConnectAddress):$($rule.ConnectPort)"
        }
        Write-Host ("Firewall rule: " + ($(if ($fw) {"present"} else {"absent"})))
    }
    "rollback" {
        $state = Load-State
        if ($state.listenAddress -ne $ListenAddress -or [int]$state.port -ne $Port) {
            throw "State file does not match current ListenAddress/Port."
        }

        if ($null -eq $state.previousRule) {
            Remove-Bridge
        } else {
            $prevAddr = $state.previousRule.ConnectAddress
            $prevPort = [int]$state.previousRule.ConnectPort
            & netsh interface portproxy delete v4tov4 listenaddress=$ListenAddress listenport=$Port | Out-Null
            & netsh interface portproxy add v4tov4 listenaddress=$ListenAddress listenport=$Port connectaddress=$prevAddr connectport=$prevPort | Out-Null
            Write-Host "Bridge restored: $ListenAddress`:$Port -> $prevAddr`:$prevPort"
        }

        if ($state.firewallManaged -eq $true) {
            Ensure-FirewallRule
        } else {
            Remove-FirewallRule
        }
    }
}
