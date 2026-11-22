<div align="center">

# WinRAR Activator

**One command. Permanent registration.**

![Version](https://img.shields.io/badge/version-v2.4.2-purple?style=flat-square)
![PowerShell](https://img.shields.io/badge/powershell-5.1%2B%20%7C%207%2B-blue?style=flat-square&logo=powershell&logoColor=white)
![Platform](https://img.shields.io/badge/platform-windows-lightgrey?style=flat-square&logo=windows&logoColor=white)
![License](https://img.shields.io/badge/license-MIT-green?style=flat-square)

</div>

---

## Quick Start

```powershell
irm "https://raw.githubusercontent.com/k0ishiii/WinRAR-Activator/main/WinRAR-Activator.ps1" | iex
```

The script elevates itself, locates WinRAR, deploys the license, and hardens the file. One run is all it takes.

For local use, run `Run.bat` from a clone of the repository.

## Features

| | |
|---|---|
| **Auto-elevation** | Requests UAC once, with loop protection |
| **Universal discovery** | Standard paths, Scoop, and registry `App Paths` |
| **Safe processes** | Graceful close, bounded kill fallback |
| **License integrity** | Verified before any overwrite |
| **File hardening** | `ReadOnly` and NTFS ACL applied separately |
| **Fast-path** | Skips WinRAR restart cycles when activation is already complete |
| **Explicit exit codes** | `0` success, `1` failure, `2` elevation loop |
| **Targeted cleanup** | Temp and VirtualStore scoped to WinRAR only |
| **Remote staging** | Temp `.ps1` for correct parameter forwarding |

## Requirements

Windows 10 / 11 · PowerShell 5.1+ or 7+ · WinRAR installed · Administrator access (requested automatically)

## Troubleshooting

| Issue | Fix |
|---|---|
| `WinRAR installation not found` | Install WinRAR, rerun |
| `NTFS ACL hardening not applied` | Non-NTFS volume; `ReadOnly` still applies |
| `WinRAR terminated immediately after launch` | Reinstall WinRAR |

## License

MIT © 2026 [k0ishiii](https://github.com/k0ishiii)