import ArgumentParser
import OffhandKit

struct WindowsCommand: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "windows",
        abstract: "List app windows, front to back."
    )

    @OptionGroup var target: TargetOptions

    func run() throws {
        let app = try target.resolveRunningApp()
        let windows = WindowList.windows(pid: app?.pid)
        let table = TextTable(
            header: ["ID", "APP", "PID", "FRAME", "STATE", "TITLE"],
            rows: windows.map { window in
                let f = window.frame
                return [
                    String(window.id),
                    window.appName,
                    String(window.pid),
                    "\(Int(f.minX)),\(Int(f.minY)) \(Int(f.width))x\(Int(f.height))",
                    window.isOnScreen ? "on-screen" : "off-screen",
                    window.title ?? "-",
                ]
            }
        )
        print(table.render())
    }
}
