//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

public struct CallCompositeStatus {
    public let callStatusCode: String
    public let navigationStatusCode: Error
}

public struct CallStatusCode {
    public static let none0: String = "none"
    public static let connected: String = "connected"

}

public struct NavigationStatusCode {
    public static let none0: String = "none"
    public static let setup: String = "setup"
    public static let call: String = "call"
    public static let exit: String = "exit"

}


