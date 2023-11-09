//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//
import Foundation
import AzureCommunicationCommon

public struct CallCompositePushNotificationOptions {
    public let deviceRegistrationToken: Data
    public let credential: CommunicationTokenCredential

    /// The display name of the local participant when joining the call.
    /// The limit for string length is 256.
    public let displayName: String?

    /// CallKit options
    public let callKitOptions: CallCompositeCallKitOption?

    public init(deviceToken: Data,
                credential: CommunicationTokenCredential,
                displayName: String? = nil,
                callKitOptions: CallCompositeCallKitOption? = nil) {
        self.deviceRegistrationToken = deviceToken
        self.credential = credential
        self.displayName = displayName
        self.callKitOptions = callKitOptions
    }
}
