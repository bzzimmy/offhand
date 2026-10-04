import CoreGraphics
import Testing
@testable import OffhandKit

struct SnapshotRendererTests {
    func element(_ index: Int, depth: Int = 0, role: String, subrole: String? = nil, label: String? = nil,
                 value: String? = nil, placeholder: String? = nil, focused: Bool = false) -> Snapshot.Element {
        Snapshot.Element(index: index, depth: depth, role: role, subrole: subrole, label: label, value: value,
                         placeholder: placeholder, isFocused: focused, isSelected: false, isEnabled: true,
                         frame: nil, path: [])
    }

    @Test func rendersIndentedOutline() {
        let snapshot = Snapshot(pid: 42, appName: "Notes", windowID: 7, windowTitle: "Notes", elements: [
            element(1, role: "AXButton", subrole: "AXCloseButton"),
            element(2, role: "AXTextField", label: "Search", placeholder: "Search notes", focused: true),
            element(3, depth: 1, role: "AXStaticText", label: "Line one\n\"two\""),
        ], isTruncated: false)

        #expect(SnapshotRenderer.render(snapshot) == #"""
            Notes (pid 42) window 7 "Notes"
            [1] closeButton
            [2] textField "Search" placeholder="Search notes" focused
              [3] staticText "Line one\n\"two\""
            """#)
    }
}
