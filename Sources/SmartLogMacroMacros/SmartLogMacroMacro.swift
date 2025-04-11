import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import OSLog

enum SmartLogError: Error {
    case wrongNumberOfArguments
    case unsupportedSyntaxForArgument(String)
    case missingArgument(String)
    case trailingClosuresNotSupported
}

fileprivate struct HelperFunctions {
    
    static func extractNamed(_ argName: String, from args: LabeledExprListSyntax, allowedSyntaxes:[ExprSyntaxProtocol.Type]? = nil, memberAccessBaseName: String = "") throws -> ExprSyntaxProtocol {
        for arg in args {
            if case .identifier(argName) = arg.label?.tokenKind {
                if let allowedSyntaxes = allowedSyntaxes {
                    return try validate(arg, argName: argName, allowedSyntaxes: allowedSyntaxes)
                }
                return arg.expression
            }
        }
        throw SmartLogError.missingArgument(argName)
    }
    
    static func validate(_ arg: LabeledExprListSyntax.Element, argName:String, allowedSyntaxes:[ExprSyntaxProtocol.Type], memberAccessBaseName: String = "") throws -> ExprSyntaxProtocol {
        for t in allowedSyntaxes {
            if let v = arg.expression.as(t) {
                if let cast = v as? MemberAccessExprSyntax {
                    return addBaseIfNeeded(to: cast, base: memberAccessBaseName)
                }
                else if var cast = v as? FunctionCallExprSyntax, let access = cast.calledExpression.as(MemberAccessExprSyntax.self) {
                    cast.calledExpression = ExprSyntax(addBaseIfNeeded(to: access, base: memberAccessBaseName))
                    return cast
                }
                else {
                    return v
                }
            }
        }
        throw SmartLogError.unsupportedSyntaxForArgument(argName)
    }
    
    static func addBaseIfNeeded(to memberAccess: MemberAccessExprSyntax, base: String) -> MemberAccessExprSyntax {
        if memberAccess.base != nil {
            return memberAccess
        }
        else {
            return MemberAccessExprSyntax(base:DeclReferenceExprSyntax(baseName: .identifier(base)), period: memberAccess.period, declName: memberAccess.declName)
        }
    }
}

public struct Log: ExpressionMacro {
    public static func expansion(
        of node: some FreestandingMacroExpansionSyntax,
        in context: some MacroExpansionContext
    ) throws -> ExprSyntax {
        let args = Array(node.arguments)
        guard args.count >= 3 && args.count <= 5 else {
            throw SmartLogError.wrongNumberOfArguments
        }
        guard node.trailingClosure == nil else {
            throw SmartLogError.trailingClosuresNotSupported
        }
        let message = try HelperFunctions.validate(args[2], argName:"message", allowedSyntaxes: [StringLiteralExprSyntax.self, MacroExpansionExprSyntax.self])
        let logger = try HelperFunctions.validate(args[0], argName:"logger", allowedSyntaxes: [MemberAccessExprSyntax.self, DeclReferenceExprSyntax.self, FunctionCallExprSyntax.self], memberAccessBaseName: "Logger")
        
        let logLevel = try HelperFunctions.validate(args[1], argName:"logLevel", allowedSyntaxes: [MemberAccessExprSyntax.self, DeclReferenceExprSyntax.self, FunctionCallExprSyntax.self])
        var logMessageWithPrivacy:any ExprSyntaxProtocol
        if let privacy = try? HelperFunctions.extractNamed("privacy", from: node.arguments, allowedSyntaxes: [MemberAccessExprSyntax.self]) as? MemberAccessExprSyntax, let message = message as? StringLiteralExprSyntax {
            // Privacy option provided, so we must add it to log message
            var copy = message
            logMessageWithPrivacy = message
            var segments = StringLiteralSegmentListSyntax()
            for segment in message.segments {
                if let s = segment.as(ExpressionSegmentSyntax.self) {
                    var newExpr = s
                    newExpr.expressions = []
                    var i = 0
                    let expressions = Array(s.expressions)
                    while i < expressions.count {
                        var toAdd = expressions[i]
                        if i == expressions.count-1 {
                            // this is the last one, add trailing comma and privacy
                            toAdd.trailingComma = .commaToken()
                            newExpr.expressions.append(toAdd)
                            newExpr.expressions.append(LabeledExprSyntax(label: "privacy", expression: privacy))
                            break
                        }
                        else {
                            newExpr.expressions.append(toAdd)
                        }
                        i += 1
                    }
                    segments.append(.expressionSegment(newExpr))
                }
                else {
                    segments.append(segment)
                }
            }
            copy.segments = segments
            logMessageWithPrivacy = copy
        }
        else {
            // Privacy not provided, so we log the message as-is
            logMessageWithPrivacy = message
        }
        do {
            let customLoggingFunction = try HelperFunctions.extractNamed("customLoggingFunction", from: node.arguments, allowedSyntaxes: [DeclReferenceExprSyntax.self, MemberAccessExprSyntax.self])
            return try ExprSyntax(validating: ExprSyntax(#"""
                {
                \#(logger).log(level: \#(logLevel), \#(logMessageWithPrivacy))
                \#(customLoggingFunction)(\#(message))
                }()
                """#))
        }
        catch {
            if case SmartLogError.missingArgument(_) = error {
                // custom logging not provided
                return try ExprSyntax(validating: ExprSyntax(#"""
                    \#(logger).log(level: \#(logLevel), \#(logMessageWithPrivacy))
                    """#))
            }
            else {
                throw error
            }
        }
    }
}

public struct LogPublic: ExpressionMacro {
    public static func expansion(
        of node: some FreestandingMacroExpansionSyntax,
        in context: some MacroExpansionContext
    ) throws -> ExprSyntax {
        guard node.arguments.count >= 3 && node.arguments.count <= 4 else {
            throw SmartLogError.wrongNumberOfArguments
        }
        // all we need to do is to add another argument `customLoggingFunction`
        // and call the Log above
        var nodeCopy = node
        let argumentsCopy = Array(node.arguments)
        var arguments = LabeledExprListSyntax()
        var i = 0
        let privacyArg = LabeledExprSyntax(label: "privacy", expression: MemberAccessExprSyntax(
            period: .periodToken(),
            declName: DeclReferenceExprSyntax(baseName: .identifier("public"))))
        while i < node.arguments.count {
            if i == 3 {
                arguments.append(privacyArg)
            }
            arguments.append(argumentsCopy[i])
            i += 1
        }
        if i == 3 {
            arguments.append(privacyArg)
        }
        nodeCopy.arguments = arguments
        return try Log.expansion(of: nodeCopy, in: context)
    }
}

public struct SmartLog: ExpressionMacro {
    public static func expansion(
        of node: some FreestandingMacroExpansionSyntax,
        in context: some MacroExpansionContext
    ) throws -> ExprSyntax {
        guard node.arguments.count >= 3 && node.arguments.count <= 4 else {
            throw SmartLogError.wrongNumberOfArguments
        }
        // all we need to do is to add another argument `customLoggingFunction`
        // and call the Log above
        var nodeCopy = node
        var arguments = node.arguments
        arguments.append(LabeledExprSyntax(label: "customLoggingFunction", expression: MemberAccessExprSyntax(
            base: DeclReferenceExprSyntax(baseName: .identifier("SmartLogMacroCustomLogger")),
            period: .periodToken(),
            declName: DeclReferenceExprSyntax(baseName: .identifier("log"))
        )))
        nodeCopy.arguments = arguments
        return try Log.expansion(of: nodeCopy, in: context)
    }
}

public struct SmartLogPublic: ExpressionMacro {
    public static func expansion(
        of node: some FreestandingMacroExpansionSyntax,
        in context: some MacroExpansionContext
    ) throws -> ExprSyntax {
        guard node.arguments.count == 3 else {
            throw SmartLogError.wrongNumberOfArguments
        }
        // all we need to do is to add another argument `customLoggingFunction`
        // and call the Log above
        var nodeCopy = node
        var arguments = node.arguments
        arguments.append(LabeledExprSyntax(label: "privacy", expression: MemberAccessExprSyntax(
            period: .periodToken(),
            declName: DeclReferenceExprSyntax(baseName: .identifier("public")))))
        arguments.append(LabeledExprSyntax(label: "customLoggingFunction", expression: MemberAccessExprSyntax(
            base: DeclReferenceExprSyntax(baseName: .identifier("SmartLogMacroCustomLogger")),
            period: .periodToken(),
            declName: DeclReferenceExprSyntax(baseName: .identifier("log"))
        )))
        nodeCopy.arguments = arguments
        return try Log.expansion(of: nodeCopy, in: context)
    }
}

@main
struct SmartLogMacroPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        Log.self,
        LogPublic.self,
        SmartLog.self,
        SmartLogPublic.self
    ]
}
