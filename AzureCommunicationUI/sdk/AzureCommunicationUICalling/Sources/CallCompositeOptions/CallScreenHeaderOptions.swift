/* <TIMER_TITLE_FEATURE>
//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

/// User-configurable options to customize the InfoHeader of CallScreen.
public class CallScreenHeaderOptions {
    /// CallDurationTimer has the information of elapsed duration after timer starts and
    /// also lets the user to set elapsed duration.
    public let timer: CallDurationTimer?
    let title: String?
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
</TIMER_TITLE_FEATURE> */
