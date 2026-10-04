import Foundation

/// Keeps the latest snapshot of each app on disk, one JSON file per pid.
public struct SnapshotStore {
    public let directory: URL

    public init(directory: URL = Self.defaultDirectory) {
        self.directory = directory
    }

    public static var defaultDirectory: URL {
        URL.cachesDirectory.appending(path: "offhand/snapshots", directoryHint: .isDirectory)
    }

    public func save(_ snapshot: Snapshot) throws {
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        try JSONEncoder().encode(snapshot).write(to: file(for: snapshot.pid), options: .atomic)
    }

    /// The latest snapshot for `pid`, or nil if none was saved.
    public func load(pid: pid_t) throws -> Snapshot? {
        let file = file(for: pid)
        guard FileManager.default.fileExists(atPath: file.path) else { return nil }
        return try JSONDecoder().decode(Snapshot.self, from: Data(contentsOf: file))
    }

    private func file(for pid: pid_t) -> URL {
        directory.appending(path: "\(pid).json")
    }
}
