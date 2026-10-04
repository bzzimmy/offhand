import Testing
@testable import OffhandKit

struct TextTableTests {
    @Test func alignsColumnsWithoutPaddingTheLastOne() {
        let table = TextTable(header: ["NAME", "PID"], rows: [["Safari", "1"], ["Notes", "22"]])
        #expect(table.render() == """
            NAME    PID
            Safari  1
            Notes   22
            """)
    }
}
