//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import Combine

/// User-configurable view data to customize the InfoHeader of CallScreen.
public class CallScreenHeaderViewData: ObservableObject {
    /// Title replaces the default header message in the InfoHeader with a user injected custom title message.
    /// The title message is updatable even after launching the composite.
    @Published public var title: String?
    /// Subtitle is the header message in the InfoHeader with a user injected custom subtitle message.
    /// The subtitle message is updatable even after launching the composite.
    @Published public var subtitle: String?

    /* <CALL_SCREEN_HEADER_CUSTOM_BUTTONS:0> */
    /// Custom buttons.
    public let customButtons: [CustomButtonViewData]
    /* </CALL_SCREEN_HEADER_CUSTOM_BUTTONS> */

    /// Creates an instance of CallScreenHeaderViewData with related options.
    /// - Parameter title: A string which replaces the default header message in the
    ///                    InfoHeader with a user injected custom title message.
    /// - Parameter subtitle: A string message the is viewed below the title message in the
    ///                    InfoHeader.
    /// - Parameter customButtons: An array of custom button options. Default is an empty array.
    public init(title: String? = nil,
                subtitle: String? = nil
                /* <CALL_SCREEN_HEADER_CUSTOM_BUTTONS:0> */
                ,
                customButtons: [CustomButtonViewData] = []
                /* </CALL_SCREEN_HEADER_CUSTOM_BUTTONS> */
    ) {
        self.title = title
        self.subtitle = subtitle
        /* <CALL_SCREEN_HEADER_CUSTOM_BUTTONS:0> */
        self.customButtons = customButtons
        /* </CALL_SCREEN_HEADER_CUSTOM_BUTTONS> */
    }
}
