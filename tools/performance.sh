#!/usr/bin/env bash
# Apply performance optimizations to Android TV (Philips TPM191E and similar).
# This script disables unnecessary services, tweaks system settings, and applies
# optimizations to improve speed and responsiveness on low-RAM devices.
#
# Usage: TV_HOST=192.168.1.50 tools/performance.sh
#
# To revert all changes, use: TV_HOST=192.168.1.50 tools/performance_rollback.sh
#
# NOTE: This script assumes you are using com.gathin.tvhome as your launcher.
#       Do NOT run this if you are still using the stock launcher.
set -euo pipefail

cd "$(dirname "$0")/.."
: "${TV_HOST:?set TV_HOST to the TV IP address, e.g. TV_HOST=192.168.1.50 $0}"

PY=tools/venv/bin/python
[ -x "$PY" ] || PY=tools/venv/Scripts/python.exe
export MSYS_NO_PATHCONV=1
[ -x "$PY" ] || { echo "run: python3 -m venv tools/venv && tools/venv/bin/pip install -r tools/requirements.txt" >&2; exit 1; }

tv() { "$PY" -I tools/tv.py "$@"; }

echo "=== Applying Performance Optimizations to $TV_HOST ==="
echo ""

# =============================================================================
# 1. DISABLE UNNECESSARY GOOGLE SERVICES
# =============================================================================
echo "--- Disabling unnecessary Google services ---"
tv "pm disable-user --user 0 com.google.android.gms/.update.SystemUpdateService" 2>/dev/null || true
tv "pm disable-user --user 0 com.google.android.gms/.update.SystemUpdateActivity" 2>/dev/null || true
tv "pm disable-user --user 0 com.google.android.gms/.nearby.exposure.ExposureNotificationService" 2>/dev/null || true
tv "pm disable-user --user 0 com.google.android.gms/.update.PackageInstallerService" 2>/dev/null || true

# =============================================================================
# 2. DISABLE AUTO-SYNC AND DATA ROAMING
# =============================================================================
echo "--- Disabling auto-sync and data roaming ---"
tv "settings put global auto_sync 0"
tv "settings put global data_roaming 0"

# =============================================================================
# 3. OPTIMIZE ANIMATIONS (0 = disabled, 0.5 = half speed, 1 = normal)
# =============================================================================
echo "--- Disabling animations for better performance ---"
tv "settings put global window_animation_scale 0"
tv "settings put global transition_animation_scale 0"
tv "settings put global animator_duration_scale 0"

# =============================================================================
# 4. LIMIT BACKGROUND PROCESSES (default is 4-8, we set to 2 for 2GB RAM)
# =============================================================================
echo "--- Limiting background processes to 2 ---"
tv "settings put global bg_app_limit 2"

# =============================================================================
# 5. ENABLE LOW RAM MODE
# =============================================================================
echo "--- Enabling low RAM mode ---"
tv "setprop ro.config.low_ram true"

# =============================================================================
# 6. CLEAR APP CACHES (frees up storage and reduces I/O)
# =============================================================================
echo "--- Clearing app caches ---"
tv "pm trim-caches 999"

# Clear specific app caches
tv "pm clear --user 0 com.google.android.gms" 2>/dev/null || true
tv "pm clear --user 0 com.google.android.youtube.tv" 2>/dev/null || true
tv "pm clear --user 0 com.netflix.ninja" 2>/dev/null || true
tv "pm clear --user 0 com.amazon.amazonvideo.livingroom" 2>/dev/null || true

# =============================================================================
# 7. DISABLE LOCATION SERVICES (if not needed)
# =============================================================================
echo "--- Disabling location services ---"
tv "pm disable-user --user 0 com.google.android.location.fused" 2>/dev/null || true
tv "settings put global location_mode 0"

# =============================================================================
# 8. DISABLE UNUSED SYSTEM SERVICES
# =============================================================================
echo "--- Disabling unused system services ---"
tv "pm disable-user --user 0 com.android.printspooler" 2>/dev/null || true
tv "pm disable-user --user 0 com.android.htmlviewer" 2>/dev/null || true
tv "pm disable-user --user 0 com.android.dreams.basic" 2>/dev/null || true
tv "pm disable-user --user 0 com.android.soundpicker" 2>/dev/null || true
tv "pm disable-user --user 0 com.android.managedprovisioning" 2>/dev/null || true

# =============================================================================
# 9. DISABLE FREEVIEW UK SERVICES (irrelevant for Italy)
# =============================================================================
echo "--- Disabling Freeview UK services ---"
tv "pm disable-user --user 0 uk.co.freeview.mdsclient" 2>/dev/null || true
tv "pm disable-user --user 0 uk.co.freeview.amc_catchup" 2>/dev/null || true
tv "pm disable-user --user 0 uk.co.freeview.onnow" 2>/dev/null || true
tv "pm disable-user --user 0 uk.co.freeview.sony_kids_vod" 2>/dev/null || true
tv "pm disable-user --user 0 uk.co.freeview.uktv" 2>/dev/null || true
tv "pm disable-user --user 0 org.droidtv.freeviewplayers" 2>/dev/null || true
tv "pm disable-user --user 0 uk.co.freeview.fvpconfigauth" 2>/dev/null || true
tv "pm disable-user --user 0 uk.co.freeview.explore" 2>/dev/null || true
tv "pm disable-user --user 0 uk.co.freeview.bbc_sounds" 2>/dev/null || true
tv "pm disable-user --user 0 uk.co.freeview.bbc" 2>/dev/null || true
tv "pm disable-user --user 0 uk.co.freeview.ch5" 2>/dev/null || true
tv "pm disable-user --user 0 uk.co.freeview.itv" 2>/dev/null || true
tv "pm disable-user --user 0 uk.co.freeview.stv" 2>/dev/null || true
tv "pm disable-user --user 0 uk.co.freeview.amc_horror" 2>/dev/null || true
tv "pm disable-user --user 0 uk.co.freeview.ch4_vod" 2>/dev/null || true

# =============================================================================
# 10. DISABLE PHILIPS TELEMETRY AND BLOAT
# =============================================================================
echo "--- Disabling Philips telemetry and bloat ---"
tv "pm disable-user --user 0 org.droidtv.candeebug" 2>/dev/null || true
tv "pm disable-user --user 0 org.droidtv.ci" 2>/dev/null || true
tv "pm disable-user --user 0 org.droidtv.gel" 2>/dev/null || true
tv "pm disable-user --user 0 org.droidtv.icp" 2>/dev/null || true
tv "pm disable-user --user 0 org.droidtv.usagelogger" 2>/dev/null || true
tv "pm disable-user --user 0 org.droidtv.tv.frameworklogger" 2>/dev/null || true
tv "pm disable-user --user 0 org.droidtv.dropboxprovider" 2>/dev/null || true
tv "pm disable-user --user 0 org.droidtv.nettv.market" 2>/dev/null || true
tv "pm disable-user --user 0 org.droidtv.nettvrecommender" 2>/dev/null || true
tv "pm disable-user --user 0 org.droidtv.recommendation" 2>/dev/null || true
tv "pm disable-user --user 0 org.droidtv.demome" 2>/dev/null || true
tv "pm disable-user --user 0 org.droidtv.nettvapps" 2>/dev/null || true
tv "pm disable-user --user 0 org.droidtv.nettvregistration" 2>/dev/null || true
tv "pm disable-user --user 0 org.droidtv.sticker" 2>/dev/null || true

# =============================================================================
# 11. DISABLE GOOGLE TV LAUNCHER (only after verifying com.gathin.tvhome works)
# =============================================================================
echo "--- Disabling Google TV launcher (stock launcher) ---"
echo "NOTE: Ensure com.gathin.tvhome is set as default launcher first!"
tv "pm disable-user --user 0 com.google.android.tvlauncher" 2>/dev/null || true
tv "pm disable-user --user 0 org.droidtv.leanbackcustomizer" 2>/dev/null || true

# =============================================================================
# 12. APPLY CUSTOM ITALY THEME (if available)
# =============================================================================
echo "--- Applying custom_italy theme ---"
if [ -f "themes/custom_italy/config.json" ]; then
    tv "mkdir -p /sdcard/Android/data/com.gathin.tvhome/files"
    # Push theme using theme.sh logic
    THEME="themes/custom_italy"
    if [ -f "$THEME/config.json" ]; then
        "$PY" -I tools/b64push.py "$THEME/config.json" /data/local/tmp/cyt-theme-config.json
        tv "mkdir -p /sdcard/Android/data/com.gathin.tvhome/files && cp /data/local/tmp/cyt-theme-config.json /sdcard/Android/data/com.gathin.tvhome/files/config.json"
        tv "rm -f /data/local/tmp/cyt-theme-config.json"
    fi
    # Restart Home to apply theme
    tv "am force-stop com.gathin.tvhome; am start -n com.gathin.tvhome/.MainActivity"
else
    echo "custom_italy theme not found, skipping..."
fi

# =============================================================================
# 13. RESTART TV TO APPLY ALL CHANGES
# =============================================================================
echo ""
echo "=== Performance optimizations applied successfully! ==="
echo ""
echo "To see the changes, restart your TV or run:"
echo "  TV_HOST=$TV_HOST adb shell reboot"
echo ""
echo "To revert all changes, run:"
echo "  TV_HOST=$TV_HOST tools/performance_rollback.sh"
