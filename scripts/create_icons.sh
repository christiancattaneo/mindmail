#!/bin/bash
# Icon Generator Script for MindMail
# Creates all required App Store icon sizes from a master 1024x1024 image

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
ASSETS_DIR="$PROJECT_DIR/mindmail/Assets.xcassets/AppIcon.appiconset"
MASTER_ICON="$1"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "🎨 MindMail Icon Generator"
echo "=========================="

# Check if master icon provided
if [ -z "$MASTER_ICON" ]; then
    echo -e "${RED}Error: No master icon provided${NC}"
    echo ""
    echo "Usage: $0 <path-to-1024x1024-icon.png>"
    echo ""
    echo "Example:"
    echo "  $0 ~/Desktop/mindmail-icon-1024.png"
    echo ""
    echo "To create a master icon:"
    echo "  1. Design a 1024x1024 PNG with:"
    echo "     - Lavender gradient background (#f0e6ff to #d0b8ff)"
    echo "     - White envelope emoji 💌 or letter icon"
    echo "     - No transparency (solid background)"
    echo "  2. Use Figma, Sketch, or online tools"
    echo "  3. Export as PNG"
    exit 1
fi

# Check if master icon exists
if [ ! -f "$MASTER_ICON" ]; then
    echo -e "${RED}Error: Master icon not found: $MASTER_ICON${NC}"
    exit 1
fi

# Check if ImageMagick or sips is available
if command -v sips &> /dev/null; then
    CONVERTER="sips"
    echo -e "${GREEN}✓ Using sips (macOS native)${NC}"
elif command -v magick &> /dev/null; then
    CONVERTER="imagemagick"
    echo -e "${GREEN}✓ Using ImageMagick${NC}"
else
    echo -e "${RED}Error: No image converter found${NC}"
    echo ""
    echo "Install ImageMagick:"
    echo "  brew install imagemagick"
    echo ""
    echo "Or use online tool:"
    echo "  https://www.appicon.co/"
    exit 1
fi

# Function to resize image
resize_icon() {
    local size=$1
    local output=$2
    
    if [ "$CONVERTER" = "sips" ]; then
        sips -z $size $size "$MASTER_ICON" --out "$output" > /dev/null 2>&1
    else
        magick "$MASTER_ICON" -resize ${size}x${size} "$output"
    fi
    
    echo -e "${GREEN}✓${NC} Created: $(basename "$output") (${size}x${size})"
}

echo ""
echo "Generating icons from: $(basename "$MASTER_ICON")"
echo "Output directory: $ASSETS_DIR"
echo ""

# Create all required sizes
resize_icon 1024 "$ASSETS_DIR/icon-1024.png"
resize_icon 180 "$ASSETS_DIR/icon-180.png"
resize_icon 120 "$ASSETS_DIR/icon-120.png"
resize_icon 167 "$ASSETS_DIR/icon-167.png"
resize_icon 152 "$ASSETS_DIR/icon-152.png"
resize_icon 76 "$ASSETS_DIR/icon-76.png"

echo ""
echo -e "${GREEN}✅ All icons generated successfully!${NC}"
echo ""
echo "Next steps:"
echo "  1. Open Xcode"
echo "  2. Clean build folder (Cmd+Shift+K)"
echo "  3. Build and run (Cmd+R)"
echo "  4. Check icon appears correctly"
echo ""

