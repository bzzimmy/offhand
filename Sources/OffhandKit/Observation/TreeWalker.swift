import ApplicationServices

/// An accessibility element as read from the app, before pruning.
struct RawNode {
    var role: String
    var subrole: String?
    var title: String?
    var description: String?
    var value: String?
    var placeholder: String?
    var isFocused = false
    var isSelected = false
    var isEnabled = true
    var frame: CGRect?
    /// Position in the parent's `AXChildren`, used to find the element again later.
    var indexInParent = 0
    var children: [RawNode] = []

    var containsWebArea: Bool {
        role == "AXWebArea" || children.contains { $0.containsWebArea }
    }
}

/// Reads an element subtree depth-first, one batched attribute read per element.
struct TreeWalker {
    static let attributes = [
        "AXRole", "AXSubrole", "AXTitle", "AXDescription", "AXValue", "AXPlaceholderValue",
        "AXFocused", "AXSelected", "AXEnabled", "AXPosition", "AXSize", "AXChildren",
    ]

    var maxNodes = 3000
    var maxDepth = 40
    private(set) var nodeCount = 0

    var isTruncated: Bool { nodeCount >= maxNodes }

    mutating func walk(_ element: AXUIElement, depth: Int = 0) -> RawNode? {
        guard nodeCount < maxNodes else { return nil }
        let values = element.values(of: Self.attributes)
        guard let role = values["AXRole"] as? String else { return nil }
        nodeCount += 1

        var node = RawNode(
            role: role,
            subrole: AXConvert.string(values["AXSubrole"]),
            title: AXConvert.string(values["AXTitle"]),
            description: AXConvert.string(values["AXDescription"]),
            value: AXConvert.string(values["AXValue"]),
            placeholder: AXConvert.string(values["AXPlaceholderValue"]),
            isFocused: AXConvert.bool(values["AXFocused"]),
            isSelected: AXConvert.bool(values["AXSelected"]),
            isEnabled: values["AXEnabled"].map(AXConvert.bool) ?? true,
            frame: AXConvert.frame(position: values["AXPosition"], size: values["AXSize"])
        )
        if depth < maxDepth, let children = values["AXChildren"] as? [AXUIElement] {
            node.children = children.enumerated().compactMap { index, child in
                var node = walk(child, depth: depth + 1)
                node?.indexInParent = index
                return node
            }
        }
        return node
    }
}
