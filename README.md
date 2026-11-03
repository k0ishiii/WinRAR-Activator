<div align="center">

# WinRAR Activator

> **A minimal, zero-friction utility engineered to effortlessly manage and protect your WinRAR registration.**

[![PowerShell Version](https://img.shields.io/badge/PowerShell-5.1%2B%20%7C%207%2B-blue.svg?style=for-the-badge&logo=powershell&logoColor=white)](https://github.com/PowerShell/PowerShell)
[![Platform](https://img.shields.io/badge/Platform-Windows%20x64%2F32-lightgrey.svg?style=for-the-badge&logo=windows&logoColor=white)](https://www.win-rar.com/)
[![Version](https://img.shields.io/badge/Version-v2.3-purple.svg?style=for-the-badge)](https://github.com/k0ishiii/WinRAR-Activator)
[![License](https://img.shields.io/badge/License-MIT-green.svg?style=for-the-badge)](./LICENSE)

</div>

---

## Overview

**WinRAR Activator v2.3** is a lightweight, fully autonomous automation tool designed for seamless deployment and persistent protection of the WinRAR registration license.

Built with performance and safety in mind, it combines universal path discovery, non-disruptive process handling, automated workspace cleanup, and hardware-agnostic permission hardening—delivering a refined, single-command experience.

---

## Core Capabilities

* **Dual-Engine Execution**: Dynamically targets PowerShell 7 (`pwsh`) with seamless fallback to Windows PowerShell 5.1.
* **Universal Registry Discovery**: Scans environment variables, Scoop installations, and system registry paths (`App Paths`) to locate WinRAR under any custom directory.
* **SID-Based Hardening**: Applies universal NTFS access control rules using security identifiers (`S-1-5-32-545`), guaranteeing cross-language OS compatibility.
* **Self-Healing License Engine**: Evaluates existing license integrity prior to payload execution to eliminate redundant writes.
* **Fault-Tolerant Retry Logic**: Employs millisecond-level retry loops during critical file operations to prevent software lockouts or antivirus interference.
* **Process & Workspace Cleanup**: Gracefully terminates background processes (`rar`, `unrar`, `winrar`) and sweeps away temporary installation artifacts.

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

## Architecture

```text
WinRAR-Activator/
├── Run.bat               # Environment bootstrap launcher
├── WinRAR-Activator.ps1  # Core engine & self-healing framework
└── README.md             # Project documentation

```

---

## Developer Info

* **Author**: `k0ishiii`
* **Discord**: `misakisakura3`

---

## License

This project is licensed under the terms of the **MIT License**. Refer to [LICENSE](https://www.google.com/search?q=./LICENSE) for full details.