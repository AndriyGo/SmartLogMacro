import OSLog

/// Logs a message using the Swift Unified Logging system and optionally mirrors the message to a custom logging backend (e.g. Crashlytics).
///
/// This macro streamlines logging by:
/// - Ensuring consistent privacy across all interpolated values with a single `privacy` argument
/// - Supporting optional duplication of log messages to external services (e.g. Firebase Crashlytics)
/// - Simplifying log syntax while maintaining type safety and performance
///
/// - Parameters:
///   - logger: The `Logger` instance to log with. This can be a variable, a static member access (e.g. `Logger.auth`), or an inline initializer (e.g. `Logger(subsystem: "com.myapp", category: "network")`).
///   - logLevel: The `OSLogType` severity level (e.g. `.info`, `.debug`, `.error`).
///   - message: A string literal with interpolated values. Must be a `StaticString` literal for compatibility with unified logging.
///   - privacy: An optional `OSLogPrivacy` value (`.public`, `.private`, or `.auto`). This applies to **all** interpolated values in the message, avoiding the need to annotate each one manually.
///   - customLoggingFunction: An optional function (e.g. `Crashlytics.crashlytics().log`) to mirror the plain message to another logging system.
///
/// - Usage:
/// ```swift
/// #log(logger: appLogger, logLevel: .info, message: "Signed out user: \(userId)", privacy: .public)
/// #log(logger: Logger.auth, logLevel: .error, message: "Error: \(error)", customLoggingFunction: Crashlytics.crashlytics().log)
/// ```
///
/// - Note: `message` must be a string literal. This is a restriction of the Swift Unified Logging system, which requires `StaticString` format strings.

@freestanding(expression)
public macro log(
    _ logger: Logger,
    _ logLevel: OSLogType,
    _ message: String,
    privacy: OSLogPrivacy = .auto,
    customLoggingFunction: ((String) -> Void)? = nil
) = #externalMacro(module: "SmartLogImplementations", type: "Log")
