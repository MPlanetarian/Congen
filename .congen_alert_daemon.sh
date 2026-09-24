#!/usr/bin/env bash
# Congen Alert Monitor Daemon
# Auto-generated — do not edit. Regenerated each start.

ALERT_WAV="/var/home/mplanetarian/Documents/BASH_SCRIPTS/Congen/.congen_alert.wav"
LOG_FILE="/var/home/mplanetarian/Documents/BASH_SCRIPTS/Congen/Congen.log"
KDECONNECT_CFG_DIR="/home/mplanetarian/.config/kdeconnect"
PID_FILE="/var/home/mplanetarian/Documents/BASH_SCRIPTS/Congen/.congen_alerts.pid"
STATE_FILE="/var/home/mplanetarian/Documents/BASH_SCRIPTS/Congen/.congen_alerts_enabled"

echo $$ > "${PID_FILE}"
trap 'rm -f "${PID_FILE}"; exit 0' EXIT TERM INT HUP

# ── Audio playback (non-blocking) ─────────────────────────────────────────────
play_alert() {
    [[ ! -f "${ALERT_WAV}" ]] && return
    if   command -v paplay  >/dev/null 2>&1; then
        paplay  "${ALERT_WAV}" >/dev/null 2>&1 &
    elif command -v pw-play >/dev/null 2>&1; then
        pw-play "${ALERT_WAV}" >/dev/null 2>&1 &
    elif command -v aplay   >/dev/null 2>&1; then
        aplay -q "${ALERT_WAV}" >/dev/null 2>&1 &
    elif command -v play    >/dev/null 2>&1; then
        play -q "${ALERT_WAV}" >/dev/null 2>&1 &
    elif command -v ffplay  >/dev/null 2>&1; then
        ffplay -nodisp -autoexit -loglevel quiet \
               "${ALERT_WAV}" >/dev/null 2>&1 &
    fi
}

# ── Collect registered script paths from all KDE Connect device configs ────────
declare -a _scripts=()
_last_refresh=0

refresh_scripts() {
    _scripts=()
    while IFS= read -r scr; do
        [[ -n "${scr}" ]] && _scripts+=("${scr}")
    done < <(python3 - "${KDECONNECT_CFG_DIR}" <<'PYEOF'
import sys, os, glob, re, json
kdir = sys.argv[1]
found_scripts = set()
for cfg in glob.glob(f"{kdir}/*/kdeconnect_runcommand/config"):
    try:
        with open(cfg, 'r', encoding='utf-8', errors='ignore') as f:
            lines = f.readlines()
        for line in lines:
            line = line.strip()
            if line.startswith("commands="):
                raw = line[len("commands="):].strip()
                if (raw.startswith('"') and raw.endswith('"')) or (raw.startswith("'") and raw.endswith("'")):
                    raw = raw[1:-1].strip()
                if raw.startswith("@ByteArray(") and raw.endswith(")"):
                    raw = raw[len("@ByteArray("):-1].strip()
                if (raw.startswith('"') and raw.endswith('"')) or (raw.startswith("'") and raw.endswith("'")):
                    raw = raw[1:-1].strip()
                if r'\"' in raw:
                    raw = raw.replace(r'\"', '"')
                try:
                    data = json.loads(raw)
                    if isinstance(data, str): data = json.loads(data)
                    if isinstance(data, dict):
                        for u, entry in data.items():
                            if isinstance(entry, dict) and "command" in entry:
                                cmd = entry["command"].strip()
                                if cmd: found_scripts.add(cmd)
                except Exception:
                    pass
                break
        in_commands = False
        for line in lines:
            line = line.strip()
            if line == "[commands]": in_commands = True; continue
            if in_commands and line.startswith("["): in_commands = False; continue
            if in_commands and "=" in line:
                k, v = line.split("=", 1)
                if re.match(r'^cmd[0-9]+\\command$', k.strip()):
                    c = v.strip()
                    if c: found_scripts.add(c)
    except Exception:
        pass
for s in sorted(found_scripts):
    print(s)
PYEOF
)
}

# ── Main polling loop ─────────────────────────────────────────────────────────
declare -A _seen=()
_alert_n=0

refresh_scripts
_last_refresh=${SECONDS}

while true; do
    # Self-terminate if alerts are disabled from the UI
    [[ ! -f "${STATE_FILE}" ]] && exit 0

    # Refresh script list every 60 s (picks up newly added commands)
    if (( SECONDS - _last_refresh >= 60 )); then
        refresh_scripts
        _last_refresh=${SECONDS}
    fi

    # Check each registered script for new running PIDs
    for scr in "${_scripts[@]:-}"; do
        [[ -z "${scr}" ]] && continue
        local scr_base
        scr_base="$(basename "${scr%% *}")"
        while IFS= read -r pid; do
            [[ -z "${pid}" ]] && continue
            if [[ -z "${_seen[${pid}]:-}" ]]; then
                _seen["${pid}"]="1"
                play_alert
                (( _alert_n++ ))
                printf '[%s] CONGEN ALERT #%d | PID=%s | Script=%s\n' \
                    "$(date '+%Y-%m-%d %H:%M:%S')" \
                    "${_alert_n}" \
                    "${pid}" \
                    "${scr}" >> "${LOG_FILE}"
            fi
        done < <(pgrep -f "${scr_base}" 2>/dev/null || true)
    done

    # Keep seen-PID map bounded
    if (( ${#_seen[@]} > 500 )); then
        unset _seen; declare -A _seen=()
    fi

    sleep 0.25
done
