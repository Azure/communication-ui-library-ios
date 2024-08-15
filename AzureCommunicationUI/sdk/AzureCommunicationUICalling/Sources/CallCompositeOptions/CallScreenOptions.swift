//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

/// User-configurable options for creating CallScreen.
public struct CallScreenOptions {
    /// CallScreenControlBarOptions for specifying CallScreenControlBar customization.
    public let controlBarOptions: CallScreenControlBarOptions?
    public let callScreenHeaderOptions: CallScreenHeaderOptions?

    /// Creates an instance of CallScreenOptions with related options.
    /// - Parameter controlBarOptions: CallScreenControlBarOptions for specifying CallScreenControlBar customization.
    public init(controlBarOptions: CallScreenControlBarOptions? = nil,
                callScreenHeaderOptions: CallScreenHeaderOptions? = nil) {
        self.controlBarOptions = controlBarOptions
        self.callScreenHeaderOptions = callScreenHeaderOptions
    }
}
