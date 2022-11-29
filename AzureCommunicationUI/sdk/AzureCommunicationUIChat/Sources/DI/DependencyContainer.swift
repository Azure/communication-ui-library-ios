//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import AzureCommunicationCommon

final class DependencyContainer {

    // Dependencies, retaining type information
    var logger: Logger
    var errorManager: ErrorManagerProtocol?
    var lifecycleManager: LifeCycleManagerProtocol?
    var compositeManager: CompositeManagerProtocol?
    var navigationRouter: NavigationRouter?

    var accessibilityProvider: AccessibilityProviderProtocol
    var localizationProvider: LocalizationProviderProtocol
    var compositeViewFactory: CompositeViewFactoryProtocol?

    // Internal dependencies? Do we need these?
    private var chatSdkEventHandler: ChatSDKEventsHandling?
    private var chatSdkWrapper: ChatSDKWrapperProtocol?
    private var chatService: ChatServiceProtocol?
    private var messageRepositoryManager: MessageRepositoryManagerProtocol?
    private var store: Store<AppState>?
    private var compositeViewModelFactory: CompositeViewModelFactoryProtocol?

    init() {
        logger = DefaultLogger(category: "ChatComponent")
        accessibilityProvider = AccessibilityProvider()
        localizationProvider = LocalizationProvider(logger: logger)
    }

    func registerDependencies(
        _ chatConfiguration: ChatConfiguration,
        chatCompositeEventsHandler: ChatAdapter.Events,
        connectEventHandler: ((Result<Void, ChatCompositeError>) -> Void)? = nil
    ) {
        let eventHandler = ChatSDKEventsHandler(
            logger: logger,
            threadId: chatConfiguration.chatThreadId,
            localUserId: chatConfiguration.identifier
        )
        chatSdkEventHandler = eventHandler

        let chatSdk = ChatSDKWrapper(
            logger: logger,
            chatEventsHandler: eventHandler,
            chatConfiguration: chatConfiguration
        )
        chatSdkWrapper = chatSdk

        let chatService = ChatService(
            logger: logger,
            chatSDKWrapper: chatSdk
        )
        self.chatService = chatService

        let repositoryManager = MessageRepositoryManager(
            chatCompositeEventsHandler: chatCompositeEventsHandler
        )
        messageRepositoryManager = repositoryManager

        let store = makeStore(
            chatService: chatService,
            messageRepository: repositoryManager,
            chatConfiguration: chatConfiguration,
            connectEventHandler: connectEventHandler
        )
        self.store = store

        navigationRouter = NavigationRouter(
            store: store,
            logger: logger,
            chatCompositeEventsHandler: chatCompositeEventsHandler
        )

        let compositeViewModelFactory = CompositeViewModelFactory(
            logger: logger,
            localizationProvider: localizationProvider,
            accessibilityProvider: accessibilityProvider,
            messageRepositoryManager: repositoryManager,
            store: store
        )
        self.compositeViewModelFactory = compositeViewModelFactory

        compositeViewFactory = CompositeViewFactory(
            logger: logger,
            compositeViewModelFactory: compositeViewModelFactory
        )

        let errorManager = ErrorManager(
            store: store,
            chatCompositeEventsHandler: chatCompositeEventsHandler
        )
        self.errorManager = errorManager

        lifecycleManager = UIKitAppLifeCycleManager(
            store: store,
            logger: logger
        )
        compositeManager = CompositeManager(
            store: store,
            logger: logger
        )
    }

    private func makeStore(
        chatService: ChatServiceProtocol,
        messageRepository: MessageRepositoryManagerProtocol,
        chatConfiguration: ChatConfiguration,
        connectEventHandler: ((Result<Void, ChatCompositeError>) -> Void)?
    ) -> Store<AppState> {

        let middlewares: [Middleware] = [
            Middleware<AppState>.liveChatMiddleware(
                chatActionHandler: ChatActionHandler(
                    chatService: chatService,
                    logger: logger,
                    connectEventHandler: connectEventHandler
                ),
                chatServiceEventHandler: ChatServiceEventHandler(
                    chatService: chatService, logger: logger
                )
            ),
            Middleware<AppState>.liveRepositoryMiddleware(
                repositoryMiddlewareHandler: RepositoryMiddlewareHandler(
                    messageRepository: messageRepository,
                    logger: logger
                )
            )
        ]

        return Store<AppState>(
            reducer: Reducer<AppState, Action>.appStateReducer(),
            middlewares: middlewares,
            state: AppState(
                chatState: ChatState(
                    localUser: ParticipantInfoModel(
                        identifier: chatConfiguration.identifier,
                        displayName: chatConfiguration.displayName ?? "",
                        isLocalParticipant: true
                    ),
                    threadId: chatConfiguration.chatThreadId
                )
            )
        )
    }
}
