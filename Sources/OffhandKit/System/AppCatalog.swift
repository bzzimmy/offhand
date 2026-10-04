import AppKit

/// Lists running apps and apps installed in the standard application folders.
public enum AppCatalog {
    /// Folders scanned for installed apps, one level of subfolders deep (e.g. `/Applications/Utilities`).
    static let searchRoots: [URL] = [
        URL(filePath: "/Applications"),
        URL(filePath: "/System/Applications"),
        FileManager.default.homeDirectoryForCurrentUser.appending(path: "Applications"),
    ]

    /// Regular (Dock) apps that are currently running, sorted by name.
    public static func running() -> [AppInfo] {
        NSWorkspace.shared.runningApplications
            .filter { $0.activationPolicy == .regular }
            .map { app in
                AppInfo(
                    name: app.localizedName ?? app.bundleURL?.deletingPathExtension().lastPathComponent ?? "pid \(app.processIdentifier)",
                    bundleID: app.bundleIdentifier,
                    pid: app.processIdentifier,
                    state: app.isActive ? .active : app.isHidden ? .hidden : .running,
                    url: app.bundleURL
                )
            }
            .sorted(by: byName)
    }

    /// Installed apps, all marked `.closed`, sorted by name.
    public static func installed() -> [AppInfo] {
        var seen = Set<String>()
        return searchRoots
            .flatMap { appBundles(in: $0, depth: 1) }
            .compactMap { url -> AppInfo? in
                let bundleID = Bundle(url: url)?.bundleIdentifier
                guard seen.insert(bundleID ?? url.path).inserted else { return nil }
                return AppInfo(
                    name: url.deletingPathExtension().lastPathComponent,
                    bundleID: bundleID,
                    pid: nil,
                    state: .closed,
                    url: url
                )
            }
            .sorted(by: byName)
    }

    /// Running apps followed by installed apps that are not running.
    public static func all() -> [AppInfo] {
        let running = running()
        let runningKeys = Set(running.flatMap { [$0.bundleID, $0.url?.path] }.compactMap(\.self))
        let closed = installed().filter { app in
            !runningKeys.contains(app.bundleID ?? "") && !runningKeys.contains(app.url?.path ?? "")
        }
        return running + closed
    }

    private static func appBundles(in directory: URL, depth: Int) -> [URL] {
        let items = (try? FileManager.default.contentsOfDirectory(
            at: directory,
            includingPropertiesForKeys: [.isDirectoryKey],
            options: [.skipsHiddenFiles]
        )) ?? []
        return items.flatMap { url -> [URL] in
            if url.pathExtension == "app" { return [url] }
            guard depth > 0, (try? url.resourceValues(forKeys: [.isDirectoryKey]))?.isDirectory == true else { return [] }
            return appBundles(in: url, depth: depth - 1)
        }
    }

    private static func byName(_ a: AppInfo, _ b: AppInfo) -> Bool {
        a.name.localizedStandardCompare(b.name) == .orderedAscending
    }
}
