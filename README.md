# SysAdminShowcase
This is my Personal Repository showing off finished code that is used for Systems Administration

## 📚 Scripts Inventory

This repository contains various system administration scripts and tools. Below is an automatically generated inventory of available scripts:

### Shell Scripts

#### 🔧 `Apple-macOS/MacPortsAutoDetectInstall.sh`

**Description:**
```
This is a cleaned up and sanatized version of my original scrypt for showcase & sharing purposes.
Originally Developed for my support of scientific research users. 
TThis script's goal was to make it so a apple systems administrator didn't have to use composer to build
out a custom installer each time a new macos version was release. This script as of 10/30/2025 now has some
automation to upgrade the github urls from teh macports procject to the latest version. This was done
```

**Functions:**
- `check_os_version()`
- `check_macports_installed()`
- `backup_macports()`
- `install_macports()`

---

#### 🔧 `Apple-macOS/appleDiskUtil.sh`

**Description:**
```
The goal of this script is to find the storage utilization of a macOS system. 
A common issue is that /Applications take up a huge amount of disk space
with that being said. User storage typically suffers as a result. 
So the real question comes down to "What's in the user's directory," and how 
does that influence the system selection for purchasing end-user compute?
```

**Functions:**
- `check_home_directory_size()`
- `check_disk_space()`
- `log_data()`
- `Create Plist()`

---


## 📋 About

This repository serves as a showcase of production-ready system administration scripts and tools. Each script is designed to solve real-world administrative challenges and can be adapted for various environments.

## 🔄 Auto-Generated Documentation

This README is automatically updated by a GitHub Actions workflow whenever scripts are added or modified. The workflow:
- Scans the repository for scripts (`.sh`, `.py`, `.ps1`)
- Extracts documentation from comments and code structure
- Updates this README with the inventory and descriptions

Last updated: $(date -u +"%Y-%m-%d %H:%M:%S UTC")

---

*For more information or contributions, please open an issue or pull request.*
