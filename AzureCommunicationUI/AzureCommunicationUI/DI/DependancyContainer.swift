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
                              localDataOptions: CommunicationUILocalDataOptions?,
                              eventsHandler: CallCompositeEventsHandling) {
        register(CallingSDKEventsHandler(logger: resolve()) as CallingSDKEventsHandling)
        register(CallingSDKWrapper(logger: resolve(),
                                   callingEventsHandler: resolve(),
                                   callConfiguration: callConfiguration) as CallingSDKWrapperProtocol)
        register(VideoViewManager(callingSDKWrapper: resolve(), logger: resolve()) as VideoViewManager)
        register(CallingService(logger: resolve(),
                                callingSDKWrapper: resolve()) as CallingServiceProtocol)
        let displayName = localDataOptions?.localPersona.renderDisplayName ?? callConfiguration.displayName
        register(makeStore(displayName: displayName) as Store<AppState>)
        register(NavigationRouter(store: resolve(),
                                  logger: resolve()) as NavigationRouter)
        register(AccessibilityProvider() as AccessibilityProviderProtocol)
        register(LocalizationProvider(logger: resolve()) as LocalizationProviderProtocol)
        register(CompositeAvatarViewManager(store: resolve(),
                                            localDataOptions: localDataOptions) as AvatarViewManagerProtocol)
        register(CompositeViewModelFactory(logger: resolve(),
                                           store: resolve(),
                                           localizationProvider: resolve(),
                                           accessibilityProvider: resolve()) as CompositeViewModelFactoryProtocol)
        register(CompositeViewFactory(logger: resolve(),
                                      avatarManager: resolve(),
                                      videoViewManager: resolve(),
                                      compositeViewModelFactory: resolve()) as CompositeViewFactoryProtocol)
    }

    private func makeStore(displayName: String?) -> Store<AppState> {
        let middlewaresHandler = CallingMiddlewareHandler(callingService: resolve(), logger: resolve())
        let middlewares: [Middleware] = [CallingMiddleware(
            callingMiddlewareHandler: middlewaresHandler)]
        let appStateReducer = AppStateReducer(permissionReducer: PermissionReducer(),
                                              localUserReducer: LocalUserReducer(),
                                              lifeCycleReducer: LifeCycleReducer(),
                                              callingReducer: CallingReducer(),
                                              navigationReducer: NavigationReducer(),
                                              errorReducer: ErrorReducer())

        let localUserState = LocalUserState(displayName: displayName)
        return Store<AppState>(reducer: appStateReducer,
                               middlewares: middlewares,
                               state: AppState(localUserState: localUserState))
    }

}
