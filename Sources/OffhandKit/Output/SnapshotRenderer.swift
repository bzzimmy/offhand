/// Renders a snapshot as an indented outline, one element per line:
///
///     [3] button "Save"
///     [4] textField "Name" = "Draft" focused
public enum SnapshotRenderer {
    public static func render(_ snapshot: Snapshot) -> String {
        var lines = [header(snapshot)]
        lines += snapshot.elements.map(line)
        if snapshot.isTruncated {
            lines.append("… truncated, the window has more elements than offhand reads")
        }
        return lines.joined(separator: "\n")
    }

    static func header(_ snapshot: Snapshot) -> String {
        var parts = ["\(snapshot.appName) (pid \(snapshot.pid))"]
        if let id = snapshot.windowID { parts.append("window \(id)") }
        if let title = snapshot.windowTitle { parts.append(quoted(title)) }
        return parts.joined(separator: " ")
    }

    static func line(_ element: Snapshot.Element) -> String {
        var parts = ["[\(element.index)]", roleName(element)]
        if let label = element.label { parts.append(quoted(label)) }
        if let value = element.value { parts.append("= " + quoted(value)) }
        if element.value == nil, let placeholder = element.placeholder { parts.append("placeholder=" + quoted(placeholder)) }
        if element.isFocused { parts.append("focused") }
        if element.isSelected { parts.append("selected") }
        if !element.isEnabled { parts.append("disabled") }
        return String(repeating: "  ", count: element.depth) + parts.joined(separator: " ")
    }

    /// The subrole when there is one (it is more specific), otherwise the role, without the `AX` prefix:
    /// `AXButton` + `AXCloseButton` becomes `closeButton`.
    static func roleName(_ element: Snapshot.Element) -> String {
        let raw = element.subrole.flatMap { $0 == "AXUnknown" ? nil : $0 } ?? element.role
        let name = raw.hasPrefix("AX") ? raw.dropFirst(2) : Substring(raw)
        return name.prefix(1).lowercased() + name.dropFirst()
    }

    static func quoted(_ text: String) -> String {
        let escaped = text
            .replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: "\"", with: "\\\"")
            .replacingOccurrences(of: "\n", with: "\\n")
        return "\"\(escaped)\""
    }
}
