# SmartLogMacro

### ✨ Swift macros for easier logging via Apple’s unified logging system with optional 3rd-party logging support (e.g. Crashlytics)

[![SPM Compatible](https://img.shields.io/badge/SPM-compatible-brightgreen?logo=swift)](https://swift.org/package-manager/)
[![License](https://img.shields.io/badge/License-Apache_2.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)
[![Buy Me a Coffee](https://img.shields.io/badge/Buy%20me%20a%20coffee-%E2%98%95-blue?logo=buymeacoffee&logoColor=white&style=flat)](https://www.buymeacoffee.com/andriyGo)

```swift
#smartLog(logger, .info, "User \(userId) signed out at \(Date())")
```

Expands to:

```swift
{
    logger.log(level: .info, "User \(userId) signed out at \(Date())")
    SmartLogMacroCustomLogger.log("User \(userId) signed out at \(Date())")
}()
```

## ✅ Key benefits

- 🔐 **Privacy made easy** – apply a single `privacy` setting to all interpolated values
- 🔁 **Optional external logging** – optionally forward the log message to any function (e.g. Crashlytics.crashlytics().log) so you can send it to Crashlytics, analytics platforms, remote log collectors, or anywhere else you like
- ⚡ **Zero runtime overhead** – macro expands at compile-time


## 📦 Installation

SmartLogMacro is available via [Swift Package Manager](https://swift.org/package-manager/).

To add it to your project in Xcode:

1. Open your project.
2. Go to **File → Add Packages...**
3. Enter the URL: https://github.com/andriyGo/SmartLogMacro
4. Select the version you want to use and press **Add Package**.

Or, add it manually to your `Package.swift`:

```swift
dependencies: [
 .package(url: "https://github.com/andriyGo/SmartLogMacro", from: "1.0.0")
]
```

Then add "SmartLogMacro" to your target dependencies:

```swift
.target(
   name: "MyTarget",
   dependencies: [.product(name: "SmartLogMacro", package: "SmartLogMacro")]
)
```

### 🧾 Macro signature

```swift
#log(
    _ logger: Logger,
    _ logLevel: OSLogType,
    _ message: String,
    privacy: OSLogPrivacy = .auto,
    customLoggingFunction: ((String) -> Void)? = nil
)
```

#### `#smartLog`

```swift
#smartLog(
    _ logger: Logger,
    _ logLevel: OSLogType,
    _ message: String,
    privacy: OSLogPrivacy = .auto
)
```

Internal implementation is equivalent to calling:

```swift
#log(
    logger,
    logLevel,
    message,
    privacy: privacy,
    customLoggingFunction: SmartLogMacroCustomLogger.log
)
```

---

## 🚀 Usage

### 🔐 One-line privacy control for multiple values

With Apple's `Logger`, every interpolated value normally requires an explicit `privacy` annotation:

```swift
logger.info("Did select item \(item, privacy: .public) at index path \(indexPath, privacy: .public)")
```

This gets repetitive — especially when all values share the same privacy level.

With SmartLogMacro, you can write:

```swift
#log(logger, .info, "Did select item \(item) at index path \(indexPath)", privacy: .public)
```

which expands to:

```swift
logger.log(level: .info, "Did select item \(item, privacy: .public) at index path \(indexPath, privacy: .public)")
```

### 🔁 Send logs to 3rd-party systems (like Crashlytics)

Sometimes you want more than just system logs — for example, sending important logs to a crash reporting tool like [Firebase Crashlytics](https://firebase.google.com/products/crashlytics).

#### Using `#smartLog`

You can drastically simplify this process by using `#smartLog` macro. You can call `#smartLog(logger, .error, "Failed to sign out user: \(error)")`, which expands to:

```swift
{
    logger.log(level: .error, "Failed to sign out user: \(error)")
    SmartLogMacroCustomLogger.log("Failed to sign out user: \(error)")
}()
```

To support this, simply declare a type `SmartLogMacroCustomLogger` with a static function `log` or declare `typealias SmartLogMacroCustomLogger = YourType` where `YourType.log` is a valid implementation.

#### Fine-grained control

If you want more fine-grained control, you can specify a `customLoggingFunction` to forward the plain log message wherever you like:

```swift
#log(logger, .error, "Failed to sign out user: \(error)", customLoggingFunction: Crashlytics.crashlytics().log)
```

which expands to:

```swift
{
    logger.log(level: .error, "Failed to sign out user: \(error)")
    Crashlytics.crashlytics().log("Failed to sign out user: \(error)")
}()
```

If you do not want to be importing Crashlytics in each source file where you use the macro, or if you wish to send your log to more destinations, you can define your own function which will process it, e.g.:

```swift
// File: CustomLogger.swift
import FirebaseCrashlytics

struct CustomLogger {
    static func log(_ message: String) {
        Crashlytics.crashlytics().log(message)
        // You can add additional processing, filtering, or forwarding here
    }
}

// File: any other file
#log(logger, .error, "Failed to sign out user: \(error)", customLoggingFunction: CustomLogger.log)
```

---

## ⚠️ Limitations

SmartLogMacro is designed to be simple and effective out of the box. The current version intentionally keeps the scope focused, but here are a few known limitations:

1. **No trailing closure support for `customLoggingFunction`**  
   You must pass the logging function directly (e.g. `Crashlytics.crashlytics().log`). Trailing closures are not currently supported.

2. **Expanded macro uses a code block**  
   When `customLoggingFunction` is used, the macro expands to a closure block (`{ ... }()`), which can make it harder to associate the log message in the Xcode console with a precise line number in your code.  
   This will be improved once [`codeItem` freestanding macros](https://github.com/swiftlang/swift-evolution/blob/main/proposals/0397-freestanding-declaration-macros.md) are no longer experimental.

3. **No prefixing or metadata in external logs**  
   Only the raw message string is passed to the `customLoggingFunction`. There is currently no built-in way to include metadata such as log level or category — but this could be extended based on real-world use cases.

💬 Most of these limitations (aside from #2) stem from a desire to keep `SmartLogMacro` lightweight and focused in its initial release.  
Suggestions and contributions are very welcome — feel free to open an issue or submit a pull request if you have ideas!

---

## 🤝 Contributions

Contributions are welcome!

If you have ideas for improvements, additional features, or run into any issues, feel free to open an issue or submit a pull request. Whether it's bug fixes, documentation, or feature suggestions — all contributions are appreciated!

---

## ☕️ Support

Enjoying SmartLogMacro? You can [buy me a coffee](https://www.buymeacoffee.com/andriyGo) to support continued development 💙

---

## 📄 License

SmartLogMacro is available under the [Apache License 2.0](https://www.apache.org/licenses/LICENSE-2.0).

You are free to use, modify, and distribute this software in compliance with the terms of the license.

See the [LICENSE](LICENSE.txt) file for full details.
