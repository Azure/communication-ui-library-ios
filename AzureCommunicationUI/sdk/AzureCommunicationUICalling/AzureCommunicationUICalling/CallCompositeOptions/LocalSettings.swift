//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import UIKit
/// Object for local settings for Call Composite
public struct LocalSettings {
    /// The ParticipantViewData of the local participant when joining the call.
    let participantViewData: ParticipantViewData
    /// Create an instance of LocalSettings. All information in this object is only stored locally in the composite.
    /// - Parameters:
    ///    - participantViewData: The ParticipantViewData to be displayed for local participants avatar
    public init(_ participantViewData: ParticipantViewData) {
        self.participantViewData = participantViewData
    }
}
/// Object to represent participants data
public struct ParticipantViewData {
    /// The image that will be drawn on the avatar view
    let avatarImage: UIImage?
    /// The display name that will be locally rendered for this participant
    let displayName: String?
    /// Create an instance of a ParticipantViewData.
    /// All information in this object is only stored locally in the composite.
    /// - Parameters:
    ///    - avatar: The UIImage that will be displayer in the avatar view.
    ///              If this is `nil` the default avatar with user's initials will be used instead.
    ///    - displayName: The display name  to be rendered.
    ///                   If this is `nil` the display name provided in the Call Options will be used instead.
    public init(avatar: UIImage? = nil,
                displayName: String? = nil) {
        self.avatarImage = avatar
        self.displayName = displayName
    }
}
