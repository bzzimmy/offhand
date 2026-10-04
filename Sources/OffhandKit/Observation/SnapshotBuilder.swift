/// Prunes a raw tree into indexed snapshot elements.
///
/// Passive elements (layout containers, text, images) that add no text of their own are removed, and
/// their children move up a level. Text that only repeats the parent's label adds nothing. Scroll bars
/// are skipped.
enum SnapshotBuilder {
    static let layoutRoles: Set = ["AXGroup", "AXScrollArea", "AXSplitGroup", "AXLayoutArea", "AXLayoutItem", "AXUnknown"]
    static let skippedRoles: Set = ["AXScrollBar"]
    static let maxTextLength = 200

    /// Elements below `root`. The root itself (the window) is not included.
    static func elements(under root: RawNode) -> [Snapshot.Element] {
        var elements: [Snapshot.Element] = []
        visitChildren(of: root, path: [], depth: 0, parentLabel: label(of: root), into: &elements)
        return elements
    }

    private static func visitChildren(of node: RawNode, path: [Int], depth: Int, parentLabel: String?, into elements: inout [Snapshot.Element]) {
        for child in node.children where !skippedRoles.contains(child.role) {
            let path = path + [child.indexInParent]
            let label = label(of: child)

            if isTransparent(child, label: label, parentLabel: parentLabel) {
                visitChildren(of: child, path: path, depth: depth, parentLabel: parentLabel, into: &elements)
                continue
            }

            elements.append(Snapshot.Element(
                index: elements.count + 1,
                depth: depth,
                role: child.role,
                subrole: child.subrole,
                label: label.map(truncated),
                value: child.role == "AXStaticText" || child.value == label ? nil : child.value.map(truncated),
                placeholder: child.placeholder.map(truncated),
                isFocused: child.isFocused,
                isSelected: child.isSelected,
                isEnabled: child.isEnabled,
                frame: child.frame,
                path: path
            ))
            visitChildren(of: child, path: path, depth: depth + 1, parentLabel: label ?? parentLabel, into: &elements)
        }
    }

    /// Static text keeps its text in the value; everything else uses the title, then the description.
    private static func label(of node: RawNode) -> String? {
        node.role == "AXStaticText" ? node.value ?? node.title : node.title ?? node.description
    }

    private static func isTransparent(_ node: RawNode, label: String?, parentLabel: String?) -> Bool {
        let isPassive = layoutRoles.contains(node.role)
            || node.children.isEmpty && (node.role == "AXStaticText" || node.role == "AXImage")
        let addsText = label != nil && label != parentLabel || node.value != nil && node.role != "AXStaticText"
        return isPassive && !addsText && !node.isFocused && !node.isSelected
    }

    private static func truncated(_ text: String) -> String {
        text.count > maxTextLength ? text.prefix(maxTextLength) + "…" : text
    }
}
