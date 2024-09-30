//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import os

protocol Logger {
    func debug(_: @autoclosure @escaping () -> String?)
    func info(_: @autoclosure @escaping () -> String?)
    func warning(_: @autoclosure @escaping () -> String?)
    func error(_: @autoclosure @escaping () -> String?)
}

struct DefaultLogger: Logger {

    private static let osLogger: OSLog = OSLog(subsystem: "com.azure", category: "AzureCommunicationUICommon")
    init(subsystem: String = "com.azure",
         category: String = "AzureCommunicationUICommon") {
//        osLogger = OSLog(subsystem: subsystem, category: category)
    }

    func debug(_ message: @escaping () -> String?) {
        log(message, atLevel: .debug)
    }
    
    public static func debugStatic(_ message: @autoclosure @escaping () -> String?) {
        DefaultLogger.log(message, atLevel: .debug)
    }

    func info(_ message: @escaping () -> String?) {
        log(message, atLevel: .info)
    }

    func warning(_ message: @escaping () -> String?) {
        log(message, atLevel: .warning)
    }

    func error(_ message: @escaping () -> String?) {
        log(message, atLevel: .error)
    }

    func log(_ message: () -> String?, atLevel messageLevel: LogLevel) {
        if let msg = message() {
            os_log("%@", log: DefaultLogger.osLogger, type: DefaultLogger.osLogTypeFor(messageLevel), msg)
        }
    }
    
    static func log(_ message: () -> String?, atLevel messageLevel: LogLevel) {
        if let msg = message() {
            os_log("%@", log: DefaultLogger.osLogger, type: DefaultLogger.osLogTypeFor(messageLevel), msg)
        }
    }

    private static func osLogTypeFor(_ level: LogLevel) -> OSLogType {
        switch level {
        case .error,
             .warning:
            return .error
        case .info:
            return .info
        case .debug:
            return .debug
        }
    }
}

enum LogLevel: Int {
    case debug = 1
    case info = 2
    case warning = 3
    case error = 4
}

extension LogLevel: Comparable {
    static func < (lhs: LogLevel, rhs: LogLevel) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }
}
