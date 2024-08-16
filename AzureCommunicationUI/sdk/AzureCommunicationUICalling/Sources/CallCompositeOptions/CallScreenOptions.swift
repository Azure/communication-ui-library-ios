//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

/// User-configurable options for creating CallScreen.
public struct CallScreenOptions {
    /// CallScreenControlBarOptions for specifying CallScreenControlBar customization.
    public let controlBarOptions: CallScreenControlBarOptions?
    /// CallScreenHeaderOptions for customizing the InfoHeader title and call timer.
    public let headerOptions: CallScreenHeaderOptions?

    /// Creates an instance of CallScreenOptions with related options.
    /// - Parameter controlBarOptions: CallScreenControlBarOptions for specifying CallScreenControlBar customization.
    /// - Parameter headerOptions: CallScreenHeaderOptions for customizing the InfoHeader title and call timer.
    public init(controlBarOptions: CallScreenControlBarOptions? = nil,
                headerOptions: CallScreenHeaderOptions? = nil) {
        self.controlBarOptions = controlBarOptions
        self.headerOptions = headerOptions
    }
}
