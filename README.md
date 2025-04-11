# SmartLogMacro

### ✨ Swift macros for easier logging via Apple’s unified logging system with optional 3rd-party logging support (e.g. Crashlytics)

[![SPM Compatible](https://img.shields.io/badge/SPM-compatible-brightgreen?logo=swift)](https://swift.org/package-manager/)
[![License](https://img.shields.io/badge/License-Apache_2.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)
[![Buy Me a Coffee](https://img.shields.io/badge/Buy%20me%20a%20coffee-%E2%98%95-blue?logo=buymeacoffee&logoColor=white&style=flat)](https://www.buymeacoffee.com/andriyGo)

```swift
#log(logger, .info, "User \(userId) signed out at \(Date())", privacy: .public, customLoggingFunction: YourLogger.log)
```

Expands to:

```swift
{
    logger.log(level: .info, "User \(userId, privacy: .public) signed out at \(Date(), privacy: .public)")
    YourLogger.log("User \(userId) signed out at \(Date())")
}()
```

In addition, there are several shorthand macros available:

| Macro               | Privacy Level | External Logging | Description                                           |
|--------------------|---------------|------------------|-------------------------------------------------------|
| `#log`             | configurable  | optional         | Full control over logging behaviour                  |
| `#logPublic`       | `.public`     | optional         | Shortcut for always-public logs                      |
| `#smartLog`        | configurable  | always enabled   | Forwards to `SmartLogMacroCustomLogger.log`          |
| `#smartLogPublic`  | `.public`     | always enabled   | Simplest usage – public logs + external forwarding   |

---

## ✅ Key benefits

- 🔐 **Privacy made easy** – apply a single `privacy` setting to all interpolated values
- 🔁 **Optional external logging** – forward the log message to any function (e.g. Crashlytics.crashlytics().log)
- ⚡ **Zero runtime overhead** – macro expands at compile-time

---

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

Then add **SmartLogMacro** to your target dependencies:

```swift
.target(
    name: "MyTarget",
    dependencies: [.product(name: "SmartLogMacro", package: "SmartLogMacro")]
)
```

---

## 🚀 Usage

### 🔐 One-line privacy control for multiple values

With Apple's `Logger`:

```swift
logger.info("Item \(item, privacy: .public) at \(indexPath, privacy: .public)")
```

With SmartLogMacro:

```swift
#log(logger, .info, "Item \(item) at \(indexPath)", privacy: .public)
```

Expands to:

```swift
logger.log(level: .info, "Item \(item, privacy: .public) at \(indexPath, privacy: .public)")
```

Or even shorter:

```swift
#logPublic(logger, .info, "Item \(item) at \(indexPath)")
```

---

### 🔁 Send logs to 3rd-party systems (like Crashlytics)

#### Using `#smartLog` or `#smartLogPublic`

```swift
#smartLog(logger, .error, "Sign-out failed for user: \(userId)")
#smartLogPublic(logger, .info, "User signed in: \(userId)")
```

To enable this, define:

```swift
struct SmartLogMacroCustomLogger {
    static func log(_ message: String) {
        Crashlytics.crashlytics().log(message)
    }
}
```

Or use:

```swift
typealias SmartLogMacroCustomLogger = MyLogger
```

---

#### Fine-grained control

```swift
#log(logger, .error, "Error: \(error)", customLoggingFunction: Crashlytics.crashlytics().log)
#logPublic(logger, .error, "Unexpected logout", customLoggingFunction: MyLogger.send)
```

Define your own custom logger:

```swift
struct CustomLogger {
    static func log(_ message: String) {
        Crashlytics.crashlytics().log(message)
        Analytics.logEvent("log", parameters: ["message": message])
    }
}
```

---

## ⚠️ Limitations

1. **No trailing closure support for `customLoggingFunction`**  
2. **Expanded macro uses a code block**  
   May affect Xcode console line numbers.
3. **No prefixing or metadata in external logs**  
   Only raw message is passed.

💬 Most of these limitations stem from the desire to keep SmartLogMacro lightweight and simple in v1.

---

## 🤝 Contributions

Contributions are welcome!  
Open an issue or pull request — all feedback is appreciated.

---

## ☕️ Support

Enjoying SmartLogMacro?  
[Buy me a coffee](https://www.buymeacoffee.com/andriyGo) ☕💙

---

## 📄 License

SmartLogMacro is available under the [Apache License 2.0](https://www.apache.org/licenses/LICENSE-2.0).  
See the [LICENSE](LICENSE.txt) file for full details.
