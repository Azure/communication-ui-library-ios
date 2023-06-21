//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import AzureCommunicationCommon

import UIKit
import SwiftUI
import FluentUI
import AVKit
import Combine

/// The main class representing the entry point for the Call Composite.
public class CallComposite {
    /// The class to configure events closures for Call Composite.
    public class Events {
        /// Closure to execute when error event occurs inside Call Composite.
        public var onError: ((CallCompositeError) -> Void)?
        /// Closures to execute when participant has joined a call inside Call Composite.
        public var onRemoteParticipantJoined: (([CommunicationIdentifier]) -> Void)?
        /// Closure to execute when call state changes.
        public var onCallStateChanged: ((CallCompositeCallState) -> Void)?
        /// Closure to execute when Call Composite exited.
        public var onExited: ((CallCompositeExit) -> Void)?
    }

    /// The events handler for Call Composite
    public let events: Events

    private let themeOptions: ThemeOptions?
    private let localizationOptions: LocalizationOptions?
    private let setupViewOrientationOptions: OrientationOptions?
    private let callingViewOrientationOptions: OrientationOptions?

    // Internal dependencies
    private var logger: Logger = DefaultLogger(category: "Calling")
    private var accessibilityProvider: AccessibilityProviderProtocol = AccessibilityProvider()
    private var localizationProvider: LocalizationProviderProtocol
    private var orientationProvider: OrientationProvider

    private var store: Store<AppState, Action>?
    private var errorManager: ErrorManagerProtocol?
    private var exitManager: ExitManagerProtocol?
    private var callStateManager: CallStateManagerProtocol?
    private var lifeCycleManager: LifeCycleManagerProtocol?
    private var permissionManager: PermissionsManagerProtocol?
    private var audioSessionManager: AudioSessionManagerProtocol?
    private var remoteParticipantsManager: RemoteParticipantsManagerProtocol?
    private var avatarViewManager: AvatarViewManagerProtocol?
    private var customCallingSdkWrapper: CallingSDKWrapperProtocol?
    private var debugInfoManager: DebugInfoManagerProtocol?
    private var pipManager: PipManagerProtocol?
    private var callHistoryService: CallHistoryService?
    private lazy var callHistoryRepository = CallHistoryRepository(logger: logger,
        userDefaults: UserDefaults.standard)

    private var viewFactory: CompositeViewFactoryProtocol?
    private var viewController: UIViewController?
    private var pipViewController: UIViewController?

    /// Get debug information for the Call Composite.
    public var debugInfo: DebugInfo {
        let localDebugInfoManager = debugInfoManager ?? createDebugInfoManager()
        return localDebugInfoManager.getDebugInfo()
    }

    /// Get call state for the Call Composite.
    public var callStateCode: String {
        return store?.state.callingState.status.toCallCompositeCallState() ?? CallCompositeCallStateCode.none
    }

    /// Create an instance of CallComposite with options.
    /// - Parameter options: The CallCompositeOptions used to configure the experience.
    public init(withOptions options: CallCompositeOptions? = nil) {
        events = Events()
        themeOptions = options?.themeOptions
        localizationOptions = options?.localizationOptions
        localizationProvider = LocalizationProvider(logger: logger)
        setupViewOrientationOptions = options?.setupScreenOrientation
        callingViewOrientationOptions = options?.callingScreenOrientation
        orientationProvider = OrientationProvider()
    }

    /// Exit call composite
    public func exit() {
        exitManager?.exit()
    }

    convenience init(withOptions options: CallCompositeOptions? = nil,
                     callingSDKWrapperProtocol: CallingSDKWrapperProtocol? = nil) {
        self.init(withOptions: options)
        self.customCallingSdkWrapper = callingSDKWrapperProtocol
    }

    deinit {
        logger.debug("Call Composite deallocated")
    }

    private func launch(_ callConfiguration: CallConfiguration,
                        localOptions: LocalOptions?) {
        logger.debug("launch composite experience")
        let viewFactory = constructViewFactoryAndDependencies(
            for: callConfiguration,
            localOptions: localOptions,
            callCompositeEventsHandler: events,
            withCallingSDKWrapper: self.customCallingSdkWrapper
        )
        self.viewFactory = viewFactory

        setupColorTheming()
        setupLocalization(with: localizationProvider)

        guard let store = self.store else {
            fatalError("Construction of dependencies failed")
        }
        let viewController = makeToolkitHostingController(router: NavigationRouter(store: store, logger: logger),
            viewFactory: viewFactory)
        self.viewController = viewController
        present(viewController)
    }

    /// Start Call Composite experience with joining a Teams meeting.
    /// - Parameter remoteOptions: RemoteOptions used to send to ACS to locate the call.
    /// - Parameter localOptions: LocalOptions used to set the user participants information for the call.
    ///                            This is data is not sent up to ACS.
    public func launch(remoteOptions: RemoteOptions,
                       localOptions: LocalOptions? = nil) {
        let callConfiguration = CallConfiguration(locator: remoteOptions.locator,
                                                  credential: remoteOptions.credential,
                                                  displayName: remoteOptions.displayName,
                                                  roomRole: localOptions?.roleHint)
        launch(callConfiguration, localOptions: localOptions)
    }

    /// Set ParticipantViewData to be displayed for the remote participant. This is data is not sent up to ACS.
    /// - Parameters:
    ///   - remoteParticipantViewData: ParticipantViewData used to set the participant's information for the call.
    ///   - identifier: The communication identifier for the remote participant.
    ///   - completionHandler: The completion handler that receives `Result` enum value with either
    ///                        a `Void` or an `SetParticipantViewDataError`.
    public func set(remoteParticipantViewData: ParticipantViewData,
                    for identifier: CommunicationIdentifier,
                    completionHandler: ((Result<Void, SetParticipantViewDataError>) -> Void)? = nil) {
        guard let avatarManager = avatarViewManager else {
            completionHandler?(.failure(SetParticipantViewDataError.participantNotInCall))
            return
        }
        avatarManager.set(remoteParticipantViewData: remoteParticipantViewData,
                          for: identifier,
                          completionHandler: completionHandler)
    }

    public func show() {
        guard let store = self.store, let viewFactory = self.viewFactory else {
            logger.error("CallComposite was not launched yet. launch method has to be called first")
            return
        }
        self.pipManager?.stopPictureInPicture()
        self.pipViewController?.dismissSelf()
        self.viewController?.dismissSelf()

        let viewController = makeToolkitHostingController(
            router: NavigationRouter(store: store, logger: logger), viewFactory: viewFactory)
        self.viewController = viewController
        present(viewController)

        self.pipManager?.reset()
    }

    private func constructViewFactoryAndDependencies(
        for callConfiguration: CallConfiguration,
        localOptions: LocalOptions?,
        callCompositeEventsHandler: CallComposite.Events,
        withCallingSDKWrapper wrapper: CallingSDKWrapperProtocol? = nil
    ) -> CompositeViewFactoryProtocol {
        let callingSdkWrapper = wrapper ?? CallingSDKWrapper(
            logger: logger,
            callingEventsHandler: CallingSDKEventsHandler(logger: logger),
            callConfiguration: callConfiguration)

        let store = Store.constructStore(
            logger: logger,
            callingService: CallingService(logger: logger, callingSDKWrapper: callingSdkWrapper),
            displayName: localOptions?.participantViewData?.displayName ?? callConfiguration.displayName,
            startWithCameraOn: localOptions?.cameraOn,
            startWithMicrophoneOn: localOptions?.microphoneOn,
            skipSetupScreen: localOptions?.skipSetupScreen
        )
        self.store = store

        // Construct managers
        let avatarViewManager = AvatarViewManager(
            store: store,
            localParticipantViewData: localOptions?.participantViewData
        )
        self.avatarViewManager = avatarViewManager

        self.errorManager = CompositeErrorManager(store: store, callCompositeEventsHandler: callCompositeEventsHandler)
        self.callStateManager = CallStateManager(store: store, callCompositeEventsHandler: callCompositeEventsHandler)
        self.exitManager = CompositeExitManager(store: store, callCompositeEventsHandler: callCompositeEventsHandler)
        self.lifeCycleManager = UIKitAppLifeCycleManager(store: store, logger: logger)
        self.permissionManager = PermissionsManager(store: store)
        self.audioSessionManager = AudioSessionManager(store: store, logger: logger)
        self.remoteParticipantsManager = RemoteParticipantsManager(
            store: store,
            callCompositeEventsHandler: callCompositeEventsHandler,
            avatarViewManager: avatarViewManager
        )
        let debugInfoManager = createDebugInfoManager()
        self.debugInfoManager = debugInfoManager
        self.pipManager = createPipManager(store)

        self.callHistoryService = CallHistoryService(store: store, callHistoryRepository: self.callHistoryRepository)

        return CompositeViewFactory(
            logger: logger,
            avatarManager: avatarViewManager,
            videoViewManager: VideoViewManager(callingSDKWrapper: callingSdkWrapper, logger: logger),
            compositeViewModelFactory: CompositeViewModelFactory(
                logger: logger,
                store: store,
                networkManager: NetworkManager(),
                localizationProvider: localizationProvider,
                accessibilityProvider: accessibilityProvider,
                debugInfoManager: debugInfoManager,
                localOptions: localOptions
            )
        )
    }

    private func createDebugInfoManager() -> DebugInfoManagerProtocol {
        return DebugInfoManager(callHistoryRepository: self.callHistoryRepository)
    }

    private func cleanUpManagers() {
        self.errorManager = nil
        self.callStateManager = nil
        self.lifeCycleManager = nil
        self.permissionManager = nil
        self.audioSessionManager = nil
        self.avatarViewManager = nil
        self.remoteParticipantsManager = nil
        self.debugInfoManager = nil
        self.pipManager = nil
        self.callHistoryService = nil
        self.exitManager = nil
    }

    private func present(_ viewController: UIViewController) {
        Task { @MainActor in
            guard self.isCompositePresentable(),
                  let topViewController = UIWindow.keyWindow?.topViewController else {
                // go to throw the error in the delegate handler
                return
            }
            topViewController.present(viewController, animated: true, completion: nil)
        }
    }

    private func setupColorTheming() {
        let colorProvider = ColorThemeProvider(themeOptions: themeOptions)
        StyleProvider.color = colorProvider
        Task { @MainActor in
            if let window = UIWindow.keyWindow {
                Colors.setProvider(provider: colorProvider, for: window)
            }
        }
    }

    private func setupLocalization(with provider: LocalizationProviderProtocol) {
        if let localizationOptions = localizationOptions {
            provider.apply(localeConfig: localizationOptions)
        }
    }

    private func isCompositePresentable() -> Bool {
        guard let keyWindow = UIWindow.keyWindow else {
            return false
        }
        let hasCallComposite = keyWindow.hasViewController(ofKind: ContainerUIHostingController.self)

        return !hasCallComposite
    }
}

extension CallComposite {
    func createPipManager(_ store: Store<AppState, Action>) -> PipManager {
        return PipManager(store: store, logger: logger, onRequirePipContentView: {
//            self.logger.debug("onRequirePipContentView")
            guard let store = self.store, let viewFactory = self.viewFactory else {
                return nil
            }

            let viewController = self.makeToolkitHostingController(
                router: NavigationRouter(store: store, logger: self.logger),
                viewFactory: viewFactory)
            self.pipViewController = viewController
            return viewController.view
        },
                                     onRequirePipPlaceholderView: {
//            self.logger.debug("onRequirePipPlaceholderView")
            return self.viewController?.view
        },
                                     onPipStarted: {
//            self.logger.debug("onPipStarted")
            self.viewController?.dismissSelf()
            self.viewController = nil
        },
                                     onPipStoped: {
//            self.logger.debug("onPipStoped")
            self.pipViewController?.dismissSelf()
            self.show()
        },
                                     onPipStartFailed: {
//            self.logger.debug("onPipStartFailed")
            self.viewController?.dismissSelf()
            self.viewController = nil
        })
    }

    private func makeToolkitHostingController(router: NavigationRouter,
                                              viewFactory: CompositeViewFactoryProtocol)
    -> ContainerUIHostingController {
        let setupViewOrientationMask = orientationProvider.orientationMask(for:
                                                                            setupViewOrientationOptions)
        let callingViewOrientationMask = orientationProvider.orientationMask(for:
                                                                                callingViewOrientationOptions)
        let rootView = ContainerView(router: router,
                                     logger: logger,
                                     viewFactory: viewFactory,
                                     setupViewOrientationMask: setupViewOrientationMask,
                                     callingViewOrientationMask: callingViewOrientationMask,
                                     isRightToLeft: localizationProvider.isRightToLeft)
        let hostingController = ContainerUIHostingController(rootView: rootView, callComposite: self,
                                                             isRightToLeft: localizationProvider.isRightToLeft)

        hostingController.modalPresentationStyle = .fullScreen
        router.setDismissComposite { [weak hostingController, weak self] in
            hostingController?.dismissSelf()
            self?.viewController = nil
            self?.pipViewController = nil
            self?.viewFactory = nil
            self?.cleanUpManagers()
        }

        return hostingController
    }
}
