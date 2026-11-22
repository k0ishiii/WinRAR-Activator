#Requires -Version 5.1

[CmdletBinding()]
param(
    [switch]$NoPause,

    # Internal: used only by the elevated child process to clean up the downloaded temp script.
    [string]$TempScriptToCleanup = $null
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$ProgressPreference    = 'SilentlyContinue'

$script:AppTitle   = 'WinRAR Activator'
$script:AppVersion = 'v2.4'
$script:Author     = 'k0ishiii'
$script:Discord    = 'misakisakura3'

# Fixed color scheme (Purple theme).
$script:ColPrimary = 'Magenta'
$script:ColHeader  = 'Magenta'

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

    # When stdout is not an interactive terminal, avoid carriage returns that would
    # corrupt redirected logs. Emit clean single lines instead.
    if ([Console]::IsOutputRedirected) {
        Write-Host ("   [?] {0}..." -f $Message) -ForegroundColor DarkGray
        Start-Sleep -Seconds $Seconds
        Write-Host ("   [+] {0}... Completed." -f $Message) -ForegroundColor $script:ColPrimary
        return
    }

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

function Clear-TempScript {
    if ($script:TempScriptToCleanup -and (Test-Path -LiteralPath $script:TempScriptToCleanup)) {
        try {
            Remove-Item -LiteralPath $script:TempScriptToCleanup -Force -ErrorAction SilentlyContinue
        } catch { }
    }
}

function Pause-IfInteractive {
    Clear-TempScript
    if ($NoPause) { exit 0 }
    Write-Host ''
    Write-Host '  ==========================================================================' -ForegroundColor DarkGray
    Write-Host '   Press ENTER to exit the activator window...' -ForegroundColor White
    Write-Host '  ==========================================================================' -ForegroundColor DarkGray
    try {
        [void][System.Console]::ReadLine()
    } catch { }
    [System.Environment]::Exit(0)
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

    $tmpScript = $null

    if ($PSCommandPath -and (Test-Path -LiteralPath $PSCommandPath)) {
        # Local execution: relaunch the exact same script file.
        $psi.FileName = (Get-Process -Id $PID).Path
        $argList = @(
            '-NoProfile', '-ExecutionPolicy', 'Bypass',
            '-File', ('"{0}"' -f $PSCommandPath)
        )
    } else {
        # Remote execution (irm | iex): download to a temp .ps1 so parameters
        # and the -File invocation are fully honoured by the elevated process.
        try {
            $tmpScript = Join-Path $env:TEMP ("WinRAR-Activator-{0}.ps1" -f ([Guid]::NewGuid().ToString('N')))
            $url = 'https://raw.githubusercontent.com/k0ishiii/WinRAR-Activator/main/WinRAR-Activator.ps1'
            Invoke-WebRequest -Uri $url -OutFile $tmpScript -UseBasicParsing -ErrorAction Stop
        } catch {
            Write-Fail ('Failed to download activator script for elevation: {0}' -f $_.Exception.Message)
            if ($tmpScript -and (Test-Path -LiteralPath $tmpScript)) {
                try { Remove-Item -LiteralPath $tmpScript -Force -ErrorAction SilentlyContinue } catch { }
            }
            Pause-IfInteractive
            return
        }

        if (Get-Command 'pwsh.exe' -ErrorAction SilentlyContinue) {
            $psi.FileName = 'pwsh.exe'
        } else {
            $psi.FileName = 'powershell.exe'
        }

        $argList = @(
            '-NoProfile', '-ExecutionPolicy', 'Bypass',
            '-File', ('"{0}"' -f $tmpScript),
            '-TempScriptToCleanup', ('"{0}"' -f $tmpScript)
        )
    }

    if ($NoPause) { $argList += '-NoPause' }
    $psi.Arguments = $argList -join ' '

    # Anti-loop guard: mark current process env so the elevated child can detect
    # that elevation was already attempted. If the child still reports non-admin,
    # it will abort instead of spawning another UAC prompt indefinitely.
    $env:_WINRAR_ACT_ELEVATED = '1'
    try {
        $psi.EnvironmentVariables['_WINRAR_ACT_ELEVATED'] = '1'
    } catch { }

    try {
        [void][System.Diagnostics.Process]::Start($psi)
    } catch {
        Write-Fail ('UAC elevation failed or denied: {0}' -f $_.Exception.Message)
        if ($tmpScript -and (Test-Path -LiteralPath $tmpScript)) {
            try { Remove-Item -LiteralPath $tmpScript -Force -ErrorAction SilentlyContinue } catch { }
        }
        Pause-IfInteractive
        return
    }

    # The elevated child now owns the temp script and will delete it on exit
    # through -TempScriptToCleanup.
    [System.Environment]::Exit(0)
}

function Get-OSArchitecture {
    if ([Environment]::Is64BitOperatingSystem) { return 'x64' } else { return 'x86' }
}

function Get-PEArchitecture {
    param([string]$FilePath)
    $stream = $null
    $reader = $null
    try {
        $stream = [System.IO.File]::OpenRead($FilePath)
        $reader = New-Object System.IO.BinaryReader($stream)

        if ($reader.ReadUInt16() -ne 0x5A4D) { return 'Unknown' }

        $stream.Seek(0x3C, [System.IO.SeekOrigin]::Begin) | Out-Null
        $peOffset = $reader.ReadInt32()
        $stream.Seek($peOffset, [System.IO.SeekOrigin]::Begin) | Out-Null

        if ($reader.ReadUInt32() -ne 0x00004550) { return 'Unknown' }

        $machine = $reader.ReadUInt16()
        switch ($machine) {
            0x014c { return 'x86' }
            0x8664 { return 'x64' }
            0xAA64 { return 'ARM64' }
            default { return 'Unknown' }
        }
    } catch {
        return 'Unknown'
    } finally {
        if ($reader) {
            try { $reader.Dispose() } catch { }
        } elseif ($stream) {
            try { $stream.Dispose() } catch { }
        }
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

    $regPaths = @(
        'Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\WinRAR.exe',
        'Registry::HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\App Paths\WinRAR.exe'
    )
    foreach ($regPath in $regPaths) {
        if (Test-Path $regPath) {
            try {
                $val = (Get-ItemProperty -Path $regPath -Name '(default)' -ErrorAction SilentlyContinue).'(default)'
                if (-not $val) {
                    $val = (Get-ItemProperty -Path $regPath -ErrorAction SilentlyContinue).'(default)'
                }
                if ($val) {
                    $dir = [System.IO.Path]::GetDirectoryName($val)
                    if ($dir -and (Test-Path (Join-Path $dir 'WinRAR.exe'))) {
                        return $dir
                    }
                }
            } catch { }
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
            foreach ($p in $procs) {
                try {
                    $closed = $false
                    if ($p.MainWindowHandle -ne 0) {
                        try { $closed = $p.CloseMainWindow() } catch { $closed = $false }
                    }

                    if ($closed) {
                        if (-not $p.WaitForExit(3000)) {
                            try { $p.Kill() } catch { }
                            $p.WaitForExit(2000) | Out-Null
                        }
                    } else {
                        try { $p.Kill() } catch { }
                        $p.WaitForExit(2000) | Out-Null
                    }
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
    # Temp: limit recursion depth so we never traverse unrelated user directories.
    try {
        $tempPath = [System.IO.Path]::GetTempPath()
        Get-ChildItem -Path $tempPath -Filter 'RarSFX*' -Depth 1 -ErrorAction SilentlyContinue |
            Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
    } catch { }

    # VirtualStore: target only the two known WinRAR install locations instead of
    # recursively walking the whole VirtualStore tree.
    try {
        $vsRoot = Join-Path $env:LocalAppData 'VirtualStore'
        if ($vsRoot -and (Test-Path -LiteralPath $vsRoot)) {
            $vsTargets = @(
                (Join-Path $vsRoot 'Program Files\WinRAR'),
                (Join-Path $vsRoot 'Program Files (x86)\WinRAR')
            )
            foreach ($t in $vsTargets) {
                if ($t -and (Test-Path -LiteralPath $t)) {
                    try {
                        Remove-Item -LiteralPath $t -Recurse -Force -ErrorAction SilentlyContinue
                    } catch { }
                }
            }
        }
    } catch { }
}

function Start-WinRAR {
    param([string]$Dir)
    $exe = Join-Path $Dir 'WinRAR.exe'

    $proc = $null
    try {
        $proc = Start-Process -FilePath $exe -PassThru -ErrorAction Stop
    } catch {
        Write-Fail ('Failed to start WinRAR: {0}' -f $_.Exception.Message)
        return $false
    }

    try {
        if (-not $proc.HasExited) {
            $proc.WaitForInputIdle(10000) | Out-Null
        }
    } catch { }

    Start-Sleep -Milliseconds 750

    try {
        if ($proc.HasExited) {
            $code = $null
            try { $code = $proc.ExitCode } catch { }
            Write-Fail ('WinRAR terminated immediately after launch (exit code: {0}).' -f $code)
            return $false
        }
    } catch {
        Write-Fail 'Unable to verify WinRAR process state after launch.'
        return $false
    }

    Write-Ok 'WinRAR process launched.'
    return $true
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
        $success = $false
        for ($retry = 1; $retry -le 3; $retry++) {
            try {
                $content = ($script:RarRegKey -split "`r?`n") -join "`r`n"
                [System.IO.File]::WriteAllText($target, $content, (New-Object System.Text.UTF8Encoding($false)))
                $success = $true
                break
            } catch {
                Start-Sleep -Milliseconds 250
            }
        }
        if (-not $success) {
            Write-Fail 'Failed to write license file after multiple attempts.'
            return $false
        }
    }

    if (-not (Test-Path -LiteralPath $target -PathType Leaf)) {
        Write-Fail 'Post-write verification failed: License file missing.'
        return $false
    }

    Write-Step 'Applying ReadOnly attribute and NTFS hardening...'

    # --- ReadOnly attribute (independent from ACL) ---
    $readOnlyOk = $false
    for ($retry = 1; $retry -le 3; $retry++) {
        try {
            Set-ItemProperty -LiteralPath $target -Name Attributes -Value 'ReadOnly' -ErrorAction Stop
            $readOnlyOk = $true
            break
        } catch {
            Start-Sleep -Milliseconds 250
        }
    }

    # --- NTFS ACL hardening (independent from ReadOnly) ---
    $aclOk = $false
    $aclError = $null
    for ($retry = 1; $retry -le 3; $retry++) {
        try {
            $acl = Get-Acl -LiteralPath $target
            $acl.SetAccessRuleProtection($true, $true)
            $sid = New-Object System.Security.Principal.SecurityIdentifier("S-1-5-32-545")
            $rule = New-Object System.Security.AccessControl.FileSystemAccessRule($sid, "Write, Delete", "Deny")
            $acl.AddAccessRule($rule)
            Set-Acl -LiteralPath $target -AclObject $acl -ErrorAction Stop
            $aclOk = $true
            break
        } catch {
            $aclError = $_.Exception.Message
            Start-Sleep -Milliseconds 250
        }
    }

    if ($readOnlyOk) {
        Write-Ok 'ReadOnly file attribute applied successfully.'
    } else {
        Write-Warn 'Failed to apply ReadOnly file attribute.'
    }

    if ($aclOk) {
        Write-Ok 'NTFS ACL hardening applied (BUILTIN\Users denied Write/Delete).'
    } else {
        Write-Warn ('NTFS ACL hardening not applied (non-NTFS volume or access denied): {0}' -f $aclError)
    }

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
        # Anti-loop guard: if we already attempted elevation and we are still
        # not administrators, abort instead of spawning endless UAC prompts.
        if ($env:_WINRAR_ACT_ELEVATED -eq '1') {
            Write-Fail 'Elevation was already attempted, but Administrator role still not detected. Aborting to avoid UAC loop.'
            Pause-IfInteractive
            return
        }
        Invoke-SelfElevation
        return
    }
    Write-Ok 'Administrative privileges confirmed.'

    Write-Step 'Scanning system for WinRAR installation...'
    $rarDir = Resolve-WinRARPath
    if (-not $rarDir) {
        Write-Fail 'WinRAR installation not found. Please install it first.'
        Pause-IfInteractive
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
    }
    Invoke-Spinner -Message 'Waiting for workspace initialization' -Seconds 2
    Stop-WinRARDeep

    if (-not (Set-RarRegKey -Dir $rarDir)) {
        Pause-IfInteractive
    }

    Write-Step 'Finalizing registration and restarting WinRAR...'
    if (-not (Start-WinRAR -Dir $rarDir)) {
        Pause-IfInteractive
    }
    Invoke-Spinner -Message 'Applying license settings' -Seconds 2
    Stop-WinRARDeep

    Write-Host ''
    Write-Host "  ==========================================================================" -ForegroundColor DarkGray
    Write-Ok ' ACTIVATION COMPLETED SUCCESSFULLY (v2.4)! Enjoy your registered WinRAR.'
    Write-Host "  ==========================================================================" -ForegroundColor DarkGray
    Pause-IfInteractive
}

try {
    Invoke-Main
} catch {
    Write-Host ''
    Write-Fail ('Unhandled critical exception: {0}' -f $_.Exception.Message)
    Pause-IfInteractive
}