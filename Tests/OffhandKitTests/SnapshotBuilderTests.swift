import CoreGraphics
import Testing
@testable import OffhandKit

struct SnapshotBuilderTests {
    func node(_ role: String, title: String? = nil, value: String? = nil, index: Int = 0, children: [RawNode] = []) -> RawNode {
        RawNode(role: role, title: title, value: value, indexInParent: index, children: children)
    }

    @Test func hoistsUnlabeledGroupsAndKeepsRawPaths() {
        let window = node("AXWindow", children: [
            node("AXGroup", index: 0, children: [
                node("AXButton", title: "Save", index: 2),
            ]),
        ])
        let elements = SnapshotBuilder.elements(under: window)
        #expect(elements.map(\.label) == ["Save"])
        #expect(elements[0].depth == 0)
        #expect(elements[0].path == [0, 2])
    }

    @Test func dropsTextThatRepeatsItsParentLabel() {
        let window = node("AXWindow", children: [
            node("AXLink", title: "Docs", children: [node("AXStaticText", value: "Docs")]),
            node("AXStaticText", value: "Hello", index: 1),
        ])
        let elements = SnapshotBuilder.elements(under: window)
        #expect(elements.map(\.label) == ["Docs", "Hello"])
        #expect(elements.map(\.index) == [1, 2])
    }

    @Test func skipsScrollBarsAndEmptyLeaves() {
        let window = node("AXWindow", children: [
            node("AXScrollBar", value: "0"),
            node("AXImage", index: 1),
            node("AXButton", index: 2),
        ])
        #expect(SnapshotBuilder.elements(under: window).map(\.role) == ["AXButton"])
    }
}

extension SnapshotBuilderTests {
    @Test func hoistsGroupsThatRepeatTheirParentLabel() {
        let window = node("AXWindow", title: "Main", children: [
            node("AXGroup", title: "Main", children: [
                node("AXRadioButton", title: "Explorer", children: [
                    node("AXGroup", title: "Explorer", children: [node("AXStaticText", value: "Explorer")]),
                ]),
            ]),
        ])
        let elements = SnapshotBuilder.elements(under: window)
        #expect(elements.map(\.label) == ["Explorer"])
    }
}

extension SnapshotBuilderTests {
    @Test func keepsControlLabelsThatRepeatTheirParent() {
        let window = node("AXWindow", children: [
            node("AXToolbar", title: "Manage", children: [node("AXPopUpButton", title: "Manage")]),
        ])
        #expect(SnapshotBuilder.elements(under: window).map(\.label) == ["Manage", "Manage"])
    }
}
