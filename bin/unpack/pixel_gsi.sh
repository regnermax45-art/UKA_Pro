#!/bin/bash

# Pixel 7 Pro GSI Porting Script
# Supports modifying and repacking GSIs for Pixel 7 Pro (cheetah)
# Part of UKA_Pro with UKA_lite integration

# Environment setup
uka=$(pwd)
bin="$uka"/bin/arm
tmp="$uka"/bin/tmp
pybin="$uka"/bin/python
editor="$uka"/editor
debloat="$uka"/bin/debloat
phh="$uka"/bin/phh

# Pixel 7 Pro specific variables
DEVICE_CODENAME="cheetah"
DEVICE_NAME="Pixel 7 Pro"
CHIPSET="tensor_gs201"
ANDROID_VERSION="13"

echo -en "\E[32;1m"
echo "      -------------------------"
echo "      Pixel 7 Pro GSI Porter"
echo "      UKA_Pro + UKA_lite"
echo "      Device: $DEVICE_NAME ($DEVICE_CODENAME)"
echo "      Chipset: Tensor G2 (GS201)"
echo "      -------------------------"
echo -en "\E[37;1m"
echo " "

# Check for GSI image
if [ ! -f ""$uka"/system.img" ] && [ ! -f ""$uka"/system.img.raw" ] && [ ! -f ""$uka"/payload.bin" ]; then
    echo "❌ No GSI image found!"
    echo "Please place one of the following in $uka:"
    echo "  - system.img (GSI system image)"
    echo "  - system.img.raw (raw GSI image)"
    echo "  - payload.bin (from Pixel factory image)"
    exit 1
fi

# Create working directories
mkdir -p "$tmp"/pixel_gsi
mkdir -p $editor/pixel_modifications
mkdir -p "$tmp"/pixel_gsi/system
mkdir -p "$tmp"/pixel_gsi/vendor
mkdir -p "$tmp"/pixel_gsi/product

echo "🔧 Setting up Pixel 7 Pro GSI environment..."

# Extract payload.bin if present
if [ -f ""$uka"/payload.bin" ]; then
    echo "📦 Extracting payload.bin..."
    cd "$tmp"/pixel_gsi
    python3 $pybin/payload_dumper.py "$uka"/payload.bin
    
    # Move extracted images
    [ -f system.img ] && mv system.img "$tmp"/pixel_gsi/
    [ -f vendor.img ] && mv vendor.img "$tmp"/pixel_gsi/
    [ -f product.img ] && mv product.img "$tmp"/pixel_gsi/
    [ -f boot.img ] && mv boot.img "$tmp"/pixel_gsi/
    cd $uka
fi

# Mount system image
if [ -f ""$uka"/system.img" ] || [ -f ""$tmp"/pixel_gsi/system.img" ]; then
    SYSTEM_IMG=""$uka"/system.img"
    [ -f ""$tmp"/pixel_gsi/system.img" ] && SYSTEM_IMG=""$tmp"/pixel_gsi/system.img"
    
    echo "🗂️  Mounting system image..."
    
    # Check if it's sparse
    if "$bin"/file $SYSTEM_IMG | grep -q "sparse"; then
        echo "Converting sparse image..."
        "$bin"/simg2img $SYSTEM_IMG "$tmp"/pixel_gsi/system_raw.img
        SYSTEM_IMG=""$tmp"/pixel_gsi/system_raw.img"
    fi
    
    # Mount the image
    mkdir -p "$tmp"/pixel_gsi/system_mount
    sudo mount -o loop,ro $SYSTEM_IMG "$tmp"/pixel_gsi/system_mount 2>/dev/null || {
        echo "Trying alternative mount method..."
        "$bin"/mount.erofs $SYSTEM_IMG "$tmp"/pixel_gsi/system_mount 2>/dev/null || {
            echo "Using 7z extraction..."
            cd "$tmp"/pixel_gsi
            "$bin"/7z x $SYSTEM_IMG -osystem_extracted/
            ln -sf system_extracted system_mount
            cd $uka
        }
    }
fi

echo "🎯 Applying Pixel 7 Pro specific modifications..."

# Create Pixel 7 Pro specific overlay
cat > $editor/pixel_modifications/pixel7pro_overlay.sh << 'EOF'
#!/system/bin/sh

# Pixel 7 Pro GSI Modifications
echo "Applying Pixel 7 Pro optimizations..."

# Device properties
echo "ro.product.device=cheetah" >> system/build.prop
echo "ro.product.model=Pixel 7 Pro" >> system/build.prop
echo "ro.product.name=cheetah" >> system/build.prop
echo "ro.product.brand=google" >> system/build.prop
echo "ro.product.manufacturer=Google" >> system/build.prop

# Tensor G2 specific optimizations
echo "ro.soc.manufacturer=Google" >> system/build.prop
echo "ro.soc.model=Tensor G2" >> system/build.prop
echo "ro.hardware=cheetah" >> system/build.prop

# Display properties for Pixel 7 Pro
echo "ro.sf.lcd_density=512" >> system/build.prop
echo "vendor.display.primary_red=0.6980,0.3020" >> system/build.prop
echo "vendor.display.primary_green=0.2627,0.6902" >> system/build.prop
echo "vendor.display.primary_blue=0.1491,0.0431" >> system/build.prop

# Camera and sensors
echo "ro.camera.notify_nfc=1" >> system/build.prop
echo "ro.vendor.camera.extensions.package=com.google.android.apps.camera.services" >> system/build.prop

# Pixel specific features
echo "ro.config.pixel_2016_preopt=true" >> system/build.prop
echo "ro.com.google.gmsversion=13_202210" >> system/build.prop

# Bootloader and security
echo "ro.boot.flash.locked=1" >> system/build.prop
echo "ro.boot.verifiedbootstate=green" >> system/build.prop
echo "ro.boot.veritymode=enforcing" >> system/build.prop

# Performance optimizations for Tensor G2
echo "ro.vendor.perf.scroll_opt=true" >> system/build.prop
echo "vendor.powerhal.init=1" >> system/build.prop

echo "✅ Pixel 7 Pro modifications applied!"
EOF

chmod +x $editor/pixel_modifications/pixel7pro_overlay.sh

# Apply PHH GSI patches for Pixel compatibility
echo "🔧 Applying PHH GSI patches..."
if [ -d ""$tmp"/pixel_gsi/system_mount" ]; then
    # Copy system to writable location
    echo "Creating writable system copy..."
    cp -r "$tmp"/pixel_gsi/system_mount/* "$tmp"/pixel_gsi/system/ 2>/dev/null || {
        rsync -av "$tmp"/pixel_gsi/system_mount/ "$tmp"/pixel_gsi/system/
    }
    
    # Apply PHH patches
    cd "$tmp"/pixel_gsi/system
    
    # Run pixel overlay
    sh $editor/pixel_modifications/pixel7pro_overlay.sh
    
    # Apply debloat if requested
    if [ "$1" = "debloat" ]; then
        echo "🗑️  Applying debloat for Pixel 7 Pro..."
        sh $debloat/pixel_debloat.sh
    fi
    
    # Apply PHH treble patches
    if [ -f "$phh/apply_patches.sh" ]; then
        echo "🔧 Applying PHH Treble patches..."
        sh $phh/apply_patches.sh cheetah
    fi
    
    cd $uka
fi

# Repack system image
echo "📦 Repacking system image for Pixel 7 Pro..."
cd "$tmp"/pixel_gsi

# Calculate new image size
SYSTEM_SIZE=$(du -sb system | cut -f1)
IMAGE_SIZE=$((SYSTEM_SIZE + 104857600)) # Add 100MB padding

# Create new system image
echo "Creating new system.img (${IMAGE_SIZE} bytes)..."
"$bin"/make_ext4fs -L system -l ${IMAGE_SIZE} -a system system_new.img system/

# Copy to output
cp system_new.img "$uka"/system_pixel7pro_gsi.img

cd $uka

# Cleanup
echo "🧹 Cleaning up..."
sudo umount "$tmp"/pixel_gsi/system_mount 2>/dev/null
rm -rf "$tmp"/pixel_gsi

echo -en "\E[32;1m"
echo "✅ Pixel 7 Pro GSI created successfully!"
echo "📁 Output: system_pixel7pro_gsi.img"
echo "🎯 Ready for flashing on Pixel 7 Pro (cheetah)"
echo -en "\E[37;1m"
echo " "
echo "Flash instructions:"
echo "1. Boot into fastboot mode"
echo "2. fastboot flash system system_pixel7pro_gsi.img"
echo "3. fastboot -w (factory reset)"
echo "4. fastboot reboot"
echo " "

