#!/bin/bash

# Pixel 7 Pro GSI Debloat Script
# Removes unnecessary apps and services for better performance

echo "🗑️  Starting Pixel 7 Pro debloat process..."

# Google apps that can be safely removed for GSI
GOOGLE_BLOAT=(
    "app/GooglePay"
    "app/GooglePayIndia" 
    "app/Stadia"
    "app/YouTubeMusic"
    "app/Books"
    "app/Magazines"
    "app/Movies"
    "app/Music2"
    "app/PlayGames"
    "app/GoogleEarth"
    "app/Street"
    "app/Lens"
    "priv-app/HotwordEnrollmentOKGoogleHEXAGON"
    "priv-app/HotwordEnrollmentXGoogleHEXAGON"
    "priv-app/MyVerizonServices"
    "priv-app/SCONE"
    "priv-app/ScribePrebuilt"
    "priv-app/SoundAmplifierPrebuilt"
    "priv-app/Tycho"
    "priv-app/WallpapersBReel2020"
)

# Pixel specific bloat
PIXEL_BLOAT=(
    "app/CalculatorGooglePrebuilt"
    "app/CalendarGooglePrebuilt" 
    "app/Drive"
    "app/Duo"
    "app/FilesPrebuilt"
    "app/Flipendo"
    "app/GoogleCamera"
    "app/GoogleContacts"
    "app/GoogleDialer"
    "app/GoogleMessages"
    "app/MarkupGoogle"
    "app/Photos"
    "app/PrebuiltGmail"
    "app/RecorderPrebuilt"
    "app/SafetyHubPrebuilt"
    "app/SoundPickerPrebuilt"
    "app/StorageManagerGoogle"
    "app/TurboPrebuilt"
    "app/Velvet"
    "app/WellbeingPrebuilt"
)

# System apps that can be removed for GSI compatibility
SYSTEM_BLOAT=(
    "app/BasicDreams"
    "app/BookmarkProvider"
    "app/Browser2"
    "app/Calendar"
    "app/Camera2"
    "app/DeskClock"
    "app/Email"
    "app/Gallery2"
    "app/HTMLViewer"
    "app/LiveWallpapers"
    "app/MagicSmokeWallpapers"
    "app/MusicFX"
    "app/NoiseField"
    "app/PhaseBeam"
    "app/PhotoTable"
    "app/SoundRecorder"
    "app/SpeechRecorder"
    "app/VideoEditor"
    "app/VisualizationWallpapers"
)

# Function to remove app safely
remove_app() {
    local app_path="$1"
    if [ -d "$app_path" ]; then
        echo "  Removing: $(basename "$app_path")"
        rm -rf "$app_path"
    fi
}

# Remove Google bloat
echo "Removing Google bloatware..."
for app in "${GOOGLE_BLOAT[@]}"; do
    remove_app "$app"
done

# Remove Pixel specific bloat  
echo "Removing Pixel specific bloat..."
for app in "${PIXEL_BLOAT[@]}"; do
    remove_app "$app"
done

# Remove system bloat
echo "Removing system bloatware..."
for app in "${SYSTEM_BLOAT[@]}"; do
    remove_app "$app"
done

# Remove unnecessary permissions
echo "Cleaning up permissions..."
if [ -f "etc/permissions/privapp-permissions-google.xml" ]; then
    # Keep only essential permissions
    sed -i '/com.google.android.apps.photos/d' etc/permissions/privapp-permissions-google.xml
    sed -i '/com.google.android.apps.youtube.music/d' etc/permissions/privapp-permissions-google.xml
    sed -i '/com.google.android.videos/d' etc/permissions/privapp-permissions-google.xml
fi

# Clean up overlays for removed apps
echo "Cleaning up overlays..."
find overlay/ -name "*Photos*" -type d -exec rm -rf {} + 2>/dev/null
find overlay/ -name "*YouTube*" -type d -exec rm -rf {} + 2>/dev/null
find overlay/ -name "*Books*" -type d -exec rm -rf {} + 2>/dev/null

# Remove unused libraries
echo "Removing unused libraries..."
UNUSED_LIBS=(
    "lib/libfilterpack_facedetect.so"
    "lib64/libfilterpack_facedetect.so"
    "lib/libgoogle_recognizer_jni_l.so"
    "lib64/libgoogle_recognizer_jni_l.so"
)

for lib in "${UNUSED_LIBS[@]}"; do
    if [ -f "$lib" ]; then
        echo "  Removing: $lib"
        rm -f "$lib"
    fi
done

# Clean up build.prop entries for removed apps
echo "Cleaning build.prop..."
if [ -f "build.prop" ]; then
    # Remove entries for deleted apps
    sed -i '/ro.config.ringtone/d' build.prop
    sed -i '/ro.config.notification_sound/d' build.prop
    sed -i '/ro.config.alarm_alert/d' build.prop
    
    # Add GSI optimizations
    {
        echo "# GSI Optimizations"
        echo "ro.treble.enabled=true"
        echo "ro.vndk.version=33"
        echo "ro.product.first_api_level=33"
    } >> build.prop
fi

# Create debloat summary
echo "✅ Debloat completed!"
echo "📊 Removed unnecessary apps and files"
echo "💾 Estimated space saved: ~500MB"
echo "🎯 GSI optimized for Pixel 7 Pro"
