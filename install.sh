#!/system/bin/sh

##########################################################################################
# UKA_Pro Enhanced Installation Script
# Enhanced Unpacker Kitchen for Android with UKA_lite Integration + Pixel 7 Pro GSI
##########################################################################################

SKIPMOUNT=false
PROPFILE=false
POSTFSDATA=false
LATESTARTSERVICE=false
REPLACE=""

# Installation paths
UKA_DIR="/data/local/uka_pro"
BIN_DIR="$UKA_DIR/bin"
PYTHON_DIR="$UKA_DIR/python"

##########################################################################################
# Print module name
##########################################################################################
print_modname() {
  ui_print " "
  ui_print "***********************************"
  ui_print "  UKA_Pro Enhanced Installation"
  ui_print "***********************************"
  ui_print "- UKA_Pro + UKA_lite Integration"
  ui_print "- Pixel 7 Pro GSI Support"
  ui_print "- Multi-OEM Compatibility"
  ui_print "- GitHub Actions CI/CD"
  ui_print "***********************************"
  ui_print " "
}

##########################################################################################
# Installation function
##########################################################################################
on_install() {
  ui_print "🔧 Starting UKA_Pro Enhanced installation..."
  
  # Check architecture
  ui_print "📱 Checking device architecture..."
  ABI=$(getprop ro.product.cpu.abi)
  case $ABI in
    arm64-v8a|arm64) 
      ui_print "✅ ARM64 architecture detected: $ABI"
      ARCH="arm64"
      ;;
    armeabi-v7a|armeabi) 
      ui_print "⚠️  ARM32 architecture detected: $ABI"
      ui_print "⚠️  Some features may be limited on 32-bit devices"
      ARCH="arm"
      ;;
    x86_64|x86) 
      ui_print "❌ x86 architecture not supported: $ABI"
      abort "❌ This module requires ARM architecture"
      ;;
    *) 
      ui_print "❌ Unknown architecture: $ABI"
      abort "❌ Unsupported device architecture"
      ;;
  esac
  
  # Check Android version
  SDK=$(getprop ro.build.version.sdk)
  if [ "$SDK" -lt 26 ]; then
    ui_print "❌ Android version too old (API $SDK)"
    abort "❌ Requires Android 8.0+ (API 26+)"
  else
    ui_print "✅ Android API level: $SDK"
  fi
  
  # Create installation directory
  ui_print "📁 Creating installation directories..."
  rm -rf "$UKA_DIR"
  mkdir -p "$UKA_DIR"
  mkdir -p "$BIN_DIR"
  mkdir -p "$PYTHON_DIR"
  mkdir -p "$UKA_DIR/local"
  
  if [ ! -d "$UKA_DIR" ]; then
    abort "❌ Failed to create installation directory: $UKA_DIR"
  fi
  
  # Copy module files to installation directory
  ui_print "📦 Installing UKA_Pro Enhanced files..."
  
  # Copy main scripts
  cp -f "$MODPATH/uka_main.sh" "$UKA_DIR/"
  cp -f "$MODPATH/install.sh" "$UKA_DIR/"
  cp -f "$MODPATH/uninstall.sh" "$UKA_DIR/"
  cp -f "$MODPATH/module.prop" "$UKA_DIR/"
  
  # Copy binary tools
  if [ -d "$MODPATH/bin" ]; then
    cp -rf "$MODPATH/bin"/* "$BIN_DIR/"
  fi
  
  # Copy Python scripts
  if [ -d "$MODPATH/python" ]; then
    cp -rf "$MODPATH/python"/* "$PYTHON_DIR/"
  fi
  
  # Copy local files
  if [ -d "$MODPATH/local" ]; then
    cp -rf "$MODPATH/local"/* "$UKA_DIR/local/"
  fi
  
  # Extract AIK if present
  if [ -f "$MODPATH/aik.tar.xz" ]; then
    ui_print "📦 Extracting Android Image Kitchen..."
    cd "$UKA_DIR"
    tar -xf "$MODPATH/aik.tar.xz"
  fi
  
  # Set proper permissions
  ui_print "🔐 Setting permissions..."
  chmod -R 755 "$UKA_DIR"
  chmod +x "$UKA_DIR/uka_main.sh"
  chmod +x "$UKA_DIR/install.sh"
  chmod +x "$UKA_DIR/uninstall.sh"
  
  # Make all shell scripts executable
  find "$UKA_DIR" -name "*.sh" -exec chmod +x {} \;
  
  # Make binary tools executable
  if [ -d "$BIN_DIR" ]; then
    find "$BIN_DIR" -type f -exec chmod +x {} \;
  fi
  
  # Create system bin symlinks for easy access
  ui_print "🔗 Creating system shortcuts..."
  mkdir -p "$MODPATH/system/bin"
  
  # Create uka_main symlink
  cat > "$MODPATH/system/bin/uka_main" << 'EOF'
#!/system/bin/sh
cd /data/local/uka_pro
exec ./uka_main.sh "$@"
EOF
  
  # Create uka symlink (shorter alias)
  cat > "$MODPATH/system/bin/uka" << 'EOF'
#!/system/bin/sh
cd /data/local/uka_pro
exec ./uka_main.sh "$@"
EOF
  
  # Create menu symlink (legacy compatibility)
  cat > "$MODPATH/system/bin/menu" << 'EOF'
#!/system/bin/sh
cd /data/local/uka_pro
exec ./uka_main.sh "$@"
EOF
  
  chmod +x "$MODPATH/system/bin/uka_main"
  chmod +x "$MODPATH/system/bin/uka"
  chmod +x "$MODPATH/system/bin/menu"
  
  # Verify installation
  ui_print "✅ Verifying installation..."
  
  required_files=(
    "$UKA_DIR/uka_main.sh"
    "$BIN_DIR/unpack/pixel_gsi.sh"
    "$BIN_DIR/debloat/pixel_debloat.sh"
    "$PYTHON_DIR/payload_dumper.py"
  )
  
  for file in "${required_files[@]}"; do
    if [ -f "$file" ]; then
      ui_print "  ✅ $(basename $file)"
    else
      ui_print "  ❌ Missing: $(basename $file)"
    fi
  done
  
  # Create working directories
  mkdir -p "$UKA_DIR/tmp"
  mkdir -p "$UKA_DIR/editor"
  
  ui_print " "
  ui_print "🎉 Installation completed successfully!"
  ui_print " "
  ui_print "📋 Usage Instructions:"
  ui_print "  • Terminal: uka_main (or uka, or menu)"
  ui_print "  • Direct: cd /data/local/uka_pro && ./uka_main.sh"
  ui_print " "
  ui_print "🎯 Pixel 7 Pro GSI Support:"
  ui_print "  • Place system.img or payload.bin in /data/local/uka_pro"
  ui_print "  • Run uka_main and select option 7"
  ui_print " "
  ui_print "📱 Supported Formats:"
  ui_print "  • Samsung OneUI (super.img.lz4)"
  ui_print "  • Motorola MotoUI (*.xml.zip)"
  ui_print "  • Xiaomi MIUI (*.12.0.zip)"
  ui_print "  • Realme RealmeUI (realme.bin)"
  ui_print "  • Google Pixel (payload.bin)"
  ui_print " "
}

##########################################################################################
# Set permissions
##########################################################################################
set_permissions() {
  # Module permissions
  set_perm_recursive "$MODPATH" 0 0 0755 0644
  set_perm_recursive "$MODPATH/system/bin" 0 0 0755 0755
  
  # Installation directory permissions
  if [ -d "$UKA_DIR" ]; then
    chown -R 0:0 "$UKA_DIR"
    chmod -R 755 "$UKA_DIR"
    find "$UKA_DIR" -name "*.sh" -exec chmod 755 {} \;
    find "$BIN_DIR" -type f -exec chmod 755 {} \; 2>/dev/null || true
  fi
}

