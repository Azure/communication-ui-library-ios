//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import AzureCommunicationCommon

final class DependencyContainer {
    private var dependencies = [String: AnyObject]()

    init() {
        registerDefaultDependencies()
    }

    func register<T>(_ dependency: T) {
        let key = String(describing: T.self)
        dependencies[key] = dependency as AnyObject
    }

    func resolve<T>() -> T {
        let key = String(describing: T.self)
        let dependency = dependencies[key] as? T

        precondition(dependency != nil, "No dependency found for \(key)! must register a dependency before resolve.")

        return dependency!
    }

    private func registerDefaultDependencies() {
        register(DefaultLogger() as Logger)
    }

    func registerDependencies(_ chatConfiguration: ChatConfiguration,
                              localOptions: LocalOptions?,
                              chatCompositeEventsHandler: ChatComposite.Events) {
        register(ChatSDKEventsHandler(
            logger: resolve(),
            threadId: chatConfiguration.chatThreadId,
            localUserId: chatConfiguration.communicationIdentifier) as ChatSDKEventsHandling)
        register(ChatSDKWrapper(logger: resolve(),
                                chatEventsHandler: resolve(),
                                chatConfiguration: chatConfiguration) as ChatSDKWrapperProtocol)
        register(ChatService(logger: resolve(),
                             chatSDKWrapper: resolve()) as ChatServiceProtocol)

        register(MessageRepositoryManager() as MessageRepositoryManagerProtocol)

        let displayName = localOptions?.participantViewData.displayName ?? chatConfiguration.displayName
        register(makeStore(displayName: displayName,
                           localUserIdentifier: chatConfiguration.communicationIdentifier,
                           chatThreadId: chatConfiguration.chatThreadId) as Store<AppState> )
        register(NavigationRouter(store: resolve(),
                                  logger: resolve()) as NavigationRouter)
        register(AccessibilityProvider() as AccessibilityProviderProtocol)
        register(LocalizationProvider(logger: resolve()) as LocalizationProviderProtocol)
        register(AvatarViewManager(store: resolve(),
                                   localOptions: localOptions) as AvatarViewManager)
        register(CompositeViewModelFactory(messageRepository: resolve(),
                                           logger: resolve(),
                                           store: resolve(),
                                           localizationProvider: resolve(),
                                           accessibilityProvider: resolve()) as CompositeViewModelFactoryProtocol)
        register(CompositeViewFactory(logger: resolve(),
                                      avatarManager: resolve(),
                                      compositeViewModelFactory: resolve()) as CompositeViewFactoryProtocol)
        register(ErrorManager(store: resolve(),
                              chatCompositeEventsHandler: chatCompositeEventsHandler) as ErrorManagerProtocol)
        register(UIKitAppLifeCycleManager(store: resolve(),
                                          logger: resolve()) as LifeCycleManagerProtocol)
        register(RemoteParticipantsManager(store: resolve(),
                                           chatCompositeEventsHandler: chatCompositeEventsHandler,
                                           chatSDKWrapper: resolve(),
                                           avatarViewManager: resolve()) as RemoteParticipantsManager)
        register(CompositeManager(store: resolve(),
                                  logger: resolve()) as CompositeManagerProtocol)

    }

    private func makeStore(displayName: String?,
                           localUserIdentifier: CommunicationIdentifier?,
                           chatThreadId: String?) -> Store<AppState> {
        let chatActionHandler = ChatActionHandler(chatService: resolve(), logger: resolve())
        let chatServiceListener = ChatServiceListener(chatService: resolve(), logger: resolve())

        let messageMiddlewareHandler = MessageRepositoryMiddlewareHandler(messageRepository: resolve(),
                                                                          logger: resolve())
        let middlewares: [Middleware] = [
            Middleware<AppState>.liveChatMiddleware(
                chatActionHandler: chatActionHandler,
                chatServiceListener: chatServiceListener),
            Middleware<AppState>.liveMessageRepositoryMiddleware(messageMiddlewareHandler: messageMiddlewareHandler)
        ]

        let localUserInfoModel = LocalUserInfoModel(
            displayName: displayName,
            localUserIdentifier: localUserIdentifier,
            chatThreadId: chatThreadId)

        let appState = AppState(chatState: ChatState(
            localUser: localUserInfoModel))
        return Store<AppState>(reducer: Reducer<AppState, Action>.appStateReducer(),
                               middlewares: middlewares,
                               state: appState)
    }
}
