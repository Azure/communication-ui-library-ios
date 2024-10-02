//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

/// User-configurable options for creating CallScreen.
public struct CallScreenOptions {
    /// CallScreenControlBarOptions for specifying CallScreenControlBar customization.
    public let controlBarOptions: CallScreenControlBarOptions?
    /// CallScreenHeaderViewData for customizing the InfoHeader title and call timer.
    public let headerViewData: CallScreenHeaderViewData?

    /// Creates an instance of CallScreenOptions with related options.
    /// - Parameter controlBarOptions: CallScreenControlBarOptions for specifying CallScreenControlBar customization.
    /// - Parameter headerOptions: CallScreenHeaderViewData for customizing the InfoHeader title and call timer.
    public init(controlBarOptions: CallScreenControlBarOptions? = nil,
                headerViewData: CallScreenHeaderViewData? = nil) {
        self.controlBarOptions = controlBarOptions
        self.headerViewData = headerViewData
    }
}
