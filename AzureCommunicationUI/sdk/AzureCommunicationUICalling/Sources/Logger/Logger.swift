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

enum LogLevel: Int {
    case debug = 1
    case info = 2
    case warning = 3
    case error = 4
}

extension LogLevel: Comparable {}

func < (lhs: LogLevel, rhs: LogLevel) -> Bool {
    return lhs.rawValue < rhs.rawValue
}
