//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

class SupportFormViewModel: ObservableObject {
    // Published properties that the view can observe
    @Published var messageText: String = ""
    @Published var submitOnDismiss: Bool = false
    @Published var blockSubmission: Bool = true

    // Strings
    @Published var reportIssueTitle: String
    @Published var logsAttachNotice: String
    @Published var privacyPolicyText: String
    @Published var describeYourIssueHintText: String
    @Published var cancelButtonText: String
    @Published var reportAProblemText: String
    @Published var sendFeedbackText: String

    let dispatchAction: ActionDispatch

    var isSubmitButtonDisabled: Bool {
        messageText.isEmpty
    }

    let events: CallComposite.Events
    let getDebugInfo: () -> DebugInfo

    init(dispatchAction: @escaping ActionDispatch,
         events: CallComposite.Events,
         localizationProvider: LocalizationProviderProtocol,
         getDebugInfo: @escaping () -> DebugInfo) {
        self.events = events
        self.getDebugInfo = getDebugInfo
        self.dispatchAction = dispatchAction
        reportIssueTitle = localizationProvider.getLocalizedString(.supportFormReportIssueTitle)
        logsAttachNotice = localizationProvider.getLocalizedString(.supportFormLogsAttachNotice)
        privacyPolicyText = localizationProvider.getLocalizedString(.supportFormPrivacyPolicyText)
        describeYourIssueHintText = localizationProvider.getLocalizedString(.supportFormDescribeYourIssueHintText)
        cancelButtonText = localizationProvider.getLocalizedString(.supportFormCancelButtonText)
        reportAProblemText = localizationProvider.getLocalizedString(.supportFormReportAProblemText)
        sendFeedbackText = localizationProvider.getLocalizedString(.supportFormSendFeedbackText)
    }

    // Function to handle the send action
    func sendReport() {
        guard let callback = events.onUserReportedIssue else {
            return
        }
        callback(CallCompositeUserReportedIssue(userMessage: self.messageText,
                                                debugInfo: self.getDebugInfo()))
        messageText = ""
        dispatchAction(.hideSupportForm)
    }

    func hideForm() {
        dispatchAction(.hideSupportForm)
    }
}
