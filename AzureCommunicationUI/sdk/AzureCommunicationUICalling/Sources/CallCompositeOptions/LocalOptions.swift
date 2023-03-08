//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import UIKit

/// Object for local options for Call Composite
public struct LocalOptions {
    /// The ParticipantViewData of the local participant when joining the call.
    let participantViewData: ParticipantViewData?
    /// The SetupScreenViewData is used for call setup screen
    let setupScreenViewData: SetupScreenViewData?
    ///  The CarmeraOnByDefault is used when we skip the setup screen
    let cameraOnByDefaultIfPermissionIsGranted: Bool?
    ///  The MicrophoneOnByDefacult is used when we skip the setup screen
    let microphoneOnByDefaultIfPermissionIsGranted: Bool?
    ///  The SkipSetup is used when we skip the setup screen
    let skipSetup: Bool?
    /// Create an instance of LocalOptions. All information in this object is only stored locally in the composite.
    /// - Parameters:
    ///    - participantViewData: The ParticipantViewData to be displayed for local participants avatar
    ///    - setupScreenViewData: The SetupScreenViewData to be used to set up views on setup screen
    public init(participantViewData: ParticipantViewData? = nil,
                setupScreenViewData: SetupScreenViewData? = nil,
                cameraOnByDefaultIfPermissionIsGranted: Bool? = true,
                microphoneOnByDefaultIfPermissionIsGranted: Bool? = false,
                skipSetup: Bool = false
    ) {
        self.participantViewData = participantViewData
        self.setupScreenViewData = setupScreenViewData
        self.cameraOnByDefaultIfPermissionIsGranted = cameraOnByDefaultIfPermissionIsGranted
        self.microphoneOnByDefaultIfPermissionIsGranted = microphoneOnByDefaultIfPermissionIsGranted
        self.skipSetup = skipSetup
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
/// Object to represent the data needed to customize the call setup screen's view data
public struct SetupScreenViewData {
    /// The title that would be used for the navigation bar on setup screen
    let title: String
    /// The subtitle that would be used for the navigation bar on setup screen
    let subtitle: String?
    /// Create an instance of a SetupScreenViewData.
    /// All information in this object is only stored locally in the composite.
    /// - Parameters:
    ///    - title: The String that would be displayed as the title on setup screen
    ///              If title is empty the default title "Setup" would be used
    ///    - subtitle: The String that would be displayed as the subtitle on setup screen
    ///                   If this is `nil` the subtitle would be hidden
    public init(title: String,
                subtitle: String? = nil) {
        self.title = title
        self.subtitle = subtitle
    }
}
