//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

class LoggerMocking {}

extension LoggerMocking: Logger {
    func debug(_: @autoclosure @escaping () -> String?) {}
    func info(_: @autoclosure @escaping () -> String?) {}
    func warning(_: @autoclosure @escaping () -> String?) {}
    func error(_: @autoclosure @escaping () -> String?) {}
}
