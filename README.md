# UKA_Pro Enhanced 🚀

**Enhanced Unpacker Kitchen for Android with UKA_lite Integration + Pixel 7 Pro GSI Porting**

A powerful, unified Android firmware unpacking and GSI porting solution that combines the best of UKA_Pro and UKA_lite with specialized Pixel 7 Pro support.

## ✨ Features

### 🔧 Multi-OEM Support
- **Samsung OneUI**: super.img.lz4, erofs.img.lz4
- **Motorola MotoUI**: *.xml.zip, sparsechunk files  
- **Xiaomi MIUI**: *.12.0.zip, *.13.0.zip
- **Realme RealmeUI**: payload.bin → realme.bin
- **Google Pixel**: payload.bin, system.img

### 🎯 Pixel 7 Pro GSI Porting
- **Device-Specific Optimizations**: Tensor G2 chipset support
- **GSI Modification**: Repack and optimize existing GSIs
- **Advanced Debloating**: Remove unnecessary apps for better performance
- **PHH Treble Integration**: Enhanced compatibility patches
- **Auto-Detection**: Intelligent file format recognition

### 🤖 Automated CI/CD
- **GitHub Actions**: Automated module building
- **Multi-Format Testing**: Validate all supported formats
- **Security Scanning**: Built-in safety checks
- **Release Automation**: Automatic versioning and releases

## 📱 Supported Devices

### Primary Target
- **Google Pixel 7 Pro** (cheetah) - Full GSI porting support
- **Tensor G2 chipset** optimizations

### Secondary Support
- All Project Treble compatible devices
- 64-bit ARM devices (ARMv8-A)

## 🚀 Installation

### Method 1: Magisk Module (Recommended)
1. Download the latest release from [Releases](../../releases)
2. Install via Magisk Manager
3. Reboot your device
4. Access via terminal: `uka_main.sh`

### Method 2: Manual Installation
```bash
# Download and extract
wget https://github.com/regnermax45-art/UKA_Pro/releases/latest/download/UKA_Pro_Enhanced_*.zip
unzip UKA_Pro_Enhanced_*.zip -d /data/local/tmp/uka_pro/

# Set permissions
chmod -R 755 /data/local/tmp/uka_pro/
```

## 🔧 Usage

### Quick Start
```bash
# Access the main menu
su
uka_main.sh
```

### Pixel 7 Pro GSI Porting
```bash
# Place your GSI files in the UKA directory
# Supported formats: system.img, payload.bin

# Run the Pixel GSI porter
uka_main.sh
# Select option 7: "Pixel 7 Pro GSI Porter"

# Optional: Apply debloating
# Choose 'y' when prompted for debloat
```

### Supported File Formats

| OEM | Format | Files Required |
|-----|--------|----------------|
| Samsung | OneUI | `super.img.lz4`, `prism.img.lz4`, `optics.img.lz4` |
| Samsung | OneUI EROFS | `erofs.img.lz4`, `prism.img.lz4`, `optics.img.lz4` |
| Motorola | MotoUI Global | `*.xml.zip` |
| Motorola | MotoUI CN | `super.img_sparsechunk.*` |
| Xiaomi | MIUI | `*.12.0.zip`, `*.13.0.zip` |
| Realme | RealmeUI | `realme.bin` (renamed from payload.bin) |
| Google | Pixel | `payload.bin`, `system.img` |

## 🎯 Pixel 7 Pro Specific Features

### GSI Optimizations
- **Tensor G2 Support**: Hardware-specific optimizations
- **Display Configuration**: 512 DPI, proper resolution settings
- **Camera Integration**: Google Camera services compatibility
- **Bootloader Support**: Verified boot and security features
- **Performance Tuning**: Pixel-specific power management

### Debloating Options
- Remove unnecessary Google apps
- Clean up system overlays
- Optimize for GSI compatibility
- Preserve essential Pixel features

### Build Properties
```properties
ro.product.device=cheetah
ro.product.model=Pixel 7 Pro
ro.soc.model=Tensor G2
ro.sf.lcd_density=512
ro.hardware=cheetah
```

## 🛠️ Development

### Building from Source
```bash
# Clone the repository
git clone https://github.com/regnermax45-art/UKA_Pro.git
cd UKA_Pro

# Build using GitHub Actions locally
act -j build
```

### Contributing
1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

### Testing
```bash
# Run tests
.github/workflows/test-pixel-gsi.yml

# Lint shell scripts
shellcheck bin/**/*.sh
```

## 📋 Requirements

### System Requirements
- **Android**: 8.0+ (API 26+)
- **Architecture**: ARM64 (ARMv8-A)
- **Root**: Required (Magisk recommended)
- **Storage**: 2GB+ free space
- **RAM**: 4GB+ recommended

### Dependencies
- **Magisk**: v20.0+ (for module installation)
- **BusyBox**: Included in module
- **Python**: 3.6+ (for payload extraction)

## 🔒 Security

### Safety Features
- **TruffleHog Integration**: Secret scanning
- **Input Validation**: Prevent malicious files
- **Sandboxed Execution**: Isolated processing
- **Checksum Verification**: File integrity checks

### Permissions
- **Root Access**: Required for system modifications
- **Storage Access**: Read/write firmware files
- **Network Access**: Download updates (optional)

## 📚 Documentation

### Command Reference
- `uka_main.sh` - Main interface
- `bin/unpack/pixel_gsi.sh` - Pixel GSI porter
- `bin/debloat/pixel_debloat.sh` - Debloating tool

### File Structure
```
UKA_Pro/
├── META-INF/           # Magisk module metadata
├── bin/                # Binary tools and scripts
│   ├── arm/           # ARM64 binaries
│   ├── unpack/        # Unpacking scripts
│   ├── debloat/       # Debloating tools
│   └── phh/           # PHH Treble patches
├── python/            # Python scripts
├── local/             # Local configurations
├── module.prop        # Module properties
├── install.sh         # Installation script
├── uninstall.sh       # Uninstallation script
└── uka_main.sh        # Main entry point
```

## 🤝 Credits

### Original Projects
- **UKA_Pro**: ColdWindScholar - Base unpacking framework
- **UKA_lite**: cryzuezin - Lightweight unpacking scripts
- **PHH GSI**: phhusson - Treble GSI patches

### Contributors
- **regnermax45-art**: Integration and Pixel 7 Pro support
- **cryzuezin**: UKA_lite functionality
- **ColdWindScholar**: Original UKA framework

### Third-Party Tools
- **Android Image Kitchen**: Boot image tools
- **payload_dumper**: Payload extraction
- **make_ext4fs**: Filesystem creation

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🐛 Issues & Support

### Reporting Issues
- Use the [GitHub Issues](../../issues) page
- Provide device information and logs
- Include steps to reproduce

### Support Channels
- **GitHub Discussions**: General questions
- **Issues**: Bug reports and feature requests
- **Wiki**: Detailed documentation

## 🔄 Changelog

### v2.0 (Latest)
- ✅ Merged UKA_Pro and UKA_lite
- ✅ Added Pixel 7 Pro GSI support
- ✅ Implemented GitHub Actions CI/CD
- ✅ Enhanced debloating system
- ✅ Added auto-detection features

### v1.0 (Legacy)
- Basic UKA_Pro functionality
- Multi-OEM support
- Magisk module format

---

> [!NOTICE]
> **Device Compatibility**: This tool is optimized for 64-bit ARM devices. Pixel 7 Pro support requires Android 13+ and unlocked bootloader.

> [!WARNING]
> **Root Required**: This tool requires root access and can modify system partitions. Use at your own risk and ensure you have proper backups.

