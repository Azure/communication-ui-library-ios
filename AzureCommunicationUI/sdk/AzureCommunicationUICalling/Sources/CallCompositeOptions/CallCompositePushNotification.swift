//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import AzureCommunicationCommon
import AzureCommunicationCalling

/// Call composite push notification.
public struct CallCompositePushNotification {
    /// call id
    public let callId: String
    /// event type
    public let eventType: CallCompositePushNotificationEventType
    /// from
    public let from: CommunicationIdentifier
    /// to
    public let to: CommunicationIdentifier
    /// from display name
    public let fromDisplayName: String
    /// incoming with video
    public let hasIncomingVideo: Bool

    /// Create an instance of a CallCompositePushNotificationInfo with push notification payload.
    /// - Parameters:
    ///   - data: Push notification payload.
    public init(data: [AnyHashable: Any]) {
        let pushNotificationInfo = PushNotificationInfo.fromDictionary(data)
        self.callId = pushNotificationInfo.callId.uuidString
        self.eventType = pushNotificationInfo.eventType.toCallCompositePushNotificationEventType()
        self.from = pushNotificationInfo.from
        self.to = pushNotificationInfo.to
        self.fromDisplayName = pushNotificationInfo.fromDisplayName
        self.hasIncomingVideo = pushNotificationInfo.incomingWithVideo
    }
}
