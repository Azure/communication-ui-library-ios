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
                              localDataOptions: CommunicationUILocalDataOptions?) {
        register(CallingSDKEventsHandler(logger: resolve()) as CallingSDKEventsHandling)
        register(ACSCallingSDKWrapper(logger: resolve(),
                                      callingEventsHandler: resolve(),
                                      callConfiguration: callConfiguration) as CallingSDKWrapper)
        register(VideoViewManager(callingSDKWrapper: resolve(), logger: resolve()) as VideoViewManager)
        register(ACSCallingService(logger: resolve(),
                                   callingSDKWrapper: resolve()) as CallingService)
        register(makeStore(displayName: localDataOptions?.localPersona.renderDisplayName) as Store<AppState>)
        register(NavigationRouter(store: resolve(),
                                  logger: resolve()) as NavigationRouter)
        register(AppAccessibilityProvider() as AccessibilityProvider)
        register(AppLocalizationProvider(logger: resolve()) as LocalizationProvider)
        register(CompositeAvatarViewManager(store: resolve(),
                                            localDataOptions: localDataOptions) as AvatarViewManager)
        register(ACSCompositeViewModelFactory(logger: resolve(),
                                              store: resolve(),
                                              localizationProvider: resolve(),
                                              accessibilityProvider: resolve()) as CompositeViewModelFactory)
        register(ACSCompositeViewFactory(logger: resolve(),
                                         avatarManager: resolve(),
                                         videoViewManager: resolve(),
                                         compositeViewModelFactory: resolve()) as CompositeViewFactory)
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
