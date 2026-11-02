#Requires -Version 5.1
<#
.SYNOPSIS
    WinRAR Activator - Version 2.2
.DESCRIPTION
    Advanced self-contained PowerShell utility supporting both local execution
    and instant remote execution via command line one-liner.
    Author  : k0ishiii
    Discord : misakisakura3
#>

[CmdletBinding()]
param(
    [ValidateSet('Cyan', 'Purple', 'Green', 'Red', 'Yellow')]
    [string]$Theme = 'Purple',

    [switch]$NoPause
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$ProgressPreference    = 'SilentlyContinue'

$script:AppTitle   = 'WinRAR Activator'
$script:AppVersion = 'v2.2'
$script:Author     = 'k0ishiii'
$script:Discord    = 'misakisakura3'

switch ($Theme) {
    'Cyan'   { $script:ColPrimary = 'Cyan';    $script:ColHeader = 'Cyan' }
    'Green'  { $script:ColPrimary = 'Green';   $script:ColHeader = 'Green' }
    'Red'    { $script:ColPrimary = 'Red';     $script:ColHeader = 'Red' }
    'Yellow' { $script:ColPrimary = 'Yellow';  $script:ColHeader = 'Yellow' }
    Default  { $script:ColPrimary = 'Magenta'; $script:ColHeader = 'Magenta' }
}

try {
    if ($Host.UI.RawUI) {
        $Host.UI.RawUI.WindowTitle = "{0} [{1}]" -f $script:AppTitle, $script:AppVersion
        $size = $Host.UI.RawUI.BufferSize
        $size.Width = 90
        $size.Height = 35
        $Host.UI.RawUI.BufferSize = $size
        $windowSize = $Host.UI.RawUI.WindowSize
        $windowSize.Width = 90
        $windowSize.Height = 35
        $Host.UI.RawUI.WindowSize = $windowSize
    }
} catch { }

function Write-Banner {
    Clear-Host
    $banner = @'
 _       ___                ___           _          _   _              
| |     / (_)___  ____ _   /   | ____________  (_)______  / /_____  _______ 
| | /| / / / __ \/ __ `/  / /| |/ ___/ ___/ / / / ___/ / __/ __ \/ ___/ _ \
| |/ |/ / / / / / /_/ /  / ___ / /__/ /  / /_/ / /__/ / /_/ /_/ / /  /  __/
|__/|__/_/_/ /_/\__,_/  /_/  |_\___/_/   \__,_/\___/_/\__/\____/_/   \___/ 
'@
    Write-Host $banner -ForegroundColor $script:ColHeader
    Write-Host "  ==========================================================================" -ForegroundColor DarkGray
    Write-Host ("   {0} [{1}]" -f $script:AppTitle, $script:AppVersion) -ForegroundColor $script:ColPrimary
    Write-Host ("   Author: {0}  |  Discord: {1}" -f $script:Author, $script:Discord) -ForegroundColor White
    Write-Host "  ==========================================================================" -ForegroundColor DarkGray
    Write-Host ''
}

function Write-Step { param([string]$Msg) Write-Host ("   [?] {0}" -f $Msg) -ForegroundColor DarkGray }
function Write-Ok   { param([string]$Msg) Write-Host ("   [+] {0}" -f $Msg) -ForegroundColor $script:ColPrimary }
function Write-Warn { param([string]$Msg) Write-Host ("   [!] {0}" -f $Msg) -ForegroundColor Yellow }
function Write-Fail { param([string]$Msg) Write-Host ("   [-] {0}" -f $Msg) -ForegroundColor Red }

function Invoke-Spinner {
    param(
        [string]$Message,
        [int]$Seconds = 2
    )
    $frames = @('|', '/', '-', '\')
    $sw = [Diagnostics.Stopwatch]::StartNew()
    $i = 0
    while ($sw.Elapsed.TotalSeconds -lt $Seconds) {
        $frame = $frames[$i++ % $frames.Length]
        Write-Host -NoNewline ("`r   [?] {0} [{1}] " -f $Message, $frame) -ForegroundColor DarkGray
        Start-Sleep -Milliseconds 100
    }
    Write-Host ("`r   [+] {0}... Completed.             " -f $Message) -ForegroundColor $script:ColPrimary
}

function Pause-IfInteractive {
    if ($NoPause) { return }
    if ([Environment]::UserInteractive) {
        Write-Host ''
        Write-Host '  ==========================================================================' -ForegroundColor DarkGray
        Write-Host '   Press any key to exit the activator window...' -ForegroundColor White
        Write-Host '  ==========================================================================' -ForegroundColor DarkGray
        try { [void]$Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown') } catch { Start-Sleep -Seconds 3 }
    }
}

function Test-Admin {
    $id = [Security.Principal.WindowsIdentity]::GetCurrent()
    $pr = New-Object Security.Principal.WindowsPrincipal($id)
    return $pr.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Invoke-SelfElevation {
    Write-Warn 'Administrative privileges required. Requesting UAC elevation...'
    $psi = New-Object System.Diagnostics.ProcessStartInfo
    $psi.UseShellExecute = $true
    $psi.Verb = 'runas'
    $psi.WindowStyle = [System.Diagnostics.ProcessWindowStyle]::Normal

    if ($PSCommandPath -and (Test-Path -LiteralPath $PSCommandPath)) {
        $psi.FileName = (Get-Process -Id $PID).Path
        $argList = @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', ('"{0}"' -f $PSCommandPath), '-Theme', $Theme)
    } else {
        $psi.FileName = 'pwsh.exe'
        if (-not (Get-Command 'pwsh.exe' -ErrorAction SilentlyContinue)) {
            $psi.FileName = 'powershell.exe'
        }
        $argList = @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-Command', "irm `"https://raw.githubusercontent.com/k0ishiii/WinRAR-Activator/main/WinRAR-Activator.ps1`" | iex")
    }

    if ($NoPause) { $argList += '-NoPause' }
    $psi.Arguments = $argList -join ' '

    try {
        [void][System.Diagnostics.Process]::Start($psi)
        exit 0
    } catch {
        Write-Fail ('UAC elevation failed or denied: {0}' -f $_.Exception.Message)
        Pause-IfInteractive
        exit 1
    }
}

function Get-OSArchitecture {
    if ([Environment]::Is64BitOperatingSystem) { return 'x64' } else { return 'x86' }
}

function Get-PEArchitecture {
    param([string]$FilePath)
    try {
        $stream = [System.IO.File]::OpenRead($FilePath)
        $reader = New-Object System.IO.BinaryReader($stream)
        if ($reader.ReadUInt16() -ne 0x5A4D) { $stream.Close(); return 'Unknown' }
        $stream.Seek(0x3C, [System.IO.SeekOrigin]::Begin) | Out-Null
        $peOffset = $reader.ReadInt32()
        $stream.Seek($peOffset, [System.IO.SeekOrigin]::Begin) | Out-Null
        if ($reader.ReadUInt32() -ne 0x00004550) { $stream.Close(); return 'Unknown' }
        $machine = $reader.ReadUInt16()
        $stream.Close()
        switch ($machine) {
            0x014c { return 'x86' }
            0x8664 { return 'x64' }
            0xAA64 { return 'ARM64' }
            default { return 'Unknown' }
        }
    } catch {
        return 'Unknown'
    }
}

function Resolve-WinRARPath {
    $paths = @(
        "$env:ProgramFiles\WinRAR",
        "${env:ProgramFiles(x86)}\WinRAR",
        "$env:USERPROFILE\scoop\apps\winrar\current"
    )
    foreach ($p in $paths) {
        if ($p -and (Test-Path (Join-Path $p 'WinRAR.exe'))) {
            return $p
        }
    }
    return $null
}

function Stop-WinRARDeep {
    $targetNames = @('WinRAR', 'rar', 'unrar', 'WinRAR32', 'WinRAR64')
    $terminated = $false

    foreach ($name in $targetNames) {
        $procs = Get-Process -Name $name -ErrorAction SilentlyContinue
        if ($procs) {
            if (-not $terminated) {
                Write-Step 'Performing deep termination of active/tray instances...'
                $terminated = $true
            }
            $procs | ForEach-Object {
                try { 
                    $_.Kill()
                    $_.WaitForExit(2000) | Out-Null
                } catch { }
            }
        }
    }

    if ($terminated) {
        Start-Sleep -Milliseconds 300
        Write-Ok 'All WinRAR processes & tray instances successfully cleared.'
    }
}

function Clear-WinRARCache {
    try {
        $tempPath = [System.IO.Path]::GetTempPath()
        Get-ChildItem -Path $tempPath -Filter 'RarSFX*' -ErrorAction SilentlyContinue | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
        Get-ChildItem -Path "$env:LocalAppData\VirtualStore" -Recurse -Filter '*WinRAR*' -ErrorAction SilentlyContinue | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
    } catch { }
}

function Start-WinRAR {
    param([string]$Dir)
    $exe = Join-Path $Dir 'WinRAR.exe'
    try {
        Start-Process -FilePath $exe -ErrorAction Stop | Out-Null
        Write-Ok 'WinRAR process launched.'
        return $true
    } catch {
        Write-Fail ('Failed to start WinRAR: {0}' -f $_.Exception.Message)
        return $false
    }
}

$script:RarRegKey = @"
RAR registration data
Hououin Kyouma
El Psy Congroo
UID=c881245b7b1a78985cb0
64122122505cb05c44e75618ab5ea84c86e876e620d42d566d4453
18f59893063b0c337398603ef609acfb0eac3505bc19e61df2b7f5
bba0aeef9172868794c0d6b2314c038d105f9b3ba638ec8a82305b
a209c087680d071cbbdbb10a9652f8c2b06091a5243fbbc24b381d
4cb3b58c52c3d7d99b828c76f88937dd4d94058fb3038d105f9b3b
a638ec8aa57606488b324a1e71be06e54787b797df438679604ee6
92b1f552734e6580bee03078379b0cdddee16bb6f4a53644961125
------------------------------------------------------
"@

function Set-RarRegKey {
    param([string]$Dir)
    $target = Join-Path $Dir 'rarreg.key'
    $backup = Join-Path $Dir 'rarreg.key.bak'

    $needsDeployment = $true
    if (Test-Path -LiteralPath $target) {
        try {
            $currentContent = [System.IO.File]::ReadAllText($target)
            $currentLen = (Get-Item -LiteralPath $target).Length
            if ($currentLen -ge 100 -and $currentContent -match 'RAR registration data' -and $currentContent -match 'Hououin Kyouma') {
                $needsDeployment = $false
                Write-Ok 'Key integrity check passed: Valid license already active.'
            }
        } catch { }
    }

    if ($needsDeployment) {
        if (Test-Path -LiteralPath $target) {
            Write-Step 'Creating safety backup of existing license key...'
            try {
                Set-ItemProperty -LiteralPath $target -Name Attributes -Value 'Normal' -ErrorAction SilentlyContinue
                Copy-Item -LiteralPath $target -Destination $backup -Force -ErrorAction Stop
                Write-Ok ('Backup successfully saved to: "{0}"' -f $backup)
            } catch { }

            Write-Step 'Removing corrupted or outdated key...'
            try {
                Remove-Item -LiteralPath $target -Force -ErrorAction Stop
            } catch { }
        }

        Write-Step 'Deploying self-healing license payload...'
        try {
            $content = ($script:RarRegKey -split "`r?`n") -join "`r`n"
            [System.IO.File]::WriteAllText($target, $content, (New-Object System.Text.UTF8Encoding($false)))
        } catch {
            Write-Fail ('Failed to write license file: {0}' -f $_.Exception.Message)
            return $false
        }
    }

    Write-Step 'Applying NTFS read-only hardening to prevent overwrites...'
    try {
        Set-ItemProperty -LiteralPath $target -Name Attributes -Value 'ReadOnly' -ErrorAction Stop
        $acl = Get-Acl $target
        $rule = New-Object System.Security.AccessControl.FileSystemAccessRule("Users", "Write, Delete", "Deny")
        $acl.AddAccessRule($rule)
        Set-Acl $target $acl -ErrorAction SilentlyContinue
        Write-Ok 'License protected against unauthorized system modifications.'
    } catch { }

    if (-not (Test-Path -LiteralPath $target -PathType Leaf)) {
        Write-Fail 'Post-verification failed: License file missing.'
        return $false
    }

    Write-Ok 'License deployment and integrity validation completed.'
    return $true
}

function Invoke-Main {
    Write-Banner

    if (-not (Test-Admin)) {
        Invoke-SelfElevation
        return
    }
    Write-Ok 'Administrative privileges confirmed.'

    Write-Step 'Scanning system for WinRAR installation...'
    $rarDir = Resolve-WinRARPath
    if (-not $rarDir) {
        Write-Fail 'WinRAR installation not found in standard directories. Please install it first.'
        Pause-IfInteractive
        exit 2
    }

    $exePath = Join-Path $rarDir 'WinRAR.exe'
    $osArch  = Get-OSArchitecture
    $rarArch = Get-PEArchitecture -FilePath $exePath
    
    try {
        $verInfo = [System.Diagnostics.FileVersionInfo]::GetVersionInfo($exePath)
        $exactVer = $verInfo.FileVersion
        Write-Ok ("WinRAR v{0} ({1}) detected on Windows ({2}) at: `"{3}`"" -f $exactVer, $rarArch, $osArch, $rarDir)
    } catch {
        Write-Ok ("WinRAR ({0}) detected on Windows ({1}) at: `"{2}`"" -f $rarArch, $osArch, $rarDir)
    }

    Stop-WinRARDeep
    Clear-WinRARCache

    Write-Step 'Initializing environment workspace...'
    if (-not (Start-WinRAR -Dir $rarDir)) {
        Pause-IfInteractive
        exit 3
    }
    Invoke-Spinner -Message 'Waiting for workspace initialization' -Seconds 2
    Stop-WinRARDeep

    if (-not (Set-RarRegKey -Dir $rarDir)) {
        Pause-IfInteractive
        exit 4
    }

    Write-Step 'Finalizing registration and restarting WinRAR...'
    if (-not (Start-WinRAR -Dir $rarDir)) {
        Pause-IfInteractive
        exit 5
    }
    Invoke-Spinner -Message 'Applying license settings' -Seconds 2
    Stop-WinRARDeep

    Write-Host ''
    Write-Host "  ==========================================================================" -ForegroundColor DarkGray
    Write-Ok ' ACTIVATION COMPLETED SUCCESSFULLY (v2.2)! Enjoy your registered WinRAR.'
    Write-Host "  ==========================================================================" -ForegroundColor DarkGray
    Pause-IfInteractive
}

try {
    Invoke-Main
} catch {
    Write-Host ''
    Write-Fail ('Unhandled critical exception: {0}' -f $_.Exception.Message)
    Pause-IfInteractive
    exit 1
}