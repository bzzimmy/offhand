import ArgumentParser

@main
struct Offhand: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "offhand",
        abstract: "Drive macOS apps in the background.",
        subcommands: [
            AppsCommand.self,
            WindowsCommand.self,
            StateCommand.self,
        ]
    )
}
