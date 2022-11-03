//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

class MessageListViewModel: ObservableObject {
    private let messageRepositoryManager: MessageRepositoryManagerProtocol
    private let logger: Logger
    private let dispatch: ActionDispatch

    private var repositoryUpdatedTimestamp: Date = .distantPast
    private var localUserId: String? // Remove optional?
    private var lastReadMessageIndex: Int?

    var jumpToNewMessagesButtonViewModel: PrimaryButtonViewModel!

    @Published var messages: [ChatMessageInfoModel]
    @Published var haveInitialMessagesLoaded: Bool = false
    @Published var showJumpToNewMessages: Bool = false
    @Published var shouldScrollToBottom: Bool = false

    init(compositeViewModelFactory: CompositeViewModelFactoryProtocol,
         messageRepositoryManager: MessageRepositoryManagerProtocol,
         logger: Logger,
         dispatch: @escaping ActionDispatch,
         chatState: ChatState) {
        self.messageRepositoryManager = messageRepositoryManager
        self.logger = logger
        self.dispatch = dispatch

        self.localUserId = chatState.localUser?.id // Only take in local User ID?
        self.messages = messageRepositoryManager.messages

        jumpToNewMessagesButtonViewModel = compositeViewModelFactory.makePrimaryButtonViewModel(
            buttonStyle: .primaryFilled,
            buttonLabel: jumpToNewMessagesLabel,
            iconName: .downArrow,
            isDisabled: false) { [weak self] in
                guard let self = self else {
                    return
                }
                self.jumpToNewMessagesButtonTapped()
        }
//      .update(accessibilityLabel: self.localizationProvider.getLocalizedString(.jumpToNewMessages))
    }

    var numberOfNewMessages: Int {
        (messages.count - 1) - (lastReadMessageIndex ?? 0)
    }

    var jumpToNewMessagesLabel: String {
        numberOfNewMessages < 100
        ? "\(numberOfNewMessages) new messages"
        : "99+ new messages"
    }

    func jumpToNewMessagesButtonTapped() {
        shouldScrollToBottom = true
    }

    func fetchMessages() {
        dispatch(.repositoryAction(.fetchPreviousMessagesTriggered))
    }

    func update(repositoryState: RepositoryState) {
        if self.repositoryUpdatedTimestamp < repositoryState.lastUpdatedTimestamp {
            self.repositoryUpdatedTimestamp = repositoryState.lastUpdatedTimestamp
            messages = messageRepositoryManager.messages

            if !haveInitialMessagesLoaded && messages.count > 1 {
                shouldScrollToBottom = true
                haveInitialMessagesLoaded = true
            }

            if numberOfNewMessages > 0 {
                showJumpToNewMessages = true
            }

            jumpToNewMessagesButtonViewModel.update(buttonLabel: jumpToNewMessagesLabel)
        }
    }

    // Replace with factory
    func createViewModel(index: Int) -> MessageViewModel {
        let message = messages[index]
        let type = messages[index].type
        let lastMessageIndex = index == 0 ? 0 : index - 1
        let lastMessage = messages[lastMessageIndex]
        let showDateHeader = index == 0 || message.createdOn.dayOfYear - lastMessage.createdOn.dayOfYear > 0
        let isConsecutive = message.senderId == lastMessage.senderId

        switch type {
        case .text:
            let isLocalUser = isLocalUser(message: message)
            let showUsername = !isLocalUser && !isConsecutive
            let showTime = !isConsecutive

            return TextMessageViewModel(message: message,
                                        showDateHeader: showDateHeader,
                                        showUsername: showUsername,
                                        showTime: showTime,
                                        isLocalUser: isLocalUser,
                                        isConsecutive: isConsecutive)
        case .participantsAdded, .participantsRemoved, .topicUpdated:
            return SystemMessageViewModel(message: message,
                                          showDateHeader: showDateHeader,
                                          isConsecutive: false)
        case .html:
            return HtmlMessageViewModel(message: message, showDateHeader: showDateHeader, isConsecutive: isConsecutive)
        case .custom(_): // Stub until finished
            return SystemMessageViewModel(message: message,
                                          showDateHeader: showDateHeader,
                                          isConsecutive: isConsecutive)
        }
    }

    // Move the message repo?
    func isLocalUser(message: ChatMessageInfoModel?) -> Bool {
        guard message != nil else {
            return false
        }
        return message!.senderId == localUserId
    }
}
