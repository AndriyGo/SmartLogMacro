import SmartLogMacro
import OSLog

struct Custom {
    func log(_ message:String) {
        
    }
}

typealias SmartLogMacroCustomLogger = Custom

#smartLog(Logger(), .debug, "wow")
