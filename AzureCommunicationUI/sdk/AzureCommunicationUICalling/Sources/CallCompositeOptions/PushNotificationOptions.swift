//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//
import Foundation
import AzureCommunicationCommon

public struct PushNotificationOptions {
    public let deviceRegistrationToken: Data
    public let credential: CommunicationTokenCredential
    public init(deviceToken: Data,
                credential: CommunicationTokenCredential) {
        self.deviceRegistrationToken = deviceToken
        self.credential = credential
    }
}
