//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

internal class SupportFormViewModel: ObservableObject {
    @Published var isDisplayed = false
    @Published var submitOnDismiss = false
    @Published var blockSubmission = true

    // Strings
    @Published var reportIssueTitle: String
    @Published var logsAttachNotice: String
    @Published var privacyPolicyText: String
    @Published var describeYourIssueHintText: String
    @Published var cancelButtonText: String
    @Published var reportAProblemText: String
    @Published var sendFeedbackText: String

    let dispatchAction: ActionDispatch
    let events: CallComposite.Events
    let getDebugInfo: () -> DebugInfo

    init(isDisplayed: Bool,
         dispatchAction: @escaping ActionDispatch,
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

    func update(state: AppState) {
        isDisplayed = state.navigationState.supportFormVisible
            && state.visibilityState.currentStatus == .visible
    }

    // Published properties that the view can observe
    private var _messageText: String = "" {
        willSet {
            objectWillChange.send()
        }
        didSet {
            blockSubmission = _messageText.isEmpty
        }
    }

    // Public facing property to get and set the message text
    var messageText: String {
        get { _messageText }
        set { _messageText = newValue }
    }

    var isSubmitButtonDisabled: Bool {
        messageText.isEmpty
    }

    // Function to handle the send action
    func sendReport() {
        guard let callback = events.onUserReportedIssue else {
            return
        }
        callback(CallCompositeUserReportedIssue(userMessage: self.messageText,
                                                debugInfo: self.getDebugInfo()))
        messageText = ""
        dispatchAction(.hideDrawer)
    }

    func hideForm() {
        dispatchAction(.hideDrawer)
    }
}

extension SupportFormViewModel: Equatable {
    static func == (lhs: SupportFormViewModel, rhs: SupportFormViewModel) -> Bool {
        // Compare value types only, excluding closures and events
        return lhs.submitOnDismiss == rhs.submitOnDismiss &&
        lhs.blockSubmission == rhs.blockSubmission &&
        lhs.reportIssueTitle == rhs.reportIssueTitle &&
        lhs.logsAttachNotice == rhs.logsAttachNotice &&
        lhs.privacyPolicyText == rhs.privacyPolicyText &&
        lhs.describeYourIssueHintText == rhs.describeYourIssueHintText &&
        lhs.cancelButtonText == rhs.cancelButtonText &&
        lhs.reportAProblemText == rhs.reportAProblemText &&
        lhs.sendFeedbackText == rhs.sendFeedbackText &&
        lhs.messageText == rhs.messageText
    }
}
