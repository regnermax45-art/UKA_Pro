#!/system/bin/sh

##########################################################################################
# UKA_Pro Enhanced Uninstallation Script
# Clean removal of all UKA_Pro Enhanced components
##########################################################################################

echo "🗑️  Uninstalling UKA_Pro Enhanced..."

# Main installation directory
UKA_DIR="/data/local/uka_pro"

# Remove main installation
if [ -d "$UKA_DIR" ]; then
    echo "📁 Removing main installation: $UKA_DIR"
    rm -rf "$UKA_DIR"
else
    echo "ℹ️  Main installation directory not found"
fi

# Remove legacy directories (from old versions)
echo "🧹 Cleaning up legacy directories..."
rm -rf /data/local/binary
rm -rf /data/local/python
rm -rf /data/local/UnpackerContexts
rm -rf /data/local/UnpackerPayload
rm -rf /data/local/UnpackerPreloader
rm -rf /data/local/UnpackerQfil
rm -rf /data/local/UnpackerSystem
rm -rf /data/local/UnpackerSuper
rm -rf /data/local/UnpackerUpdateApp

# Remove AIK if present
if [ -d "/data/local/AIK-mobile" ]; then
    echo "📦 Removing Android Image Kitchen..."
    /data/local/AIK-mobile/bin/aik --uninstall 2>/dev/null || true
    rm -rf /data/local/AIK-mobile
fi

# Remove old module directories
echo "🗂️  Removing old module directories..."
rm -rf /data/adb/modules/UKA
rm -rf /data/adb/modules/UKA_Pro
rm -rf /data/adb/modules/UKA_Pro_Enhanced

# Remove temporary files
echo "🧽 Cleaning temporary files..."
rm -rf /data/local/tmp/uka_*
rm -rf /tmp/uka_*

# Remove any remaining UKA-related files
find /data/local -name "*uka*" -type d -exec rm -rf {} + 2>/dev/null || true
find /data/local -name "*UKA*" -type d -exec rm -rf {} + 2>/dev/null || true

echo "✅ UKA_Pro Enhanced uninstallation completed!"
echo "ℹ️  System shortcuts (uka_main, uka, menu) will be removed on next reboot"
echo "ℹ️  Or manually remove the Magisk module to remove shortcuts immediately"

