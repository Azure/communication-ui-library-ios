//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

/// User-configurable options for creating setup screen.
public struct SetupScreenOptions {
    private(set) var cameraButtonEnabled: Bool
    private(set) var microphoneButtonEnabled: Bool

    /// Creates an instance of SetupScreenOptions with related options.
    /// - Parameter cameraButtonEnabled: enables camera button on the setup screen.
    /// - Parameter microphoneButtonEnabled: enables microphone button on the setup screen.
    public init(cameraButtonEnabled: Bool = true, microphoneButtonEnabled: Bool = true) {
        self.cameraButtonEnabled = cameraButtonEnabled
        self.microphoneButtonEnabled = microphoneButtonEnabled
    }
}
