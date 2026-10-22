#!/usr/bin/env bash
# Rollback all performance optimizations applied by tools/performance.sh.
# This script re-enables disabled services, restores default settings, and
# reverts the TV to its original state before performance optimizations.
#
# Usage: TV_HOST=192.168.1.50 tools/performance_rollback.sh
#
# NOTE: This does NOT restore packages disabled via debloat.txt.
#       Use tools/restore.sh for that.
set -euo pipefail

cd "$(dirname "$0")/.."
: "${TV_HOST:?set TV_HOST to the TV IP address, e.g. TV_HOST=192.168.1.50 $0}"

PY=tools/venv/bin/python
[ -x "$PY" ] || PY=tools/venv/Scripts/python.exe
export MSYS_NO_PATHCONV=1
[ -x "$PY" ] || { echo "run: python3 -m venv tools/venv && tools/venv/bin/pip install -r tools/requirements.txt" >&2; exit 1; }

tv() { "$PY" -I tools/tv.py "$@"; }

echo "=== Rolling back Performance Optimizations on $TV_HOST ==="
echo ""

# =============================================================================
# 1. RE-ENABLE GOOGLE SERVICES
# =============================================================================
echo "--- Re-enabling Google services ---"
tv "pm enable com.google.android.gms/.update.SystemUpdateService" 2>/dev/null || true
tv "pm enable com.google.android.gms/.update.SystemUpdateActivity" 2>/dev/null || true
tv "pm enable com.google.android.gms/.nearby.exposure.ExposureNotificationService" 2>/dev/null || true
tv "pm enable com.google.android.gms/.update.PackageInstallerService" 2>/dev/null || true

# =============================================================================
# 2. RESTORE AUTO-SYNC AND DATA ROAMING
# =============================================================================
echo "--- Restoring auto-sync and data roaming ---"
tv "settings put global auto_sync 1"
tv "settings put global data_roaming 1"

# =============================================================================
# 3. RESTORE ANIMATIONS TO DEFAULT (1 = normal)
# =============================================================================
echo "--- Restoring animations to default ---"
tv "settings put global window_animation_scale 1"
tv "settings put global transition_animation_scale 1"
tv "settings put global animator_duration_scale 1"

# =============================================================================
# 4. RESTORE BACKGROUND PROCESS LIMIT (default is 4 for TVs)
# =============================================================================
echo "--- Restoring background process limit to default ---"
tv "settings delete global bg_app_limit" 2>/dev/null || true

# =============================================================================
# 5. DISABLE LOW RAM MODE
# =============================================================================
echo "--- Disabling low RAM mode ---"
tv "setprop ro.config.low_ram false"

# =============================================================================
# 6. RE-ENABLE LOCATION SERVICES
# =============================================================================
echo "--- Re-enabling location services ---"
tv "pm enable com.google.android.location.fused" 2>/dev/null || true
tv "settings put global location_mode 3"  # 3 = High accuracy

# =============================================================================
# 7. RE-ENABLE SYSTEM SERVICES
# =============================================================================
echo "--- Re-enabling system services ---"
tv "pm enable com.android.printspooler" 2>/dev/null || true
tv "pm enable com.android.htmlviewer" 2>/dev/null || true
tv "pm enable com.android.dreams.basic" 2>/dev/null || true
tv "pm enable com.android.soundpicker" 2>/dev/null || true
tv "pm enable com.android.managedprovisioning" 2>/dev/null || true

# =============================================================================
# 8. RE-ENABLE FREEVIEW UK SERVICES
# =============================================================================
echo "--- Re-enabling Freeview UK services ---"
tv "pm enable uk.co.freeview.mdsclient" 2>/dev/null || true
tv "pm enable uk.co.freeview.amc_catchup" 2>/dev/null || true
tv "pm enable uk.co.freeview.onnow" 2>/dev/null || true
tv "pm enable uk.co.freeview.sony_kids_vod" 2>/dev/null || true
tv "pm enable uk.co.freeview.uktv" 2>/dev/null || true
tv "pm enable org.droidtv.freeviewplayers" 2>/dev/null || true
tv "pm enable uk.co.freeview.fvpconfigauth" 2>/dev/null || true
tv "pm enable uk.co.freeview.explore" 2>/dev/null || true
tv "pm enable uk.co.freeview.bbc_sounds" 2>/dev/null || true
tv "pm enable uk.co.freeview.bbc" 2>/dev/null || true
tv "pm enable uk.co.freeview.ch5" 2>/dev/null || true
tv "pm enable uk.co.freeview.itv" 2>/dev/null || true
tv "pm enable uk.co.freeview.stv" 2>/dev/null || true
tv "pm enable uk.co.freeview.amc_horror" 2>/dev/null || true
tv "pm enable uk.co.freeview.ch4_vod" 2>/dev/null || true

# =============================================================================
# 9. RE-ENABLE PHILIPS TELEMETRY AND BLOAT
# =============================================================================
echo "--- Re-enabling Philips telemetry and bloat ---"
tv "pm enable org.droidtv.candeebug" 2>/dev/null || true
tv "pm enable org.droidtv.ci" 2>/dev/null || true
tv "pm enable org.droidtv.gel" 2>/dev/null || true
tv "pm enable org.droidtv.icp" 2>/dev/null || true
tv "pm enable org.droidtv.usagelogger" 2>/dev/null || true
tv "pm enable org.droidtv.tv.frameworklogger" 2>/dev/null || true
tv "pm enable org.droidtv.dropboxprovider" 2>/dev/null || true
tv "pm enable org.droidtv.nettv.market" 2>/dev/null || true
tv "pm enable org.droidtv.nettvrecommender" 2>/dev/null || true
tv "pm enable org.droidtv.recommendation" 2>/dev/null || true
tv "pm enable org.droidtv.demome" 2>/dev/null || true
tv "pm enable org.droidtv.nettvapps" 2>/dev/null || true
tv "pm enable org.droidtv.nettvregistration" 2>/dev/null || true
tv "pm enable org.droidtv.sticker" 2>/dev/null || true

# =============================================================================
# 10. RE-ENABLE GOOGLE TV LAUNCHER
# =============================================================================
echo "--- Re-enabling Google TV launcher ---"
tv "pm enable com.google.android.tvlauncher" 2>/dev/null || true
tv "pm enable org.droidtv.leanbackcustomizer" 2>/dev/null || true

# =============================================================================
# 11. RESET THEME TO DEFAULT
# =============================================================================
echo "--- Resetting theme to default ---"
tv "rm -f /sdcard/Android/data/com.gathin.tvhome/files/config.json"
tv "rm -f /sdcard/Android/data/com.gathin.tvhome/files/wallpaper.jpg"
tv "am force-stop com.gathin.tvhome"
tv "am start -n com.google.android.tvlauncher/.MainActivity"

# =============================================================================
# 12. RESTART TV TO APPLY ALL CHANGES
# =============================================================================
echo ""
echo "=== Performance optimizations rolled back successfully! ==="
echo ""
echo "To see the changes, restart your TV or run:"
echo "  TV_HOST=$TV_HOST adb shell reboot"
echo ""
echo "To re-apply optimizations, run:"
echo "  TV_HOST=$TV_HOST tools/performance.sh"
