//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

class SupportFormViewModel: ObservableObject {
    // Published properties that the view can observe
    @Published var messageText: String = "Please describe your issue..."
    @Published var includeScreenshot: Bool = true
    let events: CallComposite.Events
    // Any additional properties your ViewModel needs

    init(events: CallComposite.Events) {
        self.events = events
    }

    // Function to handle the send action
    func sendReport() {
        print("SEND TEST" + messageText)
        guard let callback = events.onUserReportedIssue else {
            return
        }
        callback(CallCompositeUserReportedIssue(userMessage: messageText, logFiles: [], callIds: []))
    }

    // Any additional methods your ViewModel needs
}
