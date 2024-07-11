//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

/// User-configurable options for creating setup screen.
public struct SetupScreenOptions {
    private(set) var cameraButtonEnabled: Bool
    private(set) var microphoneButtonEnabled: Bool

    private(set) var cameraButton: ButtonOptions?
    private(set) var microphoneButton: ButtonOptions?

    /// Creates an instance of SetupScreenOptions with related options.
    /// - Parameter cameraButtonEnabled: enables camera button on the setup screen.
    /// - Parameter microphoneButtonEnabled: enables microphone button on the setup screen.
    @available(*, deprecated, message: "Use init with ButtonsOptions arguments.")
    public init(cameraButtonEnabled: Bool = true, microphoneButtonEnabled: Bool = true) {
        self.cameraButtonEnabled = cameraButtonEnabled
        self.microphoneButtonEnabled = microphoneButtonEnabled
        self.cameraButton = nil
        self.microphoneButton = nil
    }

    /// Creates an instance of SetupScreenOptions with related options.
    /// - Parameter cameraButton: camera button options.
    /// - Parameter microphoneButton: microphone button options.
    public init(cameraButton: ButtonOptions? = nil, microphoneButton: ButtonOptions? = nil) {
        self.cameraButtonEnabled = true
        self.microphoneButtonEnabled = true
        self.cameraButton = cameraButton
        self.microphoneButton = microphoneButton
    }
}
