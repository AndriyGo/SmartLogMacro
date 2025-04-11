import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest
import OSLog

// Macro implementations build for the host, so the corresponding module is not available when cross-compiling. Cross-compiled tests may still make use of the macro itself in end-to-end tests.
#if canImport(SmartLogMacroMacros)
import SmartLogMacroMacros

let testMacros: [String: Macro.Type] = [
    "log": Log.self,
    "logPublic": LogPublic.self,
    "smartLog": SmartLog.self,
    "smartLogPublic": SmartLogPublic.self
]
#endif

final class SmartLogTests: XCTestCase {
    
    func testSmartLogPublic() throws {
        #if canImport(SmartLogMacroMacros)
        assertMacroExpansion(
            """
            #smartLogPublic(logger, .error, "wow \\(a) and \\(b)!")
            """,
            expandedSource: """
            {
                logger.log(level: .error, "wow \\(a, privacy: .public) and \\(b, privacy: .public)!")
                SmartLogMacroCustomLogger.log("wow \\(a) and \\(b)!")
            }()
            """,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
        }
    
    func testLogPublic() throws {
        #if canImport(SmartLogMacroMacros)
        assertMacroExpansion(
            """
            #logPublic(logger, .error, "wow \\(a) and \\(b)!")
            """,
            expandedSource: """
            logger.log(level: .error, "wow \\(a, privacy: .public) and \\(b, privacy: .public)!")
            """,
            macros: testMacros
        )
        assertMacroExpansion(
            """
            #logPublic(logger, .error, "wow \\(a) and \\(b)!", customLoggingFunction: Crashlytics.log)
            """,
            expandedSource: """
            {
                logger.log(level: .error, "wow \\(a, privacy: .public) and \\(b, privacy: .public)!")
                Crashlytics.log("wow \\(a) and \\(b)!")
            }()
            """,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
    
    func testSmartLog() throws {
        #if canImport(SmartLogMacroMacros)
        assertMacroExpansion(
            """
            #smartLog(logger, .error, "wow \\(a) and \\(b)!", privacy: .private)
            """,
            expandedSource: """
            {
                logger.log(level: .error, "wow \\(a, privacy: .private) and \\(b, privacy: .private)!")
                SmartLogMacroCustomLogger.log("wow \\(a) and \\(b)!")
            }()
            """,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
    
    func testValidPrivacyLevels() throws {
        #if canImport(SmartLogMacroMacros)
        assertMacroExpansion(
            """
            #log(logger, .error, "wow \\(a) and \\(b)!", privacy: .private, customLoggingFunction: hey)
            """,
            expandedSource: """
            {
                logger.log(level: .error, "wow \\(a, privacy: .private) and \\(b, privacy: .private)!")
                hey("wow \\(a) and \\(b)!")
            }()
            """,
            macros: testMacros
        )
        assertMacroExpansion(
            """
            #log(logger, .error, "wow \\(a) and \\(b)!", privacy: OSLogPrivacy.private, customLoggingFunction: hey)
            """,
            expandedSource: """
            {
                logger.log(level: .error, "wow \\(a, privacy: OSLogPrivacy.private) and \\(b, privacy: OSLogPrivacy.private)!")
                hey("wow \\(a) and \\(b)!")
            }()
            """,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
    
    func testValidMessages() throws {
        #if canImport(SmartLogMacroMacros)
        assertMacroExpansion(
            """
            #log(logger, .error, "wow", customLoggingFunction: hey)
            """,
            expandedSource: """
            {
                logger.log(level: .error, "wow")
                hey("wow")
            }()
            """,
            macros: testMacros
        )
        assertMacroExpansion(
            """
            #log(logger, .error, "wow \\(a)", customLoggingFunction: hey)
            """,
            expandedSource: """
            {
                logger.log(level: .error, "wow \\(a)")
                hey("wow \\(a)")
            }()
            """,
            macros: testMacros
        )
        assertMacroExpansion(
            """
            #log(logger, .error, "wow \\(a) and \\(b)", customLoggingFunction: hey)
            """,
            expandedSource: """
            {
                logger.log(level: .error, "wow \\(a) and \\(b)")
                hey("wow \\(a) and \\(b)")
            }()
            """,
            macros: testMacros
        )
        assertMacroExpansion(
            """
            #log(logger, .error, "wow \\(a) and \\(b)!", customLoggingFunction: hey)
            """,
            expandedSource: """
            {
                logger.log(level: .error, "wow \\(a) and \\(b)!")
                hey("wow \\(a) and \\(b)!")
            }()
            """,
            macros: testMacros
        )
        assertMacroExpansion(
            """
            #log(logger, .error, #function, customLoggingFunction: hey)
            """,
            expandedSource: """
            {
                logger.log(level: .error, #function)
                hey(#function)
            }()
            """,
            macros: testMacros
        )
        assertMacroExpansion(
            """
            #log(logger, .error, #function(a), customLoggingFunction: hey)
            """,
            expandedSource: """
            {
                logger.log(level: .error, #function(a))
                hey(#function(a))
            }()
            """,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
    
    func testValidCustomFunctions() throws {
        #if canImport(SmartLogMacroMacros)
        assertMacroExpansion(
            """
            #log(logger, .error, "", customLoggingFunction: hey)
            """,
            expandedSource: """
            {
                logger.log(level: .error, "")
                hey("")
            }()
            """,
            macros: testMacros
        )
        assertMacroExpansion(
            """
            #log(logger, .error, "", customLoggingFunction: Class.hey)
            """,
            expandedSource: """
            {
                logger.log(level: .error, "")
                Class.hey("")
            }()
            """,
            macros: testMacros
        )
        assertMacroExpansion(
            """
            #log(logger, .error, "", customLoggingFunction: Class.singleton().hey)
            """,
            expandedSource: """
            {
                logger.log(level: .error, "")
                Class.singleton().hey("")
            }()
            """,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
    
    func testvalidLogLevels() throws {
        #if canImport(SmartLogMacroMacros)
        assertMacroExpansion(
            """
            #log(logger, .error, "")
            """,
            expandedSource: """
            logger.log(level: .error, "")
            """,
            macros: testMacros
        )
        assertMacroExpansion(
            """
            #log(logger, OSLogType.error, "")
            """,
            expandedSource: """
            logger.log(level: OSLogType.error, "")
            """,
            macros: testMacros
        )
        assertMacroExpansion(
            """
            #log(logger, OSLogType(rawValue: 2), "")
            """,
            expandedSource: """
            logger.log(level: OSLogType(rawValue: 2), "")
            """,
            macros: testMacros
        )
        assertMacroExpansion(
            """
            #log(logger, OSLogType.init(rawValue: 2), "")
            """,
            expandedSource: """
            logger.log(level: OSLogType.init(rawValue: 2), "")
            """,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
    
    func testvalidLoggerSyntaxes() throws {
        #if canImport(SmartLogMacroMacros)
        assertMacroExpansion(
            """
            #log(logger, .debug, "")
            """,
            expandedSource: """
            logger.log(level: .debug, "")
            """,
            macros: testMacros
        )
        assertMacroExpansion(
            """
            #log(.logger, .debug, "")
            """,
            expandedSource: """
            Logger.logger.log(level: .debug, "")
            """,
            macros: testMacros
        )
        assertMacroExpansion(
            """
            #log(Logger(subsystem: "sub", category: "cat"), .debug, "")
            """,
            expandedSource: """
            Logger(subsystem: "sub", category: "cat").log(level: .debug, "")
            """,
            macros: testMacros
        )
        assertMacroExpansion(
            """
            #log(Logger.init(subsystem: "sub", category: "cat"), .debug, "")
            """,
            expandedSource: """
            Logger.init(subsystem: "sub", category: "cat").log(level: .debug, "")
            """,
            macros: testMacros
        )
        assertMacroExpansion(
            """
            #log(.init(subsystem: "sub", category: "cat"), .debug, "")
            """,
            expandedSource: """
            Logger.init(subsystem: "sub", category: "cat").log(level: .debug, "")
            """,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
}
