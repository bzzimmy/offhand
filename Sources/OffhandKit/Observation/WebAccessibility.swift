import ApplicationServices
import Foundation

/// Chromium and Electron apps only build their accessibility tree when asked to.
enum WebAccessibility {
    /// Turns on the accessibility tree of Chromium-based apps. Returns false for other apps,
    /// which are left untouched.
    ///
    /// Electron supports the documented `AXManualAccessibility` flag. Chromium browsers reject it
    /// and need `AXEnhancedUserInterface`, which is only set on them because it changes window
    /// animation behavior in other apps. Both setters can report errors even when they worked.
    static func enable(_ app: AXUIElement, bundleURL: URL?) -> Bool {
        guard let bundleURL, isChromiumBased(bundleURL) else { return false }
        let result = AXUIElementSetAttributeValue(app, "AXManualAccessibility" as CFString, kCFBooleanTrue)
        if result == .attributeUnsupported {
            AXUIElementSetAttributeValue(app, "AXEnhancedUserInterface" as CFString, kCFBooleanTrue)
        }
        return true
    }

    /// Chromium-based apps ship a "<Product> Framework.framework", e.g. "Electron Framework.framework"
    /// or "Google Chrome Framework.framework".
    static func isChromiumBased(_ bundleURL: URL) -> Bool {
        let frameworks = bundleURL.appending(path: "Contents/Frameworks")
        let names = (try? FileManager.default.contentsOfDirectory(atPath: frameworks.path)) ?? []
        return names.contains { $0.hasSuffix(" Framework.framework") }
    }
}
