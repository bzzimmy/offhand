import Foundation

/// An app that is either running or installed on disk.
public struct AppInfo: Sendable, Equatable {
    public enum State: String, Sendable {
        /// Running and frontmost.
        case active
        case running
        case hidden
        /// Installed but not running.
        case closed
    }

    public let name: String
    public let bundleID: String?
    public let pid: pid_t?
    public let state: State
    public let url: URL?

    public init(name: String, bundleID: String?, pid: pid_t?, state: State, url: URL?) {
        self.name = name
        self.bundleID = bundleID
        self.pid = pid
        self.state = state
        self.url = url
    }

    public var isRunning: Bool { state != .closed }
}
