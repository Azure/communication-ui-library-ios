//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
@testable import AzureCommunicationUIChat

class LoggerMocking {
    var logCallCount: Int = 0

    func logWasCalled() -> Bool {
        return logCallCount > 0
    }
}

extension LoggerMocking: Logger {
    func debug(_: @autoclosure @escaping () -> String?) {
        logCallCount += 1

    }

    func info(_: @autoclosure @escaping () -> String?) {
        logCallCount += 1

    }

    func warning(_: @autoclosure @escaping () -> String?) {
        logCallCount += 1

    }

    func error(_: @autoclosure @escaping () -> String?) {
        logCallCount += 1

    }
}
