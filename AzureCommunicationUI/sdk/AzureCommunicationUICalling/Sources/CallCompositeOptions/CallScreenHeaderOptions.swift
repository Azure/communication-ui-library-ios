/* <TIMER_TITLE_FEATURE> */
//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import Combine

/// User-configurable options to customize the InfoHeader of CallScreen.
public class CallScreenHeaderOptions: ObservableObject {
    /// Title replaces the default information header message in the InfoHeader 
    /// with a user injected custom title message.
    /// The title message can be updated anytime after launching the composite as well.
    @Published public var title: String?
    /// Subtitle is the message in the InfoHeader with a user injected custom subtitle message.
    /// The subtitle message can be updated anytime after launching the composite as well.
    @Published public var subtitle: String?
    /// Creates an instance of CallScreenHeaderOptions with related options.
    /// - Parameter title: A string which replaces the default header message in the
    ///                    InfoHeader with a user injected custom title message.
    /// - Parameter subtitle: A string which is viewed under the title message.
    public init(title: String? = nil,
                subtitle: String? = nil) {
        self.title = title
        self.subtitle = subtitle
    }
}
/* </TIMER_TITLE_FEATURE> */
