import CoreGraphics
import Foundation

/// A pruned, indexed view of one app window. Saved between commands so elements can be referenced by index.
public struct Snapshot: Codable, Sendable, Equatable {
    public let pid: pid_t
    public let appName: String
    public let windowID: CGWindowID?
    public let windowTitle: String?
    public let elements: [Element]
    /// True when the tree was larger than the walk limit and elements are missing.
    public let isTruncated: Bool

    public struct Element: Codable, Sendable, Equatable {
        /// 1-based index shown to the agent.
        public let index: Int
        /// Nesting level in the pruned tree, used for indentation.
        public let depth: Int
        /// Raw accessibility role, e.g. `AXButton`.
        public let role: String
        public let subrole: String?
        public let label: String?
        public let value: String?
        public let placeholder: String?
        public let isFocused: Bool
        public let isSelected: Bool
        public let isEnabled: Bool
        /// Screen coordinates, top-left origin.
        public let frame: CGRect?
        /// Child indexes from the window element down to this element, in raw `AXChildren` order.
        public let path: [Int]
    }

    public func element(at index: Int) -> Element? {
        elements.indices.contains(index - 1) ? elements[index - 1] : nil
    }
}
