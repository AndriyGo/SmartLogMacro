@_exported import OSLog

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
///   - message: A string literal (e.g. `"Signed out user: \(userId)"`) or a built-in macro like `#function`. The expression must resolve to a `StaticString`, as required by unified logging.
///   - privacy: An optional `OSLogPrivacy` value (`.public`, `.private`, or `.auto`). This applies to **all** interpolated values in the message.
///   - customLoggingFunction: An optional function (e.g. `Crashlytics.crashlytics().log`) to mirror the plain message to another logging system.
///
/// - Usage:
/// ```swift
/// #log(logger, .info, "Signed out user: \(userId)", privacy: .public)
/// #log(Logger.auth, .error, "Error: \(error)", customLoggingFunction: Crashlytics.crashlytics().log)
/// ```
///
/// - Note:
///   - The `message` must be a `StaticString` or macro expression that produces one (e.g. `#file`, `#function`, etc.).
///
/// - See also:
///   - `#logPublic` for `.public` privacy with optional forwarding
///   - `#smartLog` and `#smartLogPublic` for shorthand usage with predefined destinations
@freestanding(expression)
public macro log(
    _ logger: Logger,
    _ logLevel: OSLogType,
    _ message: String,
    privacy: OSLogPrivacy = .auto,
    customLoggingFunction: ((String) -> Void)? = nil
) = #externalMacro(module: "SmartLogMacroMacros", type: "Log")

/// Logs a message using the Swift Unified Logging system with `.public` privacy for all interpolated values,
/// and optionally mirrors the message to a custom logging backend (e.g. Crashlytics).
///
/// This macro is a convenience wrapper around `#log(...)`, with the `privacy` level set to `.public` by default.
///
/// - Parameters:
///   - logger: The `Logger` instance to log with.
///   - logLevel: The `OSLogType` severity level (e.g. `.info`, `.debug`, `.error`).
///   - message: A string literal or built-in macro (e.g. `#function`) that resolves to a `StaticString`.
///   - customLoggingFunction: An optional function to mirror the plain message to another logging system.
///
/// - Usage:
/// ```swift
/// #logPublic(logger, .info, "Signed out user: \(userId)")
/// #logPublic(logger, .error, "Error: \(error)", customLoggingFunction: Crashlytics.crashlytics().log)
/// ```
///
/// - Note:
///   - The `message` must be a `StaticString` or macro expression that produces one.
///
/// - See also:
///   - `#log` for full customization
///   - `#smartLogPublic` for a predefined external logging function
@freestanding(expression)
public macro logPublic(
    _ logger: Logger,
    _ logLevel: OSLogType,
    _ message: String,
    customLoggingFunction: ((String) -> Void)? = nil
) = #externalMacro(module: "SmartLogMacroMacros", type: "LogPublic")

/// Logs a message using the Swift Unified Logging system and also forwards it to a predefined custom logging function (`SmartLogMacroCustomLogger.log`).
///
/// This macro is equivalent to calling:
/// ```swift
/// #log(logger, logLevel, message, privacy: ..., customLoggingFunction: SmartLogMacroCustomLogger.log)
/// ```
///
/// - Parameters:
///   - logger: The `Logger` instance to log with.
///   - logLevel: The `OSLogType` severity level (e.g. `.info`, `.debug`, `.error`).
///   - message: A string literal or macro expression (e.g. `#function`) that resolves to a `StaticString`.
///   - privacy: An optional `OSLogPrivacy` value that applies to all interpolated values.
///
/// - Usage:
/// ```swift
/// #smartLog(logger, .info, "User signed out: \(userId)", privacy: .public)
/// #smartLog(Logger.auth, .error, "Error: \(error)")
/// ```
///
/// - Note:
///   - You must define `SmartLogMacroCustomLogger.log(_:)` in your project, or set `typealias SmartLogMacroCustomLogger = YourLoggerType`.
///   - The `message` must resolve to a `StaticString`.
///
/// - See also:
///   - `#log` for configurable logging
///   - `#smartLogPublic` for `.public` privacy by default
@freestanding(expression)
public macro smartLog(
    _ logger: Logger,
    _ logLevel: OSLogType,
    _ message: String,
    privacy: OSLogPrivacy = .auto
) = #externalMacro(module: "SmartLogMacroMacros", type: "SmartLog")

/// Logs a message using the Swift Unified Logging system with `.public` privacy for all interpolated values,
/// and automatically mirrors the message to a predefined custom logging function (`SmartLogMacroCustomLogger.log`).
///
/// This macro is a shorthand version of `#logPublic(...)`, optimized for projects that always forward logs
/// to the same external system (e.g. Crashlytics).
///
/// - Parameters:
///   - logger: The `Logger` instance to log with.
///   - logLevel: The `OSLogType` severity level (e.g. `.info`, `.debug`, `.error`).
///   - message: A string literal or macro expression (e.g. `#function`) that resolves to a `StaticString`.
///
/// - Usage:
/// ```swift
/// #smartLogPublic(logger, .info, "User signed out: \(userId)")
/// #smartLogPublic(logger, .debug, #function)
/// ```
///
/// - Note:
///   - You must define `SmartLogMacroCustomLogger.log(_:)` or set `typealias SmartLogMacroCustomLogger = YourLoggerType`.
///   - The `message` must be a `StaticString` or macro expression that produces one.
///
/// - See also:
///   - `#logPublic` for `.public` privacy with optional forwarding
///   - `#smartLog` for privacy control and predefined forwarding
@freestanding(expression)
public macro smartLogPublic(
    _ logger: Logger,
    _ logLevel: OSLogType,
    _ message: String
) = #externalMacro(module: "SmartLogMacroMacros", type: "SmartLogPublic")
