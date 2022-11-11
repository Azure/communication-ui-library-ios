//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

class BottomBarViewModel: ObservableObject {
    private let logger: Logger
    private let dispatch: ActionDispatch

    var sendButtonViewModel: IconButtonViewModel!

    // MARK: Typing Indicators
    private var lastTypingIndicatorSendTimestamp = Date()
    private let typingIndicatorDelay: TimeInterval = 8.0

    @Published var message: String = ""
    @Published var hasFocus: Bool = false

    init(compositeViewModelFactory: CompositeViewModelFactory,
         logger: Logger,
         dispatch: @escaping ActionDispatch) {
        self.logger = logger
        self.dispatch = dispatch

        sendButtonViewModel = compositeViewModelFactory.makeIconButtonViewModel(
            iconName: .send,
            buttonType: .sendButton,
            isDisabled: false) { [weak self] in
                guard let self = self else {
                    return
                }
                self.sendMessage()
        }
//        sendButtonViewModel.update(
//            accessibilityLabel: self.localizationProvider.getLocalizedString(.sendAccessibilityLabel))
    }

    func sendMessage() {
        hasFocus = true
        guard !message.isEmpty else {
            return
        }
        dispatch(.repositoryAction(.sendMessageTriggered(
            internalId: UUID().uuidString,
            content: message)))
        message = ""
    }

    func sendTypingIndicator() {
        if lastTypingIndicatorSendTimestamp < Date() - typingIndicatorDelay {
            dispatch(.chatAction(.sendTypingIndicatorTriggered))
            lastTypingIndicatorSendTimestamp = Date()
        }
    }
}
