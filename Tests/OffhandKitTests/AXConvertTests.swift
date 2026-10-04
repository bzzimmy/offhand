import Foundation
import Testing
@testable import OffhandKit

struct AXConvertTests {
    @Test func treatsBlankAndIconGlyphStringsAsMissing() {
        #expect(AXConvert.string("") == nil)
        #expect(AXConvert.string(" \n") == nil)
        #expect(AXConvert.string("\u{EB60}") == nil)
        #expect(AXConvert.string("Save") == "Save")
    }

    @Test func formatsNumbers() {
        #expect(AXConvert.string(NSNumber(value: 1)) == "1")
    }
}
