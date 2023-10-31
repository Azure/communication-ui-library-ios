//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

public struct PushNotificationOptions {
    public let deviceRegistrationToken: Data
    // add credential here
    public init(deviceToken: Data) {
        self.deviceRegistrationToken = deviceToken
    }
}
