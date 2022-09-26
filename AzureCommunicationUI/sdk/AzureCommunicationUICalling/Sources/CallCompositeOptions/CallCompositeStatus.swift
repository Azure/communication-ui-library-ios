//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import UIKit

public struct CallStatusCode {
    static let none: String = "none"
    static let connected: String = "connected"

}

public struct NavigationStatusCode {
    static let none: String = "none"
    static let setup: String = "setup"
    static let call: String = "call"
    static let exit: String = "exit"

}

public struct CallCompositeStatus {
    public let callStatusCode: String
    public var navigationStatusCode: Error
}
