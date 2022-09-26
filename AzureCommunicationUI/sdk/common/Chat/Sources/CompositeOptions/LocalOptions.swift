//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import UIKit

/// Object for local options for the Composite
public struct LocalOptions {
    let isLaunchingWithUI: Bool
    /// The ParticipantViewData of the local participant.
    let participantViewData: ParticipantViewData
    /// Create an instance of LocalOptions. All information in this object is only stored locally in the composite.
    /// - Parameters:
    ///    - participantViewData: The ParticipantViewData to be displayed for local participants avatar
    public init(participantViewData: ParticipantViewData,
                isLaunchingWithUI: Bool = false) {
        self.participantViewData = participantViewData
        self.isLaunchingWithUI = isLaunchingWithUI
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
    ///                   If this is `nil` the display name provided in the Options will be used instead.
    public init(avatar: UIImage? = nil,
                displayName: String? = nil) {
        self.avatarImage = avatar
        self.displayName = displayName
    }
}
