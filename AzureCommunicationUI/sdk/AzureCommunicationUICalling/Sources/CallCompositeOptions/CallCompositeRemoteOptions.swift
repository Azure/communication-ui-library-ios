//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//
import Foundation
import AzureCommunicationCommon

/// Call composite remote options
public struct CallCompositeRemoteOptions {
    /// Credentials
    public let credential: CommunicationTokenCredential
    /// The display name of the local participant when joining the call.
    /// The limit for string length is 256.
    public let displayName: String?

    /// Create an instance of a RemoteOptions with options.
    /// - Parameters:
    ///   - credential: The credential used for Azure Communication Service authentication.
    ///   - displayName: The display name of the local participant for the call. The limit for string length is 256.
    public init(credential: CommunicationTokenCredential,
                displayName: String? = nil) {
        self.credential = credential
        self.displayName = displayName
    }
}
