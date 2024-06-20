//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import AzureCommunicationCommon
import AzureCommunicationCalling

/// Call composite push notification.
public struct PushNotification {
    /// call id
    public let callId: String
    /// event type
    public let eventType: PushNotificationEventType
    /// from
    public let from: CommunicationIdentifier
    /// to
    public let to: CommunicationIdentifier
    /// from display name
    public let fromDisplayName: String
    /// incoming with video
    public let hasIncomingVideo: Bool

    let data: [AnyHashable: Any]

    /// Create an instance of a PushNotification with push notification payload.
    /// - Parameters:
    ///   - data: Push notification payload.
    public init(data: [AnyHashable: Any]) {
        let pushNotificationInfo = PushNotificationInfo.fromDictionary(data)
        self.data = data
        self.callId = pushNotificationInfo.callId.uuidString
        self.eventType = pushNotificationInfo.eventType.toPushNotificationEventType()
        self.from = pushNotificationInfo.from
        self.to = pushNotificationInfo.to
        self.fromDisplayName = pushNotificationInfo.fromDisplayName
        self.hasIncomingVideo = pushNotificationInfo.incomingWithVideo
    }
}
