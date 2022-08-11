//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import UIKit

/// Object for local options for Call Composite
public struct LocalOptions {
    /// The ParticipantViewData of the local participant when joining the call.
    let participantViewData: ParticipantViewData
    /// The NavigationBarViewData would be used to populate title and subtitle on setup view
    let navigationBarViewData: NavigationBarViewData?
    /// Create an instance of LocalOptions. All information in this object is only stored locally in the composite.
    /// - Parameters:
    ///    - participantViewData: The ParticipantViewData to be displayed for local participants avatar
    ///    - navigationBarViewData: The NavigationBarViewData to be shown on navigation bar of set up view
    public init(participantViewData: ParticipantViewData,
                navigationBarViewData: NavigationBarViewData? = nil) {
        self.participantViewData = participantViewData
        self.navigationBarViewData = navigationBarViewData
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
    ///    - avatar: The UIImage that will be displayed in the avatar view.
    ///              If this is `nil` the default avatar with user's initials will be used instead.
    ///    - displayName: The display name  to be rendered.
    ///                   If this is `nil` the display name provided in the Call Options will be used instead.
    public init(avatar: UIImage? = nil,
                displayName: String? = nil) {
        self.avatarImage = avatar
        self.displayName = displayName
    }
}
/// Object to represent the data needed to customize navigation bar
public struct NavigationBarViewData {
    /// The title that would be used for the navigation bar of setup view
    let title: String?
    /// The subtitle that would be used for the navigation bar of setup view
    let subtitle: String?
    /// Create an instance of a NavigationBarViewData.
    /// All information in this object is only stored locally in the composite.
    /// - Parameters:
    ///    - title: The String that would be displayed as the title in setup view
    ///              If this is `nil` the default title "Setup" would be used
    ///    - subtitle: The String that would be displayed as the subtitle in setup view
    ///                   If this is `nil` the subtitle would be hidden
    public init(title: String? = nil,
                subtitle: String? = nil) {
        self.title = title
        self.subtitle = subtitle
    }
}
