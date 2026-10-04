import ArgumentParser
import OffhandKit

struct AppsCommand: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "apps",
        abstract: "List running and installed apps."
    )

    @Flag(help: "Only list running apps.")
    var running = false

    func run() {
        let apps = running ? AppCatalog.running() : AppCatalog.all()
        let table = TextTable(
            header: ["NAME", "STATE", "PID", "BUNDLE ID"],
            rows: apps.map { app in
                [app.name, app.state.rawValue, app.pid.map(String.init) ?? "-", app.bundleID ?? "-"]
            }
        )
        print(table.render())
    }
}
