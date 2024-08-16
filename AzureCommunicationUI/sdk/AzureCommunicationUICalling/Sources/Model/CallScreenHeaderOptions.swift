//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

public class CallScreenHeaderOptions {
    public var timer: CallDurationTimer?
    public var title: String?
    /// Creates an instance of CallScreenHeaderOptions with related options.
    /// - Parameter timer: CallDurationTimer options to set the timer in the InfoHeader.
    /// - Parameter title: A String which replaces the default header message in the
    ///                    InfoHeader with a user injected custom title message.
    public init(timer: CallDurationTimer? = nil,
                title: String? = nil) {
        self.timer = timer
        self.title = title
    }
}
