#!/bin/bash
set -euo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "$0")" && pwd)"
PREFERRED_DEVELOPER_DIR="/Volumes/RAID1-SAMSUNG-SSD-1TB/ApplicationExt/Xcode.app/Contents/Developer"
APP_NAME="markMeDown"
APP_BUNDLE="$ROOT_DIR/dist/$APP_NAME.app"
BUNDLE_ID="${BUNDLE_ID:-org.markmedown.app}"

if [[ ! "$BUNDLE_ID" =~ ^[A-Za-z0-9-]+(\.[A-Za-z0-9-]+)+$ ]]; then
    echo "Ungültige Bundle-ID '$BUNDLE_ID'. Verwende z. B. org.example.markMeDown." >&2
    exit 1
fi

if [[ -n "${DEVELOPER_DIR:-}" ]]; then
    SELECTED_DEVELOPER_DIR="$DEVELOPER_DIR"
elif [[ -d "$PREFERRED_DEVELOPER_DIR" ]]; then
    SELECTED_DEVELOPER_DIR="$PREFERRED_DEVELOPER_DIR"
else
    SELECTED_DEVELOPER_DIR="$(xcode-select -p 2>/dev/null || true)"
fi

if [[ -z "$SELECTED_DEVELOPER_DIR" || ! -d "$SELECTED_DEVELOPER_DIR" ]]; then
    echo "Xcode/Swift nicht gefunden. Installiere Xcode oder setze DEVELOPER_DIR." >&2
    exit 1
fi

export DEVELOPER_DIR="$SELECTED_DEVELOPER_DIR"
SWIFT_EXECUTABLE="$(/usr/bin/xcrun --find swift 2>/dev/null || true)"
if [[ -z "$SWIFT_EXECUTABLE" || ! -x "$SWIFT_EXECUTABLE" ]]; then
    echo "Swift wurde in der Toolchain '$DEVELOPER_DIR' nicht gefunden." >&2
    exit 1
fi

echo "Verwende Xcode-Toolchain: $DEVELOPER_DIR"
"$SWIFT_EXECUTABLE" build --configuration release --package-path "$ROOT_DIR"

CHECKOUTS_DIR="$ROOT_DIR/.build/checkouts"
SWIFT_MARKDOWN_LICENSE="$CHECKOUTS_DIR/swift-markdown/LICENSE.txt"
SWIFT_MARKDOWN_NOTICE="$CHECKOUTS_DIR/swift-markdown/NOTICE.txt"
SWIFT_CMARK_COPYING="$CHECKOUTS_DIR/swift-cmark/COPYING"

for license_file in "$SWIFT_MARKDOWN_LICENSE" "$SWIFT_MARKDOWN_NOTICE" "$SWIFT_CMARK_COPYING"; do
    if [[ ! -f "$license_file" ]]; then
        echo "Erforderlicher Drittanbieter-Lizenztext fehlt: $license_file" >&2
        echo "Führe zuerst 'swift package resolve' aus." >&2
        exit 1
    fi
done

mkdir -p "$APP_BUNDLE/Contents/MacOS" "$APP_BUNDLE/Contents/Resources/ThirdPartyNotices"
install -m 755 "$ROOT_DIR/.build/release/$APP_NAME" "$APP_BUNDLE/Contents/MacOS/$APP_NAME"
install -m 644 "$ROOT_DIR/THIRD_PARTY_NOTICES.md" "$APP_BUNDLE/Contents/Resources/ThirdPartyNotices/THIRD_PARTY_NOTICES.md"
install -m 644 "$SWIFT_MARKDOWN_LICENSE" "$APP_BUNDLE/Contents/Resources/ThirdPartyNotices/swift-markdown-LICENSE.txt"
install -m 644 "$SWIFT_MARKDOWN_NOTICE" "$APP_BUNDLE/Contents/Resources/ThirdPartyNotices/swift-markdown-NOTICE.txt"
install -m 644 "$SWIFT_CMARK_COPYING" "$APP_BUNDLE/Contents/Resources/ThirdPartyNotices/swift-cmark-COPYING"

cat > "$APP_BUNDLE/Contents/Info.plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleDevelopmentRegion</key>
    <string>de</string>
    <key>CFBundleExecutable</key>
    <string>$APP_NAME</string>
    <key>CFBundleIdentifier</key>
    <string>$BUNDLE_ID</string>
    <key>CFBundleInfoDictionaryVersion</key>
    <string>6.0</string>
    <key>CFBundleName</key>
    <string>$APP_NAME</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>LSMinimumSystemVersion</key>
    <string>14.0</string>
    <key>LSApplicationCategoryType</key>
    <string>public.app-category.productivity</string>
    <key>NSPrincipalClass</key>
    <string>NSApplication</string>
</dict>
</plist>
PLIST

/usr/bin/plutil -lint "$APP_BUNDLE/Contents/Info.plist"
echo "App-Bundle erstellt: $APP_BUNDLE"
