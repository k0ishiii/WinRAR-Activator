<div align="center">

# WinRAR Activator v2.2

> **A premium, lightweight, and fully autonomous utility to automatically apply and manage the WinRAR registration license.**

[![PowerShell Version](https://img.shields.io/badge/PowerShell-5.1%2B%20%7C%207%2B-blue.svg?style=for-the-badge&logo=powershell&logoColor=white)](https://github.com/PowerShell/PowerShell)
[![Platform](https://img.shields.io/badge/Platform-Windows%20x64%2F32-lightgrey.svg?style=for-the-badge&logo=windows&logoColor=white)](https://www.win-rar.com/)
[![Author](https://img.shields.io/badge/Author-k0ishiii-yellow.svg?style=for-the-badge&logo=github&logoColor=white)](https://github.com/k0ishiii)
[![License](https://img.shields.io/badge/License-MIT-green.svg?style=for-the-badge)](./LICENSE)

</div>

---

## 🚀 Overview

**WinRAR Activator v2.2** is an advanced, enterprise-grade, self-contained utility engineered to automatically deploy, protect, and maintain the WinRAR registration license with absolute zero user friction. Built on a robust modular PowerShell architecture and paired with an intelligent environment launcher, it features deep tray process termination, silent cache cleaning, NTFS file permission hardening, and a real-time self-healing license integrity verification engine.

---

## ✨ Core Features

* **⚡ Dual Engine Compatibility**: Dynamically detects and prioritizes **PowerShell 7** with seamless fallback to native **Windows PowerShell 5.1**.
* **🔍 Absolute Path & Architecture Discovery**: Automatically scans standard directories (`Program Files`, `Program Files (x86)`, and `Scoop`) and analyzes PE headers to precisely match WinRAR (`x64` / `x86`) and OS architecture.
* **🛑 Deep Process & Tray Termination**: Force-clears all active instances, background processes, and system tray leftovers (`rar`, `unrar`, `winrar`) prior to payload deployment.
* **🛡️ Self-Healing License Engine**: Performs instant integrity checks on startup. If a valid license is active, it bypasses deployment; if missing or corrupted, it automatically restores and validates the key.
* **🔒 NTFS Permission Hardening**: Applies read-only attributes and strict access control rules to the license file to prevent unauthorized system modifications or overwrites by future updates.
* **🧹 Silent Cache Purge**: Automatically sweeps away installation remnants and temporary workspace artifacts in total background silence.
* **🎨 Dynamic ASCII Terminal UI**: Features a sleek non-clipping banner, real-time status spinner animations, and customizable color themes (`Purple`, `Cyan`, `Green`, `Red`, `Yellow`).

---

## ⚡ Quick Start & Installation

You can choose your preferred method to run the activator:

### Method 1: Instant Remote Execution (Recommended & Fastest)
Open **PowerShell** as Administrator and run this single-line command to fetch and execute the tool instantly from GitHub:

```powershell
irm "https://raw.githubusercontent.com/k0ishiii/WinRAR-Activator/main/WinRAR-Activator.ps1" | iex

```

### Method 2: Classic Local Execution (Double-Click)

1. Clone or download the repository ZIP file to your local machine.
2. Ensure both `Run.bat` and `WinRAR-Activator.ps1` reside in the same folder.
3. Double-click `Run.bat` (administrative elevation is handled automatically).

---

## ⚙️ Behind the Scenes (Execution Flow)

1. **Bootstrap & Elevation**: Determines the optimal PowerShell host and triggers secure UAC elevation if required.
2. **Environment & Architecture Scan**: Resolves WinRAR installation paths, evaluates version metadata, and checks host architecture.
3. **Deep Clean & Workspace Prep**: Terminates ghost/tray background processes and purges temporary cache directories.
4. **Self-Healing & NTFS Hardening**: Validates current license integrity, creates safety backups if needed, deploys the clean payload, and locks down NTFS file permissions.
5. **Final Verification**: Restarts WinRAR briefly to confirm license acceptance and outputs a clean success status.

---

## 👤 Author & Credits

* **Author**: `k0ishiii`
* **Discord**: `misakisakura3`

---

## 📜 License

This project is open-source and distributed under the **MIT License**. Check the [LICENSE](https://www.google.com/search?q=./LICENSE) file for full details.