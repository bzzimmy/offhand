import AppKit
import CoreGraphics

/// A top-level app window as reported by the window server.
public struct WindowInfo: Sendable, Equatable {
    public let id: CGWindowID
    public let pid: pid_t
    public let appName: String
    public let title: String?
    public let frame: CGRect
    /// False for windows that are minimized, hidden, or on another Space.
    public let isOnScreen: Bool
}

public enum WindowList {
    /// Normal windows of regular apps, front to back. Pass a pid to limit the list to one app.
    ///
    /// The raw window list includes many untitled helper windows (menu bar strips, placeholders),
    /// so off-screen windows are only kept when they have a title. Titles need Screen Recording permission.
    public static func windows(pid: pid_t? = nil) -> [WindowInfo] {
        guard let raw = CGWindowListCopyWindowInfo([.optionAll, .excludeDesktopElements], kCGNullWindowID) as? [[String: Any]] else {
            return []
        }
        let regularPIDs = Set(
            NSWorkspace.shared.runningApplications
                .filter { $0.activationPolicy == .regular }
                .map(\.processIdentifier)
        )

        return raw.compactMap(WindowInfo.init(entry:)).filter { window in
            guard regularPIDs.contains(window.pid), pid == nil || window.pid == pid else { return false }
            return window.isOnScreen
                ? window.frame.width >= minimumSide && window.frame.height >= minimumSide
                : window.title != nil
        }
    }

    static let minimumSide: CGFloat = 50
}

extension WindowInfo {
    /// Parses one `CGWindowListCopyWindowInfo` entry, keeping only normal (layer 0), visible-alpha windows.
    init?(entry: [String: Any]) {
        guard
            entry[kCGWindowLayer as String] as? Int == 0,
            (entry[kCGWindowAlpha as String] as? Double ?? 0) > 0,
            let id = entry[kCGWindowNumber as String] as? CGWindowID,
            let pid = entry[kCGWindowOwnerPID as String] as? pid_t,
            let boundsDict = entry[kCGWindowBounds as String] as? NSDictionary,
            let frame = CGRect(dictionaryRepresentation: boundsDict)
        else { return nil }

        let title = entry[kCGWindowName as String] as? String
        self.init(
            id: id,
            pid: pid,
            appName: entry[kCGWindowOwnerName as String] as? String ?? "",
            title: title?.isEmpty == false ? title : nil,
            frame: frame,
            isOnScreen: entry[kCGWindowIsOnscreen as String] as? Bool ?? false
        )
    }
}
