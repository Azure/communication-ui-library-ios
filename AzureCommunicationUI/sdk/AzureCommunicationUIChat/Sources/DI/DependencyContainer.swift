//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import AzureCommunicationCommon

final class DependencyContainer {

    // Dependencies, retaining type information
    var logger: Logger
    var accessibilityProvider: AccessibilityProviderProtocol
    var localizationProvider: LocalizationProviderProtocol

    var errorManager: ErrorManagerProtocol?
    var lifecycleManager: LifeCycleManagerProtocol?
    var compositeManager: CompositeManagerProtocol?
    var navigationRouter: NavigationRouter?
    var compositeViewFactory: CompositeViewFactoryProtocol?

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

        let chatSdk = ChatSDKWrapper(
            logger: logger,
            chatEventsHandler: eventHandler,
            chatConfiguration: chatConfiguration
        )

        let repositoryManager = MessageRepositoryManager(
            chatCompositeEventsHandler: chatCompositeEventsHandler
        )

        let store = makeStore(
            chatService: ChatService(
                logger: logger,
                chatSDKWrapper: chatSdk
            ),
            messageRepository: repositoryManager,
            chatConfiguration: chatConfiguration,
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
