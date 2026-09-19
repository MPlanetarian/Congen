# CONGEN (KDE Connect Commands Generator)

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/Platform-Linux%20%2F%20KDE%20Plasma-blue)](https://kde.org/plasma-desktop/)
[![Tested With](https://img.shields.io/badge/PlasmaShell-6.7.4-brightgreen)](https://kde.org)
[![Version](https://img.shields.io/badge/Release-v0.1-orange)](https://github.com/mplanetarian/Congen)

**Congen** is an interactive, terminal-based KDE Connect CLI manager and command orchestration suite designed for Linux and KDE Plasma. It streamlines the creation, installation, scheduling, and monitoring of remote execution commands across paired KDE Connect devices.

---

## 🖥️ Preview

```text
  ██████╗  ██████╗ ███╗   ██╗ ██████╗ ███████╗███╗   ██╗
 ██╔════╝ ██╔═══██╗████╗  ██║██╔════╝ ██╔════╝████╗  ██║
 ██║      ██║   ██║██╔██╗ ██║██║  ███╗█████╗  ██╔██╗ ██║
 ██║      ██║   ██║██║╚██╗██║██║   ██║██╔══╝  ██║╚██╗██║
 ╚██████╗ ╚██████╔╝██║ ╚████║╚██████╔╝███████╗██║ ╚████║
  ╚═════╝  ╚═════╝ ╚═╝  ╚═══╝ ╚═════╝ ╚══════╝╚═╝  ╚═══╝

 KDE Connect Commands Generator   v1.0.0

 Service Status   :  ● Enabled
 Network Status   :  ● Up  — wlp2s0 (Wi-Fi)
 Commands Installed: 1

 ── Live Monitor ────────────────────────────────────────────
 Active Runs      :  ○ None
 Total Runs       :  No runs recorded yet
 Last Success     :  None recorded
 Last Failure     :  None recorded
```

---

## ✨ Features

- **Interactive Command Generator (`[1]`):** Prompts for command names, target executable script paths, and descriptive summaries, registering them directly into KDE Connect.
- **Inventory Management (`[2]`):** Inspect all currently registered commands with one-key removal capabilities.
- **Direct CLI Execution (`[3]`):** Trigger configured KDE Connect actions directly from the terminal interface.
- **Task Scheduling (`[4]`):** Sequential and delayed task execution queue management (`Congen_Schedule.txt`).
- **Live Health & Service Monitoring:** Real-time detection of the KDE Connect daemon service status (`Enabled`/`Disabled`), active network interface diagnostics, and command run-state metrics.
- **Detailed Logging (`[5]`):** Persistent audit log tracking command additions, service checks, and execution status (`Congen.log`).
- **Export / Import Utilities (`[6]`):** Back up or deploy command profiles across multiple Linux workstations (`CONGEN_IMPORT/`).
- **Automated Documentation Generator (`[7]`):** Generates and formats reference manuals (`Congen_Commands_List.txt` and `CONGEN_USER_MANUAL/`).
- **Auditory Notifications & Daemon (`[8]`):** Background daemon (`.congen_alert_daemon.sh`) providing audio alerts (`.congen_alert.wav`) for successful and failed triggers.
- **Shortcut Generator (`[9]`):** Map local desktop keyboard shortcuts into remote KDE Connect command calls.

---

## 📋 System Requirements & Compatibility

- **OS:** Linux (x86_64, ARM64)
- **Desktop Environment:** KDE Plasma (Tested against `plasmashell 6.7.4`)
- **Required Packages:**
  - `kdeconnect` / `kdeconnect-cli`
  - `bash` (4.4+)
  - `systemd` (user session)
  - `iproute2` / `iw` (for interface detection)
  - `alsa-utils` or `pulseaudio-utils` / `pipewire` (for alert daemon audio playback)

---

## 🚀 Installation & Setup

### 1. Clone the Repository

```bash
git clone https://github.com/mplanetarian/Congen.git
cd Congen
```

### 2. Make Executable

Ensure the main executable and background daemon have execute permissions:

```bash
chmod +x Congen .congen_alert_daemon.sh
```

### 3. Run Congen

Launch the manager:

```bash
./Congen
```

*(Optional)* Create a symlink in your local bin path to run Congen from anywhere:

```bash
mkdir -p ~/.local/bin
ln -s "$(pwd)/Congen" ~/.local/bin/congen
```

---

## 📂 Project Architecture

```text
Congen/
├── Congen                        # Main interactive CLI executable
├── Congen_Commands_List.txt      # Registered command reference index
├── Congen_Schedule.txt           # Task queue and scheduled runs
├── Congen.log                    # Runtime execution and debug logs
├── CONGEN_USER_MANUAL/           # Multi-format user guides & manuals
├── CONGEN_IMPORT/                # Configuration import directory
├── .congen_alert_daemon.sh       # Background sound notification daemon
├── .congen_alert.wav             # Notification audio asset
├── .congen_jobs/                 # Internal job spool directory
└── README.md                     # Repository documentation
```

---

## ⚙️ Recommended `.gitignore`

When initializing your git tracking, ignore local run-state flags and PID trackers:

```gitignore
# Runtime state & locks
.congen_alerts.pid
.congen_alerts_firstrun
.congen_alerts_enabled
*.bak

# Log files (optional: commit if tracking samples)
# Congen.log
```

---

## 🤝 Contributing & Support

1. Fork the Project: `https://github.com/mplanetarian/Congen`
2. Create your Feature Branch: `git checkout -b feature/NewFeature`
3. Commit your Changes: `git commit -m 'Add NewFeature'`
4. Push to the Branch: `git push origin feature/NewFeature`
5. Open a Pull Request

For bugs, issues, or KDE Plasma version reports, please use the [GitHub Issue Tracker](https://github.com/mplanetarian/Congen/issues).

---

## 📄 License

Distributed under the MIT License. See `LICENSE` for more information.