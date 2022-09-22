//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//
import Foundation
import os.log

struct DefaultLogger: Logger {

    private let osLogger = OSLog(subsystem: "com.azure", category: "ChatComponent")

    func debug(_ message: @escaping () -> String?) {
        log(message, atLevel: .debug)
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
            os_log("%@", log: osLogger, type: osLogTypeFor(messageLevel), msg)
        }
    }

    // MARK: Private Methods
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
