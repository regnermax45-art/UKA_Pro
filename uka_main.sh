#!/system/bin/sh

# UKA_Pro Enhanced Main Script
# Unified Unpacker Kitchen for Android with UKA_lite integration
# Enhanced with Pixel 7 Pro GSI porting capabilities

# Environment setup - Fixed installation path
uka="/data/local/uka_pro"
bin="$uka/bin/arm"
bb="$bin/busybox"
tmp="$uka/tmp"
pybin="$uka/python"
editor="$uka/editor"
debloat="$uka/bin/debloat"
phh="$uka/bin/phh"
unpack="$uka/bin/unpack"

# Ensure we're in the correct directory
cd "$uka" || {
    echo "❌ Error: UKA_Pro installation not found at $uka"
    echo "Please reinstall the UKA_Pro Enhanced module"
    exit 1
}

# Verify installation
if [ ! -f "$uka/uka_main.sh" ]; then
    echo "❌ Error: UKA_Pro Enhanced not properly installed"
    echo "Expected location: $uka"
    echo "Please reinstall the module"
    exit 1
fi

chmod -R 755 "$uka"
rm -rf "$tmp"
rm -rf "$editor"
mkdir -p "$tmp"
mkdir -p $editor

clear
echo -en "\E[32;1m"
echo "      =================================="
echo "      UKA_Pro + UKA_lite Integration"
echo "      Universal Kitchen for Android"
echo "      Version: 2.0 Enhanced"
echo "      =================================="
echo -en "\E[37;1m"
echo " "
echo "🚀 Enhanced with Pixel 7 Pro GSI porting!"
echo "🔧 Supports Samsung, Motorola, Xiaomi, Google, Realme"
echo "📱 Special Pixel 7 Pro (cheetah) optimizations"
echo " "

# Show menu
show_menu() {
    echo -en "\E[36;1m"
    echo "Select operation:"
    echo "1) Samsung OneUI (super.img.lz4)"
    echo "2) Samsung OneUI EROFS (erofs.img.lz4)"
    echo "3) Motorola MotoUI Global (*.xml.zip)"
    echo "4) Motorola MotoUI CN (super.img_sparsechunk.*)"
    echo "5) Xiaomi MIUI (*.12.0.zip, *.13.0.zip)"
    echo "6) Realme RealmeUI (realme.bin)"
    echo "7) 🎯 Pixel 7 Pro GSI Porter (system.img/payload.bin)"
    echo "8) 🔧 Advanced GSI Tools"
    echo "9) Exit"
    echo -en "\E[37;1m"
    echo -n "Choice [1-9]: "
}

# Advanced GSI menu
show_gsi_menu() {
    echo -en "\E[35;1m"
    echo "Advanced GSI Tools:"
    echo "1) Extract payload.bin"
    echo "2) Repack system.img"
    echo "3) Apply PHH patches"
    echo "4) Debloat GSI"
    echo "5) Create flashable zip"
    echo "6) Back to main menu"
    echo -en "\E[37;1m"
    echo -n "Choice [1-6]: "
}

# Check for files and auto-detect
auto_detect() {
    echo "🔍 Auto-detecting files..."
    
    if [ -f "$uka/super.img.lz4" ]; then
        echo "📱 Samsung OneUI detected"
        return 1
    elif [ -f "$uka/erofs.img.lz4" ]; then
        echo "📱 Samsung OneUI EROFS detected"
        return 2
    elif ls "$uka"/*.xml.zip 1> /dev/null 2>&1; then
        echo "📱 Motorola MotoUI Global detected"
        return 3
    elif [ -f "$uka/super.img_sparsechunk.1" ]; then
        echo "📱 Motorola MotoUI CN detected"
        return 4
    elif ls "$uka"/*.0.zip 1> /dev/null 2>&1; then
        echo "📱 Xiaomi MIUI detected"
        return 5
    elif [ -f "$uka/realme.bin" ]; then
        echo "📱 Realme RealmeUI detected"
        return 6
    elif [ -f "$uka/system.img" ] || [ -f "$uka/payload.bin" ]; then
        echo "🎯 Pixel/GSI image detected"
        return 7
    else
        echo "❌ No supported files detected"
        echo "Please place supported files in: $uka"
        return 0
    fi
}

# Main execution
main() {
    # Try auto-detection first
    auto_detect
    AUTO_CHOICE=$?
    
    if [ $AUTO_CHOICE -ne 0 ]; then
        echo "Auto-detected option: $AUTO_CHOICE"
        echo -n "Use auto-detection? [Y/n]: "
        read AUTO_CONFIRM
        if [ "$AUTO_CONFIRM" != "n" ] && [ "$AUTO_CONFIRM" != "N" ]; then
            CHOICE=$AUTO_CHOICE
        else
            show_menu
            read CHOICE
        fi
    else
        show_menu
        read CHOICE
    fi
    
    case $CHOICE in
        1)
            echo "🔧 Processing Samsung OneUI..."
            sh $unpack/oneui.sh
            ;;
        2)
            echo "🔧 Processing Samsung OneUI EROFS..."
            sh $unpack/oneui_erofs.sh
            ;;
        3)
            echo "🔧 Processing Motorola MotoUI Global..."
            sh $unpack/motoui.sh
            ;;
        4)
            echo "🔧 Processing Motorola MotoUI CN..."
            sh $unpack/motoui.sh
            ;;
        5)
            echo "🔧 Processing Xiaomi MIUI..."
            sh $unpack/miui.sh
            ;;
        6)
            echo "🔧 Processing Realme RealmeUI..."
            sh $unpack/realmeui.sh
            ;;
        7)
            echo "🎯 Starting Pixel 7 Pro GSI Porter..."
            echo -n "Apply debloat? [y/N]: "
            read DEBLOAT_CHOICE
            if [ "$DEBLOAT_CHOICE" = "y" ] || [ "$DEBLOAT_CHOICE" = "Y" ]; then
                sh $unpack/pixel_gsi.sh debloat
            else
                sh $unpack/pixel_gsi.sh
            fi
            ;;
        8)
            while true; do
                show_gsi_menu
                read GSI_CHOICE
                case $GSI_CHOICE in
                    1)
                        echo "🔧 Extracting payload.bin..."
                        python3 $pybin/payload_dumper.py payload.bin
                        ;;
                    2)
                        echo "🔧 Repacking system.img..."
                        # Add repack logic here
                        ;;
                    3)
                        echo "🔧 Applying PHH patches..."
                        sh $phh/apply_patches.sh
                        ;;
                    4)
                        echo "🗑️ Starting debloat process..."
                        sh $debloat/pixel_debloat.sh
                        ;;
                    5)
                        echo "📦 Creating flashable zip..."
                        # Add flashable zip creation
                        ;;
                    6)
                        break
                        ;;
                    *)
                        echo "❌ Invalid choice"
                        ;;
                esac
                echo ""
                echo "Press Enter to continue..."
                read
            done
            ;;
        9)
            echo "👋 Goodbye!"
            exit 0
            ;;
        *)
            echo "❌ Invalid choice"
            main
            ;;
    esac
}

# Run main function
main

# Cleanup and finish
echo " "
echo "🧹 Cleaning up temporary files..."
echo "- Renaming files to original types..."
mv "$uka"/*.xml "$uka"/*.xml.zip 2>/dev/null
mv "$uka"/*.0 "$uka"/*.0.zip 2>/dev/null

echo -en "\E[32;1m"
echo "✅ UKA_Pro operation completed!"
echo -en "\E[37;1m"
echo " "
