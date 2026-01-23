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
                SmartLogMacroCustomLogger.log("[logger] Error: wow \\(a) and \\(b)!")
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
                Crashlytics.log("[logger] Error: wow \\(a) and \\(b)!")
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
                SmartLogMacroCustomLogger.log("[logger] Error: wow \\(a) and \\(b)!")
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
                hey("[logger] Error: wow \\(a) and \\(b)!")
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
                hey("[logger] Error: wow \\(a) and \\(b)!")
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
                hey("[logger] Error: wow")
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
                hey("[logger] Error: wow \\(a)")
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
                hey("[logger] Error: wow \\(a) and \\(b)")
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
                hey("[logger] Error: wow \\(a) and \\(b)!")
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
                hey("[logger] Error: \\(#function)")
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
                hey("[logger] Error: \\(#function(a))")
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
                hey("[logger] Error: ")
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
                Class.hey("[logger] Error: ")
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
                Class.singleton().hey("[logger] Error: ")
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
    
    func testLoggerCategoryExtraction() throws {
        #if canImport(SmartLogMacroMacros)
        // Test .network syntax
        assertMacroExpansion(
            """
            #log(.network, .info, "test", customLoggingFunction: hey)
            """,
            expandedSource: """
            {
                Logger.network.log(level: .info, "test")
                hey("[network] Info: test")
            }()
            """,
            macros: testMacros
        )
        
        // Test Logger.auth syntax
        assertMacroExpansion(
            """
            #log(Logger.auth, .error, "failed", customLoggingFunction: hey)
            """,
            expandedSource: """
            {
                Logger.auth.log(level: .error, "failed")
                hey("[auth] Error: failed")
            }()
            """,
            macros: testMacros
        )
        
        // Test different log levels get capitalized properly
        assertMacroExpansion(
            """
            #log(.database, .debug, "query", customLoggingFunction: hey)
            """,
            expandedSource: """
            {
                Logger.database.log(level: .debug, "query")
                hey("[database] Debug: query")
            }()
            """,
            macros: testMacros
        )
        
        assertMacroExpansion(
            """
            #log(.api, .fault, "critical", customLoggingFunction: hey)
            """,
            expandedSource: """
            {
                Logger.api.log(level: .fault, "critical")
                hey("[api] Fault: critical")
            }()
            """,
            macros: testMacros
        )
        
        // Test OSLogType.error (non-member access with base)
        assertMacroExpansion(
            """
            #log(.network, OSLogType.error, "test", customLoggingFunction: hey)
            """,
            expandedSource: """
            {
                Logger.network.log(level: OSLogType.error, "test")
                hey("[network] Error: test")
            }()
            """,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
}
