//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import AzureCommunicationCommon
import AzureCommunicationCalling

/// Call composite push notification info.
public struct CallCompositePushNotificationInfo {
    /// call id
    public var callId: String
    /// event type
    public var eventType: CallCompositePushNotificationEventType
    /// from
    public var from: CommunicationIdentifier
    /// to
    public var to: CommunicationIdentifier
    /// from display name
    public var fromDisplayName: String
    /// incoming with video
    public var incomingWithVideo: Bool

    /// Create an instance of a CallCompositePushNotificationInfo with push notification payload.
    /// - Parameters:
    ///   - pushNotificationInfo: Push notification payload.
    public init(pushNotificationInfo: [AnyHashable: Any]) {
        let pushNotificationInfo = PushNotificationInfo.fromDictionary(pushNotificationInfo)
        self.callId = pushNotificationInfo.callId.uuidString
        self.eventType = pushNotificationInfo.eventType.toCallCompositePushNotificationEventType()
        self.from = pushNotificationInfo.from
        self.to = pushNotificationInfo.to
        self.fromDisplayName = pushNotificationInfo.fromDisplayName
        self.incomingWithVideo = pushNotificationInfo.incomingWithVideo
    }
}
