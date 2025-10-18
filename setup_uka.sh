#!/system/bin/sh

##########################################################################################
# UKA_Pro Enhanced Setup Helper
# Quick setup script for manual installation
##########################################################################################

echo "🚀 UKA_Pro Enhanced Setup Helper"
echo "=================================="

# Check if running as root
if [ "$(id -u)" != "0" ]; then
    echo "❌ Error: This script must be run as root"
    echo "Please run: su -c './setup_uka.sh'"
    exit 1
fi

# Installation directory
UKA_DIR="/data/local/uka_pro"
CURRENT_DIR=$(pwd)

echo "📁 Current directory: $CURRENT_DIR"
echo "📁 Target directory: $UKA_DIR"

# Check if we're in the right place
if [ ! -f "$CURRENT_DIR/uka_main.sh" ]; then
    echo "❌ Error: uka_main.sh not found in current directory"
    echo "Please run this script from the UKA_Pro directory"
    exit 1
fi

# Create installation directory
echo "📦 Creating installation directory..."
rm -rf "$UKA_DIR"
mkdir -p "$UKA_DIR"

if [ ! -d "$UKA_DIR" ]; then
    echo "❌ Error: Failed to create $UKA_DIR"
    exit 1
fi

# Copy files
echo "📋 Copying files..."
cp -rf "$CURRENT_DIR"/* "$UKA_DIR/"

# Set permissions
echo "🔐 Setting permissions..."
chmod -R 755 "$UKA_DIR"
find "$UKA_DIR" -name "*.sh" -exec chmod +x {} \;
find "$UKA_DIR/bin" -type f -exec chmod +x {} \; 2>/dev/null || true

# Create system shortcuts
echo "🔗 Creating system shortcuts..."

# Create uka_main command
cat > /system/bin/uka_main << 'EOF'
#!/system/bin/sh
cd /data/local/uka_pro
exec ./uka_main.sh "$@"
EOF

# Create uka command (shorter alias)
cat > /system/bin/uka << 'EOF'
#!/system/bin/sh
cd /data/local/uka_pro
exec ./uka_main.sh "$@"
EOF

# Create menu command (legacy compatibility)
cat > /system/bin/menu << 'EOF'
#!/system/bin/sh
cd /data/local/uka_pro
exec ./uka_main.sh "$@"
EOF

# Make shortcuts executable
chmod +x /system/bin/uka_main 2>/dev/null || true
chmod +x /system/bin/uka 2>/dev/null || true
chmod +x /system/bin/menu 2>/dev/null || true

# Create working directories
mkdir -p "$UKA_DIR/tmp"
mkdir -p "$UKA_DIR/editor"

# Verify installation
echo "✅ Verifying installation..."
if [ -f "$UKA_DIR/uka_main.sh" ]; then
    echo "  ✅ Main script installed"
else
    echo "  ❌ Main script missing"
fi

if [ -f "$UKA_DIR/bin/unpack/pixel_gsi.sh" ]; then
    echo "  ✅ Pixel GSI script installed"
else
    echo "  ❌ Pixel GSI script missing"
fi

if [ -f "$UKA_DIR/python/payload_dumper.py" ]; then
    echo "  ✅ Python scripts installed"
else
    echo "  ❌ Python scripts missing"
fi

echo ""
echo "🎉 Setup completed successfully!"
echo ""
echo "📋 Usage Instructions:"
echo "  • From anywhere: uka_main (or uka, or menu)"
echo "  • Direct: cd /data/local/uka_pro && ./uka_main.sh"
echo ""
echo "🎯 Pixel 7 Pro GSI Porting:"
echo "  1. Place system.img or payload.bin in /data/local/uka_pro"
echo "  2. Run: uka_main"
echo "  3. Select option 7: Pixel 7 Pro GSI Porter"
echo ""
echo "📱 Supported file formats:"
echo "  • Samsung: super.img.lz4, erofs.img.lz4"
echo "  • Motorola: *.xml.zip, sparsechunk files"
echo "  • Xiaomi: *.12.0.zip, *.13.0.zip"
echo "  • Realme: realme.bin (renamed payload.bin)"
echo "  • Google: payload.bin, system.img"
echo ""
echo "🔧 Test installation:"
echo "  uka_main"
echo ""

