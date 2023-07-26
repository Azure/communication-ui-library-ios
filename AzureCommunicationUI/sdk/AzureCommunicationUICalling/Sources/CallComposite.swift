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
        /// Closure to execure when CallComposite is displayed in Picture-In-Picture.
        public var onPictureInPictureChanged: ((_ isInPictureInPicture: Bool) -> Void)?
    }

    /// The events handler for Call Composite
    public let events: Events

    private let themeOptions: ThemeOptions?
    private let localizationOptions: LocalizationOptions?
    private let enableMultitasking: Bool
    private let enableSystemPiPWhenMultitasking: Bool

    // Internal dependencies
    private var logger: Logger = DefaultLogger(category: "Calling")
    private var accessibilityProvider: AccessibilityProviderProtocol = AccessibilityProvider()
    private var localizationProvider: LocalizationProviderProtocol

    private var store: Store<AppState, Action>?
    private var errorManager: ErrorManagerProtocol?
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
    private var cancellables = Set<AnyCancellable>()

    /// Get debug information for the Call Composite.
    public var debugInfo: DebugInfo {
        let localDebugInfoManager = debugInfoManager ?? createDebugInfoManager()
        return localDebugInfoManager.getDebugInfo()
    }

    /// Create an instance of CallComposite with options.
    /// - Parameter options: The CallCompositeOptions used to configure the experience.
    public init(withOptions options: CallCompositeOptions? = nil) {
        events = Events()
        themeOptions = options?.themeOptions
        localizationOptions = options?.localizationOptions
        localizationProvider = LocalizationProvider(logger: logger)
        enableMultitasking = options?.enableMultitasking ?? false
        enableSystemPiPWhenMultitasking = options?.enableSystemPiPWhenMultitasking ?? false
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

        store.$state
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.receive(state)
            }.store(in: &cancellables)

        let viewController = makeToolkitHostingController(router: NavigationRouter(store: store, logger: logger),
            viewFactory: viewFactory)
        self.viewController = viewController
        present(viewController)
        UIApplication.shared.isIdleTimerDisabled = true
    }

    /// Start Call Composite experience with joining a Teams meeting.
    /// - Parameter remoteOptions: RemoteOptions used to send to ACS to locate the call.
    /// - Parameter localOptions: LocalOptions used to set the user participants information for the call.
    ///                            This is data is not sent up to ACS.
    public func launch(remoteOptions: RemoteOptions,
                       localOptions: LocalOptions? = nil) {
        let callConfiguration = CallConfiguration(locator: remoteOptions.locator,
                                                  credential: remoteOptions.credential,
                                                  displayName: remoteOptions.displayName)
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

    /// Display Call Composite if it was hidden by user going Back in navigation while on the call.
    public func displayCallCompositeIfWasHidden() {
        guard let store = self.store, let viewFactory = self.viewFactory else {
            logger.error("CallComposite was not launched yet. launch() method has to be called first.")
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

    public func hide() {
        self.viewController?.dismissSelf()
        self.viewController = nil
        if self.enableSystemPiPWhenMultitasking && store?.state.navigationState.status == .inCall {
            store?.dispatch(action: .visibilityAction(.pipModeRequested))
        }
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
        let videoViewManager = VideoViewManager(callingSDKWrapper: callingSdkWrapper, logger: logger)

        if enableSystemPiPWhenMultitasking {
            self.pipManager = createPipManager(store)
        }

        self.callHistoryService = CallHistoryService(store: store, callHistoryRepository: self.callHistoryRepository)

        return CompositeViewFactory(
            logger: logger,
            avatarManager: avatarViewManager,
            videoViewManager: videoViewManager,
            compositeViewModelFactory: CompositeViewModelFactory(
                logger: logger,
                store: store,
                networkManager: NetworkManager(),
                localizationProvider: localizationProvider,
                accessibilityProvider: accessibilityProvider,
                debugInfoManager: debugInfoManager,
                localOptions: localOptions,
                enableMultitasking: enableMultitasking,
                enableSystemPiPWhenMultitasking: enableSystemPiPWhenMultitasking
            )
        )
    }

    private func createDebugInfoManager() -> DebugInfoManagerProtocol {
        return DebugInfoManager(callHistoryRepository: self.callHistoryRepository)
    }

    private func cleanUpManagers() {
        self.errorManager = nil
        self.lifeCycleManager = nil
        self.permissionManager = nil
        self.audioSessionManager = nil
        self.avatarViewManager = nil
        self.remoteParticipantsManager = nil
        self.debugInfoManager = nil
        self.pipManager = nil
        self.callHistoryService = nil
    }

    private func present(_ viewController: UIViewController) {
        store?.dispatch(action: .visibilityAction(.showNormalEntered))
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
    private func receiveStoreEvents(_ store: Store<AppState, Action>) {
        store.$state
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.receive(state)
            }.store(in: &cancellables)
    }

    private func receive(_ state: AppState) {
        if state.visibilityState.currentStatus == .hideRequested {
            store?.dispatch(action: .visibilityAction(.hideEntered))
            hide()
        }
    }

    private func makeToolkitHostingController(router: NavigationRouter,
                                              viewFactory: CompositeViewFactoryProtocol)
    -> ContainerUIHostingController {
        let isRightToLeft = localizationProvider.isRightToLeft
        let rootView = ContainerView(router: router,
                                     logger: logger,
                                     viewFactory: viewFactory,
                                     isRightToLeft: isRightToLeft)
        let containerUIHostingController = ContainerUIHostingController(rootView: rootView,
                                                                        callComposite: self,
                                                                        isRightToLeft: isRightToLeft)
        containerUIHostingController.modalPresentationStyle = .fullScreen

        router.setDismissComposite { [weak containerUIHostingController, weak self] in
            containerUIHostingController?.dismissSelf()
            self?.viewController = nil
            self?.pipViewController = nil
            self?.viewFactory = nil
            self?.cleanUpManagers()
            UIApplication.shared.isIdleTimerDisabled = false
        }

        return containerUIHostingController
    }

    private func createPipManager(_ store: Store<AppState, Action>) -> PipManager? {

        return PipManager(store: store, logger: logger,

                          onRequirePipContentView: {
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
            return self.viewController?.view
        },
                                     onPipStarted: {
            self.viewController?.dismissSelf(animated: false)
            self.viewController = nil
            self.events.onPictureInPictureChanged?(true)
        },
                                     onPipStoped: {
            self.pipViewController?.dismissSelf()
            self.displayCallCompositeIfWasHidden()
            self.events.onPictureInPictureChanged?(false)
        },
                                     onPipStartFailed: {
            self.viewController?.dismissSelf()
            self.viewController = nil
        })
    }
}
