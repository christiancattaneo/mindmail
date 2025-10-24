# Xcode Setup Instructions

## 1. Add Notification Permission Description

### Steps:
1. Open `mindmail.xcodeproj` in Xcode
2. Select **mindmail** target (blue icon)
3. Go to **Info** tab
4. Click **+** button under "Custom iOS Target Properties"
5. Add this entry:

```
Key: Privacy - User Notifications Usage Description
Type: String
Value: MindMail sends you notifications when your letters from past self arrive, helping you stay connected with your emotional journey.
```

### Or use this exact key in Info.plist:
```xml
<key>NSUserNotificationsUsageDescription</key>
<string>MindMail sends you notifications when your letters from past self arrive, helping you stay connected with your emotional journey.</string>
```

---

## 2. Add App Icons

### Option A: Use the Icon Generator Script (Easiest)

1. **Create your master icon (1024x1024 PNG):**
   - Lavender gradient background: `#f0e6ff` to `#d0b8ff`
   - White envelope emoji 💌 or letter icon
   - Centered, with padding
   - Solid background (no transparency)

2. **Use online tool to design:**
   - [Figma](https://www.figma.com) - Free, professional
   - [Canva](https://www.canva.com) - Easy, templates
   - [App Icon Generator](https://www.appicon.co/) - Quick

3. **Run the generator script:**
   ```bash
   cd /Users/christiancattaneo/Projects/mindmail
   ./scripts/create_icons.sh ~/Desktop/mindmail-icon-1024.png
   ```

4. **The script will create:**
   - `icon-1024.png` (1024×1024) - App Store
   - `icon-180.png` (180×180) - iPhone @3x
   - `icon-120.png` (120×120) - iPhone @2x
   - `icon-167.png` (167×167) - iPad Pro
   - `icon-152.png` (152×152) - iPad @2x
   - `icon-76.png` (76×76) - iPad

### Option B: Use Online Icon Generator

1. Go to [https://www.appicon.co/](https://www.appicon.co/)
2. Upload your 1024×1024 master icon
3. Download the generated set
4. Drag all icons into:
   `mindmail/Assets.xcassets/AppIcon.appiconset/`
5. Rename to match the filenames in `Contents.json`

### Option C: Manually Create in Xcode

1. Open Xcode
2. Navigate to `Assets.xcassets` → `AppIcon`
3. Drag your master icon onto the **1024×1024** slot
4. Right-click → Generate All Sizes (if available)
5. Or manually create and drag each size

---

## 3. Verify Icons

### In Xcode:
1. Open `Assets.xcassets` → `AppIcon`
2. You should see all slots filled:
   - Universal 1024×1024
   - iPhone 60pt @2x (120×120)
   - iPhone 60pt @3x (180×180)
   - iPad 76pt (76×76)
   - iPad 76pt @2x (152×152)
   - iPad Pro 83.5pt @2x (167×167)

### Test:
1. Clean Build Folder: `Cmd+Shift+K`
2. Build and Run: `Cmd+R`
3. Check home screen - icon should appear
4. Check app switcher - icon should appear

---

## 4. Build for TestFlight/App Store

### Archive the App:
1. In Xcode: `Product` → `Archive`
2. Wait for archive to complete
3. Organizer window will open
4. Select your archive
5. Click **Distribute App**
6. Choose **App Store Connect**
7. Follow prompts to upload

### Common Issues:

**"Missing App Icon"**
- Solution: Make sure all icon sizes are present in Assets.xcassets

**"Invalid Icon"**
- Solution: Ensure icons are PNG, RGB (not RGBA for some sizes), and exact dimensions

**"Missing Notification Permission"**
- Solution: Add NSUserNotificationsUsageDescription to Info (see step 1)

---

## Quick Design Tips for MindMail Icon

### Style Guide:
- **Background**: Soft lavender gradient (#f0e6ff → #d0b8ff)
- **Icon**: White envelope 💌 or simplified letter
- **Style**: Minimal, clean, rounded
- **Padding**: ~10% from edges
- **No text**: Just icon/symbol

### Design in Figma (5 minutes):
1. Create 1024×1024 frame
2. Add rectangle, apply gradient:
   - Top: `#f0e6ff`
   - Bottom: `#d0b8ff`
3. Add rounded rectangle or use emoji:
   - White color
   - Center it
   - Scale to ~60% of frame
4. Export as PNG

### Or Use This Prompt for AI:
"Create a 1024x1024 iOS app icon with a soft lavender gradient background (#f0e6ff to #d0b8ff) and a white envelope icon in the center. Minimal, modern design with rounded corners."

---

## Checklist

- [ ] Added notification permission description to Info.plist
- [ ] Created master icon (1024×1024)
- [ ] Generated all icon sizes (180, 120, 167, 152, 76)
- [ ] Added icons to AppIcon.appiconset folder
- [ ] Verified icons in Xcode Assets
- [ ] Clean build and test
- [ ] Icon appears on home screen
- [ ] Ready to archive!

---

**Estimated Time:** 15-30 minutes (mostly icon design)

