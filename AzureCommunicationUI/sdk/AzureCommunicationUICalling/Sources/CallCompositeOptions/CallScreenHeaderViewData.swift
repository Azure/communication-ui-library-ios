/* <TIMER_TITLE_FEATURE> */
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
    /// Creates an instance of CallScreenHeaderViewData with related options.
    /// - Parameter title: A string which replaces the default header message in the
    ///                    InfoHeader with a user injected custom title message.
    /// - Parameter subtitle: A string message the is viewed below the title message in the
///                        InfoHeader.
    public init(title: String? = nil,
                subtitle: String? = nil) {
        self.title = title
        self.subtitle = subtitle
    }
}
/* </TIMER_TITLE_FEATURE> */
