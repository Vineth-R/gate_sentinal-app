# iOS Notification Setup

## Required iOS Configuration

For iOS push notifications to work properly, you need to add notification permissions to your `ios/Runner/Info.plist` file.

### Add these keys to Info.plist:

```xml
<dict>
    <!-- Your existing keys... -->
    
    <!-- Notification permissions -->
    <key>UIBackgroundModes</key>
    <array>
        <string>remote-notification</string>
    </array>
    
    <!-- Optional: Custom notification sound -->
    <key>CFBundleDocumentTypes</key>
    <array>
        <dict>
            <key>CFBundleTypeName</key>
            <string>Notification Sound</string>
            <key>CFBundleTypeRole</key>
            <string>Editor</string>
            <key>LSItemContentTypes</key>
            <array>
                <string>public.audio</string>
            </array>
        </dict>
    </array>
</dict>
```

### Location of Info.plist:
`ios/Runner/Info.plist`

### Notes:
- These permissions allow the app to receive notifications when closed
- The notification service automatically requests user permission on first launch
- Users can manage notification settings in iOS Settings > Gate Sentinel
