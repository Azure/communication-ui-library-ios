//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import os

@_spi(common) public protocol Logger {
    func debug(_: @autoclosure @escaping () -> String?)
    func info(_: @autoclosure @escaping () -> String?)
    func warning(_: @autoclosure @escaping () -> String?)
    func error(_: @autoclosure @escaping () -> String?)
}

@_spi(common) public struct DefaultLogger: Logger {

    private let osLogger: OSLog
    @_spi(common) public init(subsystem: String = "com.azure",
                              category: String = "AzureUICommunicationCommon") {
        osLogger = OSLog(subsystem: subsystem, category: category)
    }

    public func debug(_ message: @escaping () -> String?) {
        log(message, atLevel: .debug)
    }

    public func info(_ message: @escaping () -> String?) {
        log(message, atLevel: .info)
    }

    public func warning(_ message: @escaping () -> String?) {
        log(message, atLevel: .warning)
    }

    public func error(_ message: @escaping () -> String?) {
        log(message, atLevel: .error)
    }

    func log(_ message: () -> String?, atLevel messageLevel: LogLevel) {
        if let msg = message() {
            os_log("%@", log: osLogger, type: osLogTypeFor(messageLevel), msg)
        }
    }

    private func osLogTypeFor(_ level: LogLevel) -> OSLogType {
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

@_spi(common) public enum LogLevel: Int {
    case debug = 1
    case info = 2
    case warning = 3
    case error = 4
}

extension LogLevel: Comparable {
    @_spi(common) static public func < (lhs: LogLevel, rhs: LogLevel) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }
}

