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
    /// The CameraOn is used when we skip the setup screen
    let cameraOn: Bool?
    /// The MicrophoneOn is used when we skip the setup screen
    let microphoneOn: Bool?
    /// The SkipSetupScreen is used when we skip the setup screen
    let skipSetupScreen: Bool?
    /// The avMode selects the scope of audio/video locally for the call
    let avMode: CallCompositeAvMode

    /// Create an instance of LocalOptions. All information in this object is only stored locally in the composite.
    /// - Parameters:
    ///    - participantViewData: The ParticipantViewData to be displayed for local participants avatar
    ///    - setupScreenViewData: The SetupScreenViewData to be used to set up views on setup screen
    public init(participantViewData: ParticipantViewData? = nil,
                setupScreenViewData: SetupScreenViewData? = nil,
                cameraOn: Bool? = false,
                microphoneOn: Bool? = false,
                skipSetupScreen: Bool? = false,
                avMode: CallCompositeAvMode = .normal) {
        self.participantViewData = participantViewData
        self.setupScreenViewData = setupScreenViewData
        self.cameraOn = cameraOn
        self.microphoneOn = microphoneOn
        self.skipSetupScreen = skipSetupScreen
        self.avMode = avMode
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
