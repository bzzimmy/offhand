import Foundation
import Testing
@testable import OffhandKit

struct SnapshotStoreTests {
    @Test func roundTripsSnapshotsPerPid() throws {
        let store = SnapshotStore(directory: FileManager.default.temporaryDirectory.appending(path: UUID().uuidString))
        defer { try? FileManager.default.removeItem(at: store.directory) }
        let snapshot = Snapshot(pid: 42, appName: "Notes", windowID: 7, windowTitle: nil, elements: [
            Snapshot.Element(index: 1, depth: 0, role: "AXButton", subrole: nil, label: "OK", value: nil, placeholder: nil,
                             isFocused: false, isSelected: false, isEnabled: true,
                             frame: CGRect(x: 1, y: 2, width: 3, height: 4), path: [0, 2]),
        ], isTruncated: false)

        try store.save(snapshot)
        #expect(try store.load(pid: 42) == snapshot)
        #expect(try store.load(pid: 43) == nil)
    }
}
