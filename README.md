# WinRAR Activator v2.2

> **A premium, lightweight, and fully autonomous utility to automatically apply and manage the WinRAR registration license.**

[![PowerShell Version](https://img.shields.io/badge/PowerShell-5.1%2B%20%7C%207%2B-blue.svg)](https://github.com/PowerShell/PowerShell)
[![Platform](https://img.shields.io/badge/Platform-Windows%20x64%2F32-lightgrey.svg)](https://www.win-rar.com/)
[![Author](https://img.shields.io/badge/Author-k0ishiii-yellow.svg)](https://github.com/k0ishiii)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](./LICENSE)

---

## Overview

**WinRAR Activator v2.2** is an advanced, self-contained utility designed to automatically deploy and maintain the WinRAR registration license seamlessly. Built with modular PowerShell architecture and paired with an intelligent environment launcher (`Run.bat`), it features deep tray/process termination, silent cache cleaning, NTFS file hardening, and self-healing license integrity verification.

---

## Key Features

* **Dual Engine Compatibility**: Dynamically detects and prioritizes **PowerShell 7 (`pwsh`)** with seamless fallback to **Windows PowerShell 5.1**.
* **Absolute Path & Architecture Discovery**: Scans standard directories (`Program Files`, `Program Files (x86)`, and `Scoop`) and analyzes PE headers to detect WinRAR (x64 / x86) and OS architecture.
* **Deep Process Termination**: Force-clears all active instances, background processes, and system tray leftovers (`rar`, `unrar`, `winrar`) prior to deployment.
* **Self-Healing License Engine**: Automatically verifies existing key integrity and skips deployment if a valid license is already active.
* **NTFS Permission Hardening**: Applies read-only attributes and access control rules to `rarreg.key` to prevent unauthorized system modifications or overwrites.
* **Silent Cache Cleaner**: Automatically purges installation remnants and temporary workspace artifacts (`RarSFX*`, `VirtualStore`) in the background.
* **ASCII Terminal UI & Dynamic Themes**: Features a compact, non-clipping ASCII banner, real-time spinner animations, and customizable color themes (`Purple`, `Cyan`, `Green`, `Red`, `Yellow`).
* **Multiple Deployment Options**: Choose between classic double-click local execution or instant remote execution directly from GitHub via terminal.

---

## File Structure

WinRAR-Activator/
├── Run.bat               # Intelligent environment launcher
├── WinRAR-Activator.ps1  # Core PowerShell activation script
└── README.md             # Project documentation

---

## Quick Start & Installation

You can choose your preferred method to run the activator:

### Method 1: Local Execution (Double-Click)
1. Download or clone the repository into a local folder.
2. Ensure both **`Run.bat`** and **`WinRAR-Activator.ps1`** are in the same directory.
3. Double-click **`Run.bat`** (it automatically handles administrative privileges).

### Method 2: Instant Remote Execution (PowerShell One-Liner)
If you prefer not to download files, open **PowerShell** as Administrator and run the following command to fetch and execute it directly from the repository:

```powershell
irm "[https://raw.githubusercontent.com/k0ishiii/WinRAR-Activator/main/WinRAR-Activator.ps1](https://raw.githubusercontent.com/k0ishiii/WinRAR-Activator/main/WinRAR-Activator.ps1)" | iex

```

---

## Execution Flow

1. **Environment Setup**: Launcher determines the best PowerShell host (`pwsh` vs `powershell`) and requests UAC elevation if needed.
2. **System Scan**: Discovers `WinRAR.exe` path, version metadata (`FileVersionInfo`), and machine architecture (x64 vs x86).
3. **Deep Clean & Workspace Init**: Terminates ghost/tray processes and clears temporary installation cache.
4. **Self-Healing & Hardening**: Validates license integrity, backs up old keys, deploys the payload, and applies NTFS read-only protection.
5. **Final Verification**: Restarts WinRAR briefly to confirm license acceptance and outputs a success completion status.

---

## Author & Credits

* **Author**: `k0ishiii`
* **Discord**: `misakisakura3`

---

## License

Distributed under the **MIT License**. See the [LICENSE](https://www.google.com/search?q=./LICENSE) file for more information.