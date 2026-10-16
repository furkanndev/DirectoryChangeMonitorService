# DirectoryChangeMonitorService

[![Linux](https://img.shields.io/badge/Platform-Linux-FCC624?style=flat-square&logo=linux&logoColor=black)](https://www.linux.org)
[![Bash](https://img.shields.io/badge/Shell-Bash%204%2B-4EAA25?style=flat-square&logo=gnu-bash&logoColor=white)](https://www.gnu.org/software/bash/)
[![Systemd](https://img.shields.io/badge/Daemon-Systemd-27272a?style=flat-square)](https://systemd.io/)
[![inotify](https://img.shields.io/badge/Engine-inotify--tools-blue?style=flat-square)](https://github.com/inotify-tools/inotify-tools)
[![License: MIT](https://img.shields.io/badge/License-MIT-gray?style=flat-square)](LICENSE)

A lightweight, automated Linux background daemon that monitors real-time filesystem directory events and persistently logs detailed audit entries using the Linux kernel `inotify` subsystem and `systemd`.

---

## Overview

Filesystem auditing is fundamental for security, integrity monitoring, and automated event workflows on Linux systems. `DirectoryChangeMonitorService` leverages kernel-level `inotifywait` to capture file and folder mutations with zero polling overhead. Every filesystem trigger is formatted with monotonic index numbers, ISO timestamps, and exact event categories, then appended atomically to an audit log.

### Monitored Event Categories

The daemon listens to the following POSIX filesystem events:

- `modify`: File content updates and writes.
- `attrib`: Metadata modifications (permissions, timestamps, ownership).
- `close_write`: File closed after write access (guarantees write completion).
- `move`: Atomic file/directory renames and path relocations.
- `create`: New file or directory creations.
- `delete`: File or directory unlinking and deletions.

---

## Architecture & Workflow

```
[Target Directory] 
       │
       ▼
 [Linux Kernel (inotify subsystem)]
       │
       ▼
 [script.sh (Event Capture Loop via inotifywait)]
       │
       ├── Parses: {path, action, file}
       ├── Generates: Timestamp & Sequence Number
       │
       ▼
 [Log Persistence] ────► /path/to/kayit.txt
       │
 [systemd Supervisor] ──► Auto-restart, status reporting, boot-start
```

---

## Prerequisites

Ensure `inotify-tools` and `bash` are installed on your Linux system:

```bash
# Debian / Ubuntu
sudo apt update && sudo apt install -y inotify-tools bash

# Fedora / RHEL
sudo dnf install -y inotify-tools bash

# Arch Linux
sudo pacman -S inotify-tools bash
```

---

## Configuration & Deployment

### 1. Clone Repository

```bash
git clone https://github.com/furkanndev/DirectoryChangeMonitorService.git
cd DirectoryChangeMonitorService
```

### 2. Configure Monitoring Script

Edit `script.sh` to define your target directory and desired log location:

```bash
HEDEF_DIZIN="/var/log/audit-target"      # Directory to monitor
KAYIT_DOSYASI="/var/log/kayit.txt"        # Destination audit log file
```

Grant executable permissions:

```bash
chmod +x script.sh
```

### 3. Deploy Systemd Service Unit

Update `myservice.service` with the absolute path to your `script.sh` script, then copy the unit file to systemd's configuration directory:

```bash
sudo cp myservice.service /etc/systemd/system/directory-monitor.service
sudo systemctl daemon-reload
```

---

## Service Management

Manage the background daemon using standard `systemctl` commands:

```bash
# Start the monitoring service
sudo systemctl start directory-monitor.service

# Enable automatic start on system boot
sudo systemctl enable directory-monitor.service

# Check service runtime status
sudo systemctl status directory-monitor.service

# Inspect system logs
journalctl -u directory-monitor.service -f
```

---

## Log Output Format

Audit entries in the output log follow this structured format:

```
<Sequence>. <Target_Directory> dizininde <YYYY-MM-DD HH:MM:SS> tarihinde değişiklik yapıldı: <Path> <Action> <File>
```

### Sample Log Output

```text
1. /home/user/Desktop dizininde 2026-10-16 14:22:01 tarihinde değişiklik yapıldı: /home/user/Desktop/ CREATE document.pdf
2. /home/user/Desktop dizininde 2026-10-16 14:22:03 tarihinde değişiklik yapıldı: /home/user/Desktop/ MODIFY document.pdf
3. /home/user/Desktop dizininde 2026-10-16 14:22:03 tarihinde değişiklik yapıldı: /home/user/Desktop/ CLOSE_WRITE,CLOSE document.pdf
4. /home/user/Desktop dizininde 2026-10-16 14:25:10 tarihinde değişiklik yapıldı: /home/user/Desktop/ DELETE document.pdf
```

---

## License

This project is licensed under the [MIT License](LICENSE).
