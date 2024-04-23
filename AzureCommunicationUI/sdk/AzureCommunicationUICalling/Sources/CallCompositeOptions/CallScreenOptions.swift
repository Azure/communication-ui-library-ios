//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

/// User-configurable options for creating CallScreen.
public struct CallScreenOptions {
    /// CallScreenControlBarOptions for specifying CallScreenControlBar customization.
    let controlBarOptions: CallScreenControlBarOptions?

    /// Creates an instance of CallScreenOptions with related options.
    /// - Parameter controlBarOptions: CallScreenControlBarOptions for specifying CallScreenControlBar customization.
    public init(controlBarOptions: CallScreenControlBarOptions? = nil) {
        self.controlBarOptions = controlBarOptions
    }
}
