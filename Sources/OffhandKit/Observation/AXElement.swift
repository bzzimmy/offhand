import ApplicationServices

extension AXUIElement {
    /// Reads several attributes in one round trip. Missing attributes are left out of the result.
    func values(of attributes: [String]) -> [String: Any] {
        var raw: CFArray?
        guard AXUIElementCopyMultipleAttributeValues(self, attributes as CFArray, [], &raw) == .success,
              let values = raw as? [Any]
        else { return [:] }

        var result: [String: Any] = [:]
        for (name, value) in zip(attributes, values) where !Self.isMissing(value) {
            result[name] = value
        }
        return result
    }

    func value(of attribute: String) -> Any? {
        var value: CFTypeRef?
        guard AXUIElementCopyAttributeValue(self, attribute as CFString, &value) == .success, let value else { return nil }
        return value
    }

    /// The window server id of a window element.
    var windowID: CGWindowID? {
        guard let getWindow = Self.getWindow else { return nil }
        var id: CGWindowID = 0
        return getWindow(self, &id) == .success && id != 0 ? id : nil
    }

    /// Batch reads report missing attributes as `NSNull` or as an `AXValue` wrapping an error.
    private static func isMissing(_ value: Any) -> Bool {
        if value is NSNull { return true }
        let ref = value as CFTypeRef
        return CFGetTypeID(ref) == AXValueGetTypeID() && AXValueGetType(ref as! AXValue) == .axError
    }

    private typealias GetWindowFunction = @convention(c) (AXUIElement, UnsafeMutablePointer<CGWindowID>) -> AXError
    private static let getWindow = PrivateSymbols.load("_AXUIElementGetWindow", from: PrivateSymbols.hiServices, as: GetWindowFunction.self)
}

/// Converts attribute values to the plain Swift types the snapshot stores.
enum AXConvert {
    /// Strings that are blank or only contain icon-font glyphs (private-use characters) count as missing.
    static func string(_ value: Any?) -> String? {
        switch value {
        case let string as String: string.unicodeScalars.contains(where: isVisible) ? string : nil
        case let number as NSNumber: number.stringValue
        default: nil
        }
    }

    private static func isVisible(_ scalar: Unicode.Scalar) -> Bool {
        !scalar.properties.isWhitespace && scalar.properties.generalCategory != .privateUse
    }

    static func bool(_ value: Any?) -> Bool {
        (value as? NSNumber)?.boolValue ?? false
    }

    static func frame(position: Any?, size: Any?) -> CGRect? {
        var origin = CGPoint.zero
        var extent = CGSize.zero
        guard let position = axValue(position), AXValueGetValue(position, .cgPoint, &origin),
              let size = axValue(size), AXValueGetValue(size, .cgSize, &extent)
        else { return nil }
        return CGRect(origin: origin, size: extent)
    }

    private static func axValue(_ value: Any?) -> AXValue? {
        guard let value, CFGetTypeID(value as CFTypeRef) == AXValueGetTypeID() else { return nil }
        return (value as! AXValue)
    }
}
