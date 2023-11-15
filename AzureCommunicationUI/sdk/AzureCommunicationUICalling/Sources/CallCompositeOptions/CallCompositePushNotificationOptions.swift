//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//
import Foundation
import AzureCommunicationCommon

/// Info required to subscribe for incoming call notifications
public struct CallCompositePushNotificationOptions {
    /// Device VoIP token
    public let deviceRegistrationToken: Data

    /// Credentials to create call agent
    public let credential: CommunicationTokenCredential

    /// The display name of the local participant when joining the call.
    /// The limit for string length is 256.
    public let displayName: String?

    /// CallKit options
    public let callKitOptions: CallCompositeCallKitOption?

    /// Create an instance of a RemoteOptions with options.
    /// - Parameters:
    ///   - deviceToken: Device VoIP token..
    ///   - credential: The credential used for Azure Communication Service authentication.
    ///   - displayName: The display name of the local participant for the call. The limit for string length is 256.
    ///   - callKitOptions: CallKit options.
    public init(deviceToken: Data,
                credential: CommunicationTokenCredential,
                displayName: String? = nil,
                callKitOptions: CallCompositeCallKitOption) {
        self.deviceRegistrationToken = deviceToken
        self.credential = credential
        self.displayName = displayName
        self.callKitOptions = callKitOptions
    }
}
