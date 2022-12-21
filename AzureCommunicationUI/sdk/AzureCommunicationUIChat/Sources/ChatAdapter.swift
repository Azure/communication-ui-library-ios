//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import AzureCommunicationCommon
import FluentUI
import SwiftUI
import UIKit

/// The main class representing the entry point for the Chat Composite.
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

    private var threadId: String = ""
    /// Create an instance of ChatComposite with options.
    public init(identifier: CommunicationIdentifier,
                credential: CommunicationTokenCredential,
                threadId: String,
                endpoint: String,
                displayName: String? = nil) {
        localizationProvider = LocalizationProvider(logger: logger)

        self.chatConfiguration = ChatConfiguration(
            identifier: identifier,
            credential: credential,
            endpoint: endpoint,
            displayName: displayName)
        self.events = Events()
        self.threadId = threadId
    }

    deinit {
        logger.debug("Composite deallocated")
    }

    /// Start connection to the chat composite to Azure Communication Service.
    public func connect(completionHandler: ((Result<Void, ChatCompositeError>) -> Void)?) {
        constructDependencies(
            chatConfiguration: self.chatConfiguration,
            chatThreadId: threadId,
            chatCompositeEventsHandler: events,
            connectEventHandler: completionHandler
        )
        compositeManager?.start()
    }

    /// Start connection to the chat composite to Azure Communication Service.
    public func connect() async throws {
        return try await withCheckedThrowingContinuation { continuation in
            connect() { result in
                continuation.resume(with: result)
            }
        }
    }

    /// Stop connection to chat composite to Azure Communication Service
    public func disconnect(completionHandler: @escaping ((Result<Void, ChatCompositeError>) -> Void)) {
        compositeManager?.stop(completionHandler: completionHandler)
    }

    /// Stop connection to chat composite to Azure Communication Service
    /// unsubscribe from the chat client
    /// inside the callback developers should clean up the adapter.dispose
    public func disconnect() async throws {
        return try await withCheckedThrowingContinuation { continuation in
            compositeManager?.stop(completionHandler: { result in
                continuation.resume(with: result)
            })
        }
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
