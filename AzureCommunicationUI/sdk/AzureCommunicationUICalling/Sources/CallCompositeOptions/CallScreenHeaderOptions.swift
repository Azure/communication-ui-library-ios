/* <TIMER_TITLE_FEATURE> */
//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import Combine

/// User-configurable options to customize the InfoHeader of CallScreen.
public class CallScreenHeaderOptions: ObservableObject {
    /// Title replaces the default header message in the InfoHeader with a user injected custom title message.
    @Published public var title: String?
    /// Subtitle is the header message in the InfoHeader with a user injected custom subtitle message.
    @Published public var subtitle: String?
    /// Creates an instance of CallScreenHeaderOptions with related options.
    /// - Parameter timer: CallDurationTimer options to set the timer in the InfoHeader.
    /// - Parameter title: A String which replaces the default header message in the
    ///                    InfoHeader with a user injected custom title message.
    public init(title: String? = nil,
                subtitle: String? = nil) {
        self.title = title
        self.subtitle = subtitle
    }
}
/* </TIMER_TITLE_FEATURE> */
