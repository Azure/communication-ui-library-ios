//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

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

    func registerDependencies(_ callConfiguration: CallConfiguration,
                              localOptions: LocalOptions?,
                              callCompositeEventsHandler: CallComposite.Events) {
        register(CallingSDKEventsHandler(logger: resolve()) as CallingSDKEventsHandling)
        register(CallingSDKWrapper(logger: resolve(),
                                   callingEventsHandler: resolve(),
                                   callConfiguration: callConfiguration) as CallingSDKWrapperProtocol)
        register(VideoViewManager(callingSDKWrapper: resolve(), logger: resolve()) as VideoViewManager)
        register(CallingService(logger: resolve(),
                                callingSDKWrapper: resolve()) as CallingServiceProtocol)
        let displayName = localOptions?.participantViewData.displayName ?? callConfiguration.displayName
        register(makeStore(displayName: displayName) as Store<AppState>)
        register(NavigationRouter(store: resolve(),
                                  logger: resolve()) as NavigationRouter)
        register(AccessibilityProvider() as AccessibilityProviderProtocol)
        register(LocalizationProvider(logger: resolve()) as LocalizationProviderProtocol)
        register(AvatarViewManager(store: resolve(),
                                   localOptions: localOptions) as AvatarViewManager)
        register(CompositeViewModelFactory(logger: resolve(),
                                           store: resolve(),
                                           localizationProvider: resolve(),
                                           accessibilityProvider: resolve()) as CompositeViewModelFactoryProtocol)
        register(CompositeViewFactory(logger: resolve(),
                                      avatarManager: resolve(),
                                      videoViewManager: resolve(),
                                      compositeViewModelFactory: resolve()) as CompositeViewFactoryProtocol)
        register(CompositeErrorManager(store: resolve(),
                                       callCompositeEventsHandler: callCompositeEventsHandler) as ErrorManagerProtocol)
        register(UIKitAppLifeCycleManager(store: resolve(),
                                          logger: resolve()) as LifeCycleManagerProtocol)
        register(PermissionsManager(store: resolve()) as PermissionsManagerProtocol)
        register(AudioSessionManager(store: resolve(),
                                     logger: resolve()) as AudioSessionManagerProtocol)
        register(RemoteParticipantsManager(store: resolve(),
                                           callCompositeEventsHandler: callCompositeEventsHandler,
                                           callingSDKWrapper: resolve(),
                                           avatarViewManager: resolve()) as RemoteParticipantsManager)

    }

    private func makeStore(displayName: String?) -> Store<AppState> {
        let middlewaresHandler = CallingMiddlewareHandler(callingService: resolve(), logger: resolve())
        let middlewares: [Middleware] = [ liveCallingMiddleware(callingMiddlewareHandler: middlewaresHandler)
        ]

        let localUserState = LocalUserState(displayName: displayName)
        return Store<AppState>(reducer: Reducer<AppState, Actions>.appStateReducer(),
                               middlewares: middlewares,
                               state: AppState(localUserState: localUserState))
    }

}
