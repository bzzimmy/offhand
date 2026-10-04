import Testing
@testable import OffhandKit

struct AppResolverTests {
    let apps = [
        AppInfo(name: "Safari", bundleID: "com.apple.Safari", pid: 100, state: .running, url: nil),
        AppInfo(name: "Notes", bundleID: "com.apple.Notes", pid: 200, state: .active, url: nil),
        AppInfo(name: "Notes", bundleID: "com.example.notes", pid: 300, state: .running, url: nil),
    ]

    @Test func resolvesByPid() throws {
        #expect(try AppResolver.resolve("100", in: apps).name == "Safari")
    }

    @Test func resolvesByBundleIDIgnoringCase() throws {
        #expect(try AppResolver.resolve("COM.APPLE.NOTES", in: apps).pid == 200)
    }

    @Test func resolvesByNameIgnoringCase() throws {
        #expect(try AppResolver.resolve("safari", in: apps).pid == 100)
    }

    @Test func reportsAmbiguousNames() {
        #expect(throws: AppResolver.Error.self) { try AppResolver.resolve("Notes", in: apps) }
    }

    @Test func reportsMissingApps() {
        #expect(throws: AppResolver.Error.self) { try AppResolver.resolve("Xcode", in: apps) }
    }
}
