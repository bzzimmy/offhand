import Foundation

/// Resolves a user-supplied app query (name, bundle id, or pid) to a single app.
public enum AppResolver {
    public enum Error: Swift.Error, CustomStringConvertible {
        case notFound(String)
        case ambiguous(String, [AppInfo])

        public var description: String {
            switch self {
            case .notFound(let query):
                "No running app matches '\(query)'."
            case .ambiguous(let query, let matches):
                "'\(query)' matches several apps: "
                    + matches.map { "\($0.name) (pid \($0.pid.map(String.init) ?? "-"))" }.joined(separator: ", ")
                    + ". Use a pid instead."
            }
        }
    }

    /// Matches by pid if the query is numeric, otherwise by exact bundle id or name, ignoring case.
    public static func resolve(_ query: String, in apps: [AppInfo]) throws(Error) -> AppInfo {
        let matches: [AppInfo]
        if let pid = pid_t(query) {
            matches = apps.filter { $0.pid == pid }
        } else {
            let bundleMatches = apps.filter { $0.bundleID?.caseInsensitiveCompare(query) == .orderedSame }
            matches = bundleMatches.isEmpty
                ? apps.filter { $0.name.caseInsensitiveCompare(query) == .orderedSame }
                : bundleMatches
        }

        switch matches.count {
        case 0: throw .notFound(query)
        case 1: return matches[0]
        default: throw .ambiguous(query, matches)
        }
    }
}
