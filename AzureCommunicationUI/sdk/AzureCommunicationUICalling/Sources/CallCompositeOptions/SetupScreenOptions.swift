//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

/// User-configurable options for creating setup screen.
public struct SetupScreenOptions {
    private(set) var cameraButtonEnabled: Bool
    private(set) var microphoneButtonEnabled: Bool
    private(set) var cameraButton: ButtonViewData?
    private(set) var microphoneButton: ButtonViewData?
    private(set) var audioDeviceButton: ButtonViewData?

    /// Creates an instance of SetupScreenOptions with related options.
    /// - Parameter cameraButtonEnabled: enables camera button on the setup screen.
    /// - Parameter microphoneButtonEnabled: enables microphone button on the setup screen.
    @available(*, deprecated, message: "Use init with ButtonsOptions arguments.")
    public init(cameraButtonEnabled: Bool = true, microphoneButtonEnabled: Bool = true) {
        self.cameraButtonEnabled = cameraButtonEnabled
        self.microphoneButtonEnabled = microphoneButtonEnabled
        cameraButton = ButtonViewData(enabled: cameraButtonEnabled)
        microphoneButton = ButtonViewData(enabled: microphoneButtonEnabled)
    }
    /// Creates an instance of SetupScreenOptions with related options.
    /// - Parameter cameraButton: camera button options.
    /// - Parameter microphoneButton: microphone button options.
    /// - Parameter audioDeviceButton: audio device button options.
    public init(cameraButton: ButtonViewData? = nil,
                microphoneButton: ButtonViewData? = nil,
                audioDeviceButton: ButtonViewData? = nil) {
        self.cameraButtonEnabled = cameraButton?.enabled ?? true
        self.microphoneButtonEnabled = microphoneButton?.enabled ?? true
        self.cameraButton = cameraButton
        self.microphoneButton = microphoneButton
        self.audioDeviceButton = audioDeviceButton
    }
}
