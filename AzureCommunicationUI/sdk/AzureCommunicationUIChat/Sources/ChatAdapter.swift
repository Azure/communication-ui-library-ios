//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import AzureCommunicationCommon
import FluentUI
import SwiftUI
import UIKit

/// This class contains the data-layer components of the Chat Composite.
public class ChatAdapter {

    /// The class to configure events closures for Chat Composite.
    public class Events {
        /// Closure to execute when error event occurs inside Chat Composite.
        public var onError: ((ChatCompositeError) -> Void)?
        /// Closures to execute when participant has joined a chat inside Chat Composite.
        var onRemoteParticipantJoined: (([CommunicationIdentifier]) -> Void)?
        /// Closure to execute when Chat Composite UI is hidden and receive new message
        var onUnreadMessagesCountChanged: ((Int) -> Void)?
        /// Closure to execute when Chat Composite UI is hidden and receive new message
        var onNewMessageReceived: ((ChatMessageModel) -> Void)?
    }

    /// The events handler for Chat Composite
    public let events: Events

    // Dependencies
    var logger: Logger = DefaultLogger(category: "ChatComponent")
    var accessibilityProvider: AccessibilityProviderProtocol = AccessibilityProvider()
    var localizationProvider: LocalizationProviderProtocol
    var navigationRouter: NavigationRouter?
    var compositeViewFactory: CompositeViewFactoryProtocol?

    private var chatConfiguration: ChatConfiguration
    private var errorManager: ErrorManagerProtocol?
    private var lifeCycleManager: LifeCycleManagerProtocol?
    private var compositeManager: CompositeManagerProtocol?

    private var themeOptions: ThemeOptions?

    /// Create an instance of this class with options.
    public init(identifier: CommunicationIdentifier,
                credential: CommunicationTokenCredential,
                endpoint: String,
                displayName: String? = nil) {
        localizationProvider = LocalizationProvider(logger: logger)

        self.chatConfiguration = ChatConfiguration(
            identifier: identifier,
            credential: credential,
            endpoint: endpoint,
            displayName: displayName)
        self.events = Events()
    }

    deinit {
        logger.debug("Composite deallocated")
    }

    /// Start connection to the chat composite to Azure Communication Service.
    public func connect(threadId: String,
                        completionHandler: ((Result<Void, ChatCompositeError>) -> Void)?) {
        constructDependencies(
            chatConfiguration: self.chatConfiguration,
            chatThreadId: threadId,
            chatCompositeEventsHandler: events,
            connectEventHandler: completionHandler
        )
        compositeManager?.start()
    }

    /// Start connection to the chat composite to Azure Communication Service.
    public func connect(threadId: String) async throws {
        return try await withCheckedThrowingContinuation { continuation in
            connect(threadId: threadId) { result in
                continuation.resume(with: result)
            }
        }
    }

    /// Stop connection to chat composite to Azure Communication Service
    public func disconnect() {
//    public func disconnect(threadId: String? = nil
//                           completionHandler: ((Result<Void, ChatCompositeError>) -> Void)? = nil) {

    }

    private func constructDependencies(
        chatConfiguration: ChatConfiguration,
        chatThreadId: String,
        chatCompositeEventsHandler: ChatAdapter.Events,
        connectEventHandler: ((Result<Void, ChatCompositeError>) -> Void)? = nil
    ) {
        let eventHandler = ChatSDKEventsHandler(
            logger: logger,
            threadId: chatThreadId,
            localUserId: chatConfiguration.identifier
        )

        let chatSdk = ChatSDKWrapper(
            logger: logger,
            chatEventsHandler: eventHandler,
            chatConfiguration: chatConfiguration,
            chatThreadId: chatThreadId
        )

        let repositoryManager = MessageRepositoryManager(
            chatCompositeEventsHandler: chatCompositeEventsHandler
        )

        let store = Store.constructStore(
            logger: logger,
            chatService: ChatService(
                logger: logger,
                chatSDKWrapper: chatSdk
            ),
            messageRepository: repositoryManager,
            chatConfiguration: chatConfiguration,
            chatThreadId: chatThreadId,
            connectEventHandler: connectEventHandler
        )

        navigationRouter = NavigationRouter(
            store: store,
            logger: logger,
            chatCompositeEventsHandler: chatCompositeEventsHandler
        )

        compositeViewFactory = CompositeViewFactory(
            logger: logger,
            compositeViewModelFactory: CompositeViewModelFactory(
                logger: logger,
                localizationProvider: localizationProvider,
                accessibilityProvider: accessibilityProvider,
                messageRepositoryManager: repositoryManager,
                store: store
            )
        )

        errorManager = ErrorManager(
            store: store,
            chatCompositeEventsHandler: chatCompositeEventsHandler
        )

        lifeCycleManager = UIKitAppLifeCycleManager(
            store: store,
            logger: logger
        )
        compositeManager = CompositeManager(
            store: store,
            logger: logger
        )
    }

    private func cleanUpComposite() {
        self.errorManager = nil
        self.lifeCycleManager = nil
    }

    func makeContainerUIHostingController(router: NavigationRouter,
                                          logger: Logger,
                                          viewFactory: CompositeViewFactoryProtocol,
                                          isRightToLeft: Bool,
                                          canDismiss: Bool) -> ContainerUIHostingController {
        let rootView = ContainerView(router: router,
                                     logger: logger,
                                     viewFactory: viewFactory,
                                     isRightToLeft: isRightToLeft)
        let containerUIHostingController = ContainerUIHostingController(rootView: rootView,
                                                                        chatAdapter: self,
                                                                        isRightToLeft: isRightToLeft)
        containerUIHostingController.modalPresentationStyle = .fullScreen

        return containerUIHostingController
    }
}
