//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

class SupportFormViewModel: ObservableObject {
    // Published properties that the view can observe
    @Published var messageText: String = ""
    @Published var includeScreenshot: Bool = true
    @Published var submitOnDismiss: Bool = false
    let events: CallComposite.Events
    let getDebugInfo: () -> DebugInfo

    init(events: CallComposite.Events, getDebugInfo: @escaping () -> DebugInfo) {
        self.events = events
        self.getDebugInfo = getDebugInfo
    }

    // Function to handle the send action
    func sendReport() {
        guard let callback = events.onUserReportedIssue else {
            return
        }
        var screenshotURL: URL?
        if includeScreenshot {
            if let screenshot = captureScreenshot() {
                screenshotURL = saveScreenshot(screenshot)
            }
        }
        callback(CallCompositeUserReportedIssue(userMessage: messageText,
                                                debugInfo: getDebugInfo(),
                                                screenshot: screenshotURL))
    }

    func prepareToSend() {
        submitOnDismiss = true
    }
}
