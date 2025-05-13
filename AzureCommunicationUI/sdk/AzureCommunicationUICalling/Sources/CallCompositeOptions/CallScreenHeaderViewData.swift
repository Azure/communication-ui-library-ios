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
    /// ShowCallDuration is for the InfoHeader with a user injected custom signal for the UI to show call time.
    /// The call duration show signal is not updatable after launching the composite.
    @Published public var showCallDuration: Bool?

    /// Custom buttons.
    public let customButtons: [CustomButtonViewData]

    /// Creates an instance of CallScreenHeaderViewData with related options.
    /// - Parameter title: A string which replaces the default header message in the
    ///                    InfoHeader with a user injected custom title message.
    /// - Parameter subtitle: A string message the is viewed below the title message in the
    ///                    InfoHeader.
    /// - Parameter customButtons: An array of custom button options. Default is an empty array.
    public init(title: String? = nil,
                subtitle: String? = nil,
                showCallDuration: Bool? = nil,
                customButtons: [CustomButtonViewData] = []
    ) {
        self.title = title
        self.subtitle = subtitle
        self.showCallDuration = showCallDuration
        self.customButtons = customButtons
    }
}
