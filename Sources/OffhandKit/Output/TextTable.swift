/// Renders rows as left-aligned, space-separated columns. The last column is never padded.
public struct TextTable {
    public var header: [String]
    public var rows: [[String]]

    public init(header: [String], rows: [[String]] = []) {
        self.header = header
        self.rows = rows
    }

    public func render() -> String {
        let all = [header] + rows
        let columnCount = all.map(\.count).max() ?? 0
        let widths = (0..<columnCount).map { column in
            all.map { $0.indices.contains(column) ? $0[column].count : 0 }.max() ?? 0
        }

        return all.map { row in
            row.enumerated().map { column, cell in
                column == row.count - 1 ? cell : cell.padding(toLength: widths[column], withPad: " ", startingAt: 0)
            }
            .joined(separator: "  ")
        }
        .joined(separator: "\n")
    }
}
