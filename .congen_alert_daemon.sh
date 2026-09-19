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
    local cfg_file k v
    while IFS= read -r -d '' cfg_file; do
        while IFS='=' read -r k v; do
            k="${k#"${k%%[![:space:]]*}"}"
            if [[ "${k}" =~ \\command$ ]]; then
                [[ -n "${v}" ]] && _scripts+=("${v}")
            fi
        done < <(awk '/^\[commands\]/{f=1;next} f&&/^\[/{f=0} f{print}' \
                     "${cfg_file}" 2>/dev/null)
    done < <(find "${KDECONNECT_CFG_DIR}" -name "config" \
                  -path "*/kdeconnect_runcommand/*" -print0 2>/dev/null)
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
        done < <(pgrep -f "${scr}" 2>/dev/null || true)
    done

    # Keep seen-PID map bounded
    if (( ${#_seen[@]} > 500 )); then
        unset _seen; declare -A _seen=()
    fi

    sleep 1
done
