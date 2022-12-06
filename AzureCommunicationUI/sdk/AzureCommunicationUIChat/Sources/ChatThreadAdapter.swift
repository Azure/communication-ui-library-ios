//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

public class ChatThreadAdapter {

    let client: ChatUIClient
    var logger: Logger
    public private(set) var threadId: String
    public private(set) var topic: String

    var navigationRouter: NavigationRouter?
    var compositeViewFactory: CompositeViewFactoryProtocol?

    private var chatConfiguration: ChatConfiguration
    private var errorManager: ErrorManagerProtocol?
    private var lifeCycleManager: LifeCycleManagerProtocol?
    private var compositeManager: CompositeManagerProtocol?

    public init(chatUIClient: ChatUIClient,
                threadId: String) {
        self.client = chatUIClient
        self.chatConfiguration = chatUIClient.chatConfiguration
        self.chatConfiguration.chatThreadId = threadId
        self.logger = chatUIClient.logger
        self.threadId = threadId
        self.topic = "topic placeholder"

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
            chatCompositeEventsHandler: client.events
        )

        let store = Store.constructStore(
            logger: logger,
            chatService: ChatService(
                logger: logger,
                chatSDKWrapper: chatSdk
            ),
            messageRepository: repositoryManager,
            chatConfiguration: chatConfiguration) { _ in
                print("completionHandler called")
        }

        self.navigationRouter = NavigationRouter(
            store: store,
            logger: logger,
            chatCompositeEventsHandler: client.events
        )

        self.compositeViewFactory = CompositeViewFactory(
            logger: logger,
            compositeViewModelFactory: CompositeViewModelFactory(
                logger: logger,
                localizationProvider: client.localizationProvider,
                accessibilityProvider: client.accessibilityProvider,
                messageRepositoryManager: repositoryManager,
                store: store
            )
        )

        self.errorManager = ErrorManager(
            store: store,
            chatCompositeEventsHandler: client.events
        )

        self.lifeCycleManager = UIKitAppLifeCycleManager(
            store: store,
            logger: logger
        )
        self.compositeManager = CompositeManager(
            store: store,
            logger: logger
        )

        self.compositeManager?.start()
    }
}
