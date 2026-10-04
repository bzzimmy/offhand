import ApplicationServices
import Foundation

/// Reads the accessibility tree of an app window into a snapshot.
public enum SnapshotReader {
    public enum Error: Swift.Error, CustomStringConvertible {
        case notTrusted
        case noWindow(String)
        case windowNotFound(CGWindowID)

        public var description: String {
            switch self {
            case .notTrusted:
                "Accessibility access is not granted. Enable it for your terminal in System Settings > Privacy & Security > Accessibility."
            case .noWindow(let app):
                "\(app) has no window that accessibility can see. It may be minimized or on another Space."
            case .windowNotFound(let id):
                "Window \(id) is not visible to accessibility. It may be minimized or on another Space."
            }
        }
    }

    /// Global per-request timeout, so an unresponsive app cannot hang the command.
    static let messagingTimeout: Float = 2
    /// How long to wait for a Chromium-based app to build its web tree after it was enabled.
    static let webTreeTimeout: TimeInterval = 3

    /// Snapshots the given window, or the app's focused window when `windowID` is nil.
    public static func read(_ app: AppInfo, windowID: CGWindowID? = nil) throws(Error) -> Snapshot {
        guard AXIsProcessTrusted() else { throw .notTrusted }
        guard let pid = app.pid else { throw .noWindow(app.name) }
        AXUIElementSetMessagingTimeout(AXUIElementCreateSystemWide(), messagingTimeout)

        let appElement = AXUIElementCreateApplication(pid)
        let isWebApp = WebAccessibility.enable(appElement, bundleURL: app.url)
        let window = try findWindow(in: appElement, appName: app.name, id: windowID)

        var walker = TreeWalker()
        var root = walker.walk(window)
        let deadline = Date.now.addingTimeInterval(webTreeTimeout)
        while isWebApp, root?.containsWebArea == false, Date.now < deadline {
            Thread.sleep(forTimeInterval: 0.25)
            walker = TreeWalker()
            root = walker.walk(window)
        }

        return Snapshot(
            pid: pid,
            appName: app.name,
            windowID: window.windowID,
            windowTitle: root?.title,
            elements: root.map(SnapshotBuilder.elements(under:)) ?? [],
            isTruncated: walker.isTruncated
        )
    }

    private static func findWindow(in app: AXUIElement, appName: String, id: CGWindowID?) throws(Error) -> AXUIElement {
        let windows = app.value(of: "AXWindows") as? [AXUIElement] ?? []
        if let id {
            guard let window = windows.first(where: { $0.windowID == id }) else { throw .windowNotFound(id) }
            return window
        }
        let focused = app.value(of: "AXFocusedWindow").map { $0 as! AXUIElement }
        guard let window = focused ?? windows.first else { throw .noWindow(appName) }
        return window
    }
}
