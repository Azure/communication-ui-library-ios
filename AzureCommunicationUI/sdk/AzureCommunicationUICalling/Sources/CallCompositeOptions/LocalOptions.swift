//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import UIKit

/// Encapsulates local configuration options for a Call Composite.
public struct LocalOptions {
    /// Configuration data for the local participant's view, such as avatar image and display name.
    let participantViewData: ParticipantViewData?

    /// Configuration for the call setup screen, including titles and subtitles.
    let setupScreenViewData: SetupScreenViewData?

    /// Determines if the microphone is enabled upon joining the call, bypassing the setup screen.
    let microphoneOn: Bool?

    /// Indicates whether to skip the setup screen and use default or specified settings.
    let skipSetupScreen: Bool?

    /// Specifies the audio/video mode for the call, affecting available functionalities.
    let avMode: CallCompositeAudioVideoMode

    /// Internal storage for the camera state, not directly exposed to the initializer.
    private let cameraOnInternal: Bool?

    /// Initializes a `LocalOptions` instance with specified configurations for call setup.
    ///
    /// - Parameters:
    ///   - participantViewData: Configuration for the local participant's view.
    ///   - setupScreenViewData: Configuration for the setup screen appearance.
    ///   - cameraOn: Determines if the camera is enabled by default.
    ///   - microphoneOn: Determines if the microphone is enabled by default.
    ///   - skipSetupScreen: Indicates whether to bypass the setup screen.
    ///   - avMode: The desired audio/video mode for the call.
    public init(participantViewData: ParticipantViewData? = nil,
                setupScreenViewData: SetupScreenViewData? = nil,
                cameraOn: Bool? = false,
                microphoneOn: Bool? = false,
                skipSetupScreen: Bool? = false,
                avMode: CallCompositeAudioVideoMode = .audioAndVideo) {
        self.participantViewData = participantViewData
        self.setupScreenViewData = setupScreenViewData
        self.cameraOnInternal = cameraOn
        self.microphoneOn = microphoneOn
        self.skipSetupScreen = skipSetupScreen
        self.avMode = avMode
    }

    /// Determines the actual state of the camera, considering both the `cameraOnInternal` flag and the `avMode`.
    var cameraOn: Bool {
        guard avMode != .audioOnly else {
            return false
        }
        return cameraOnInternal ?? false
    }
}

/// Represents configuration data for displaying a participant in the call composite.
public struct ParticipantViewData {
    /// The participant's avatar image. If nil, a default avatar is used.
    let avatarImage: UIImage?

    /// The display name for the participant. If nil, a display name from the call options is used.
    let displayName: String?

    /// Initializes a `ParticipantViewData` instance.
    ///
    /// - Parameters:
    ///   - avatar: Custom image for the participant's avatar.
    ///   - displayName: Custom display name for the participant.
    public init(avatar: UIImage? = nil,
                displayName: String? = nil) {
        self.avatarImage = avatar
        self.displayName = displayName
    }
}

/// Contains configuration for customizing the call setup screen's appearance.
public struct SetupScreenViewData {
    /// The title for the setup screen's navigation bar.
    let title: String

    /// An optional subtitle for additional context or instructions.
    let subtitle: String?

    /// Initializes a `SetupScreenViewData` instance.
    ///
    /// - Parameters:
    ///   - title: Title for the setup screen.
    ///   - subtitle: Optional subtitle for additional details.
    public init(title: String,
                subtitle: String? = nil) {
        self.title = title
        self.subtitle = subtitle
    }
}
