<div align="center">

# WinRAR Activator

> **A minimal, zero-friction utility engineered to effortlessly manage and protect your WinRAR registration.**

[![PowerShell Version](https://img.shields.io/badge/PowerShell-5.1%2B%20%7C%207%2B-blue.svg?style=for-the-badge&logo=powershell&logoColor=white)](https://github.com/PowerShell/PowerShell)
[![Platform](https://img.shields.io/badge/Platform-Windows%20x64%2F32-lightgrey.svg?style=for-the-badge&logo=windows&logoColor=white)](https://www.win-rar.com/)
[![Version](https://img.shields.io/badge/Version-v2.4-purple.svg?style=for-the-badge)](https://github.com/k0ishiii/WinRAR-Activator)
[![License](https://img.shields.io/badge/License-MIT-green.svg?style=for-the-badge)](./LICENSE)

</div>

---

## Overview

**WinRAR Activator v2.4** is a lightweight, fully autonomous automation tool designed for seamless deployment and persistent protection of the WinRAR registration license.

Built with performance and safety in mind, it combines universal path discovery, non-disruptive process handling, automated workspace cleanup, and hardware-agnostic permission hardening — delivering a refined, single-command experience.

---

## Core Capabilities

* **Dual-Engine Execution**: Dynamically targets PowerShell 7 (`pwsh`) with seamless fallback to Windows PowerShell 5.1.
* **Universal Registry Discovery**: Scans environment variables, Scoop installations, and system registry paths (`App Paths`) to locate WinRAR under any custom directory.
* **Robust UAC Elevation**: Safely rebuilds the elevated argument array in `Run.bat` so values containing spaces or quotes are forwarded intact, preserves the child process exit code across `endlocal`, and uses a guard environment variable to prevent runaway UAC loops.
* **Reliable Remote Execution**: `irm | iex` runs are transparently staged to a temporary `.ps1` file so the elevated child process inherits every switch correctly (`-NoPause`, cleanup path), with automatic removal of the temp file on exit.
* **SID-Based Hardening**: Applies universal NTFS access control rules using security identifiers (`S-1-5-32-545`), with the `ReadOnly` attribute and the ACL pass reported **independently**, so non-NTFS volumes (FAT32 / exFAT) degrade gracefully with an accurate status message.
* **Self-Healing License Engine**: Evaluates existing license integrity prior to payload execution to eliminate redundant writes.
* **Fault-Tolerant Retry Logic**: Employs millisecond-level retry loops during critical file operations to prevent software lockouts or antivirus interference.
* **Safe Process Lifecycle**: Requests a graceful shutdown via `CloseMainWindow` and only falls back to `Kill` after a bounded timeout; launch verification uses `WaitForInputIdle` plus a liveness check so a crashed `WinRAR.exe` is reported instead of silently ignored.
* **Targeted Workspace Cleanup**: Restricts `Temp` sweeps to `RarSFX*` at `-Depth 1` and targets only the two WinRAR-specific subfolders under `VirtualStore`, so unrelated user data is never touched.
* **Redirect-Aware Output**: The animated spinner emits clean single-line logs whenever stdout is not an interactive terminal, keeping CI runs and redirected logs readable.

---

## Quick Start

You can deploy the utility via remote command or traditional local script execution. Manual administrator elevation is handled automatically if required.

### Remote Execution (Recommended)

Run the following command inside a standard **PowerShell** prompt:

```powershell
irm "https://raw.githubusercontent.com/k0ishiii/WinRAR-Activator/main/WinRAR-Activator.ps1" | iex
```

### Local Execution

1. Clone or download this repository.
2. Ensure both `Run.bat` and `WinRAR-Activator.ps1` are located in the same directory.
3. Launch `Run.bat`.

---

## Usage

The activator accepts the following parameters when invoked directly:

| Parameter  | Type     | Default | Description                                                              |
|------------|----------|---------|--------------------------------------------------------------------------|
| `-NoPause` | `switch` | Off     | Skip the interactive *Press ENTER to exit* prompt. Useful for automation. |

### Examples

Interactive run (waits for `ENTER` before closing):

```powershell
.\WinRAR-Activator.ps1
```

Non-interactive run (ideal for scheduled tasks or CI):

```powershell
.\WinRAR-Activator.ps1 -NoPause
```

Remote execution with a parameter forwarded to the elevated child:

```powershell
& ([scriptblock]::Create((irm "https://raw.githubusercontent.com/k0ishiii/WinRAR-Activator/main/WinRAR-Activator.ps1"))) -NoPause
```

---

## How It Works

1. **Elevation** — If not already elevated, the script relaunches itself with `RunAs`. A guard environment variable (`_WINRAR_ACT_ELEVATED`) prevents infinite UAC loops when the elevated token still reports a non-admin role.
2. **Discovery** — Locates the WinRAR installation by probing standard paths, Scoop, and the `App Paths` registry keys (both native and `WOW6432Node`).
3. **Architecture Detection** — Parses the PE header of `WinRAR.exe` to report the executable architecture alongside the OS architecture.
4. **Process Handling** — Requests a graceful `CloseMainWindow` for GUI processes, falls back to `Kill` after a bounded timeout, and waits for each process to fully exit.
5. **Workspace Initialization** — Launches `WinRAR.exe` with `-PassThru`, verifies it did not exit immediately, waits for `WaitForInputIdle`, then performs a graceful shutdown to let WinRAR finalize its own state.
6. **License Deployment** — Compares the current `rarreg.key` integrity before overwriting; creates a `.bak` backup when replacing an existing file; retries file write up to three times with millisecond backoff.
7. **Hardening** — Applies `ReadOnly` and NTFS ACL protections separately, with per-pass status reporting, so partial failures are visible and never masked.
8. **Finalization** — Relaunches WinRAR to confirm the registration, then closes it cleanly.

---

## Architecture

```text
WinRAR-Activator/
├── Run.bat               # Environment bootstrap launcher
├── WinRAR-Activator.ps1  # Core engine & self-healing framework
├── README.md             # Project documentation
└── LICENSE               # MIT License
```

---

## Requirements

* **Windows** 10 / 11 (x86 or x64).
* **PowerShell** 5.1 (built-in) **or** PowerShell 7+ (`pwsh`).
* **WinRAR** installed via the official installer or Scoop.
* **Administrator privileges** — requested automatically via UAC if the current session is not elevated.

---

## Troubleshooting

| Symptom                                                       | Cause                                                       | Resolution                                                                                              |
|---------------------------------------------------------------|-------------------------------------------------------------|---------------------------------------------------------------------------------------------------------|
| `WinRAR installation not found`                               | WinRAR not installed, or installed to a non-standard path.  | Install WinRAR via the official installer or Scoop, then rerun.                                         |
| `NTFS ACL hardening not applied (non-NTFS volume...)`         | WinRAR folder is on FAT32 / exFAT or a network share.       | Expected; the `ReadOnly` attribute is still applied. Move the install to an NTFS volume for full hardening. |
| `Elevation was already attempted, but Administrator role...`  | The elevated token does not satisfy the Administrator role. | Check local security policy / UAC configuration, or launch `Run.bat` manually from an admin shell.      |
| `WinRAR terminated immediately after launch (exit code: N)`   | Corrupt installation or DLL conflict.                       | Reinstall WinRAR.                                                                                       |
| Repeated UAC prompts                                          | Guard variable missing due to a customized environment.     | Ensure `_WINRAR_ACT_ELEVATED` is not being stripped by your shell profile.                              |

---

## Developer Info

* **Author**: `k0ishiii`
* **Discord**: `misakisakura3`
* **Repository**: [github.com/k0ishiii/WinRAR-Activator](https://github.com/k0ishiii/WinRAR-Activator)

---

## License

This project is licensed under the terms of the **MIT License**. Refer to [LICENSE](./LICENSE) for full details.

Copyright © 2026 k0ishiii