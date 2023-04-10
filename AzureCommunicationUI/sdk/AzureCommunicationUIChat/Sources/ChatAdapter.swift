//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import AzureCommunicationCommon

/// This class represents the data-layer components of the Chat Composite.
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
    var compositeViewFactory: CompositeViewFactoryProtocol?

    private var chatConfiguration: ChatConfiguration
    private var errorManager: ErrorManagerProtocol?
    private var lifeCycleManager: LifeCycleManagerProtocol?
    private var compositeManager: CompositeManagerProtocol?

    private var threadId: String = ""
    /// Create an instance of this class with options.
    /// - Parameters:
    ///    - endpoint: The endpoint URL of The Communication Services.
    ///    - identifier: The CommunicationIdentifier that uniquely identifies an user
    ///    - credential: The credential that authenticates the user to a chat thread
    ///    - threadId: The unique identifier of a chat thread
    ///    - displayName: The display name that would be used when sending a chat message
    ///                   If this is `nil` the display name defined when adding the user to
    ///                   chat thread from the service would be used
    public init(endpoint: String,
                identifier: CommunicationIdentifier,
                credential: CommunicationTokenCredential,
                threadId: String,
                displayName: String? = nil) {
        self.chatConfiguration = ChatConfiguration(
            endpoint: endpoint,
            identifier: identifier,
            credential: credential,
            displayName: displayName)
        self.events = Events()
        self.threadId = threadId
    }

    deinit {
        logger.debug("Composite deallocated")
    }

    /// Start connection with chat client and registers for chat events
    /// This function should be called before adding the ChatComposite to a view
    /// - Parameters:
    ///    - completionHandler: The closure that will be called back when connection is established
    public func connect(completionHandler: ((Result<Void, ChatCompositeError>) -> Void)?) {
        constructDependencies(
            chatConfiguration: self.chatConfiguration,
            chatThreadId: threadId,
            chatCompositeEventsHandler: events,
            connectEventHandler: completionHandler
        )
        compositeManager?.start()
    }

    /// Start connection with chat client and registers for chat events
    /// This function should be called before adding the Chat Composite to a view
    public func connect() async throws {
        return try await withCheckedThrowingContinuation { continuation in
            connect() { result in
                continuation.resume(with: result)
            }
        }
    }

    /// Unsubscribe all the chat client events from Azure Communication Service
    /// - Parameters:
    ///    - completionHandler: The closure that will be called back when disconnection is complete
    public func disconnect(completionHandler: @escaping ((Result<Void, ChatCompositeError>) -> Void)) {
        compositeManager?.stop(completionHandler: completionHandler)
    }

    /// Unsubscribe all the chat client events from Azure Communication Service
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

        let localizationProvider = LocalizationProvider(logger: logger)

        compositeViewFactory = CompositeViewFactory(
            logger: logger,
            compositeViewModelFactory: CompositeViewModelFactory(
                logger: logger,
                localizationProvider: localizationProvider,
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
}
