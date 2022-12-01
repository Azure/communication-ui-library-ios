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

    @Published var isLocalUserRemoved: Bool = false
    @Published var message: String = "" {
        didSet {
            sendButtonViewModel.update(isDisabled: message.isEmptyOrWhiteSpace)
            sendButtonViewModel.update(iconName: message.isEmptyOrWhiteSpace ? .sendDisabled : .send)
            guard !message.isEmpty else {
                return
            }
            sendTypingIndicator()
        }
    }

    init(compositeViewModelFactory: CompositeViewModelFactory,
         logger: Logger,
         dispatch: @escaping ActionDispatch) {
        self.logger = logger
        self.dispatch = dispatch

        sendButtonViewModel = compositeViewModelFactory.makeIconButtonViewModel(
            iconName: .send,
            buttonType: .sendButton,
            isDisabled: true) { [weak self] in
                guard let self = self else {
                    return
                }
                self.sendMessage()
        }
//        sendButtonViewModel.update(
//            accessibilityLabel: self.localizationProvider.getLocalizedString(.sendAccessibilityLabel))
    }

    func sendMessage() {
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

    func update(chatState: ChatState) {
        guard isLocalUserRemoved != chatState.isLocalUserRemovedFromChat else {
            return
        }
        isLocalUserRemoved = chatState.isLocalUserRemovedFromChat
    }
}

extension String {
    var isEmptyOrWhiteSpace: Bool {
        return self.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}
