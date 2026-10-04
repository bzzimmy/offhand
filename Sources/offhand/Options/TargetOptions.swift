import ArgumentParser
import OffhandKit

/// The `--app` option shared by commands that act on a single app.
struct TargetOptions: ParsableArguments {
    @Option(name: .shortAndLong, help: "Target app: name, bundle id, or pid.")
    var app: String?

    /// Resolves `--app` against running apps, or returns nil when it was not given.
    func resolveRunningApp() throws -> AppInfo? {
        guard let app else { return nil }
        return try AppResolver.resolve(app, in: AppCatalog.running())
    }

    /// Resolves `--app` against running apps, failing when it was not given.
    func requireRunningApp() throws -> AppInfo {
        guard let app = try resolveRunningApp() else { throw ValidationError("Missing --app.") }
        return app
    }
}
