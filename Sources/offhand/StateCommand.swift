import ArgumentParser
import OffhandKit

struct StateCommand: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "state",
        abstract: "Show a window's elements as an indexed outline.",
        discussion: "The snapshot is saved so later commands can refer to elements by index."
    )

    @OptionGroup var target: TargetOptions

    @Option(help: "Window id from `offhand windows`. Defaults to the app's focused window.")
    var window: UInt32?

    func run() throws {
        let app = try target.requireRunningApp()
        let snapshot = try SnapshotReader.read(app, windowID: window)
        try SnapshotStore().save(snapshot)
        print(SnapshotRenderer.render(snapshot))
    }
}
