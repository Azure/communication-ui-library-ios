//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import UIKit

public struct CallStatusCode {
    public static let none: String = "none"
    public static let connected: String = "connected"

}

public struct NavigationStatusCode {
    public static let none: String = "none"
    public static let setup: String = "setup"
    public static let call: String = "call"
    public static let exit: String = "exit"

}

public struct CallCompositeStatus {
    public let callStatusCode: String
    public let navigationStatusCode: Error
}
