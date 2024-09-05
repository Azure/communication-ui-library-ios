//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

/// User-configurable options for creating CallScreen.
public struct CallScreenOptions {
    /// CallScreenControlBarOptions for specifying CallScreenControlBar customization.
    public let controlBarOptions: CallScreenControlBarOptions?
    /* <TIMER_TITLE_FEATURE> */
    /// CallScreenHeaderViewData for customizing the InfoHeader title and call timer.
    public let headerViewData: CallScreenHeaderViewData?
    /* </TIMER_TITLE_FEATURE> */

    /// Creates an instance of CallScreenOptions with related options.
    /// - Parameter controlBarOptions: CallScreenControlBarOptions for specifying CallScreenControlBar customization.
    /// - Parameter headerOptions: CallScreenHeaderViewData for customizing the InfoHeader title and call timer.
    public init(controlBarOptions: CallScreenControlBarOptions? = nil
                /* <TIMER_TITLE_FEATURE> */
                ,
                headerViewData: CallScreenHeaderViewData? = nil
                /* </TIMER_TITLE_FEATURE> */
                ) {
        self.controlBarOptions = controlBarOptions
        /* <TIMER_TITLE_FEATURE> */
        self.headerViewData = headerViewData
        /* </TIMER_TITLE_FEATURE> */
    }
}
