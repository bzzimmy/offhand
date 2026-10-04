import Darwin

/// Resolves private framework symbols at runtime, so a symbol missing on some macOS version
/// disables one feature instead of failing to launch.
enum PrivateSymbols {
    static let hiServices = "/System/Library/Frameworks/ApplicationServices.framework/Frameworks/HIServices.framework/HIServices"

    static func load<T>(_ name: String, from framework: String, as type: T.Type) -> T? {
        guard let handle = dlopen(framework, RTLD_LAZY), let symbol = dlsym(handle, name) else { return nil }
        return unsafeBitCast(symbol, to: type)
    }
}
