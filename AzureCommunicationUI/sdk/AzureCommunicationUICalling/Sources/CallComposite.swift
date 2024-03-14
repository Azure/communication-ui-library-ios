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

// swiftlint:disable type_body_length
// swiftlint:disable file_length
/// The main class representing the entry point for the Call Composite.
public class CallComposite {
    /// The class to configure events closures for Call Composite.
    public class Events {
        /// Closure to execute when error event occurs inside Call Composite.
        public var onError: ((CallCompositeError) -> Void)?
        /// Closures to execute when participant has joined a call inside Call Composite.
        public var onRemoteParticipantJoined: (([CommunicationIdentifier]) -> Void)?
        /// Closure to execure when CallComposite is displayed in Picture-In-Picture.
        public var onPictureInPictureChanged: ((_ isPictureInPicture: Bool) -> Void)?
        /// Closure to execute when call state changes.
        public var onCallStateChanged: ((CallState) -> Void)?
        /// Closure to Call Composite dismissed.
        public var onDismissed: ((CallCompositeDismissed) -> Void)?
        /// Closure to execute when the User reports an issue from within the call composite
        public var onUserReportedIssue: ((CallCompositeUserReportedIssue) -> Void)?
        /// Closure to incoming call received.
        public var onIncomingCall: ((CallCompositeIncomingCall) -> Void)?
        /// Closure to incoming call cancelled.
        public var onIncomingCallCancelled: ((CallCompositeIncomingCallCancelled) -> Void)?
    }

    /// The events handler for Call Composite
    public let events: Events

    private let themeOptions: ThemeOptions?
    private let localizationOptions: LocalizationOptions?
    private let enableMultitasking: Bool
    private let enableSystemPipWhenMultitasking: Bool
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
    private var cancellables = Set<AnyCancellable>()

    /// Get debug information for the Call Composite.
    public var debugInfo: DebugInfo {
        let localDebugInfoManager = debugInfoManager ?? createDebugInfoManager()
        return localDebugInfoManager.getDebugInfo()
    }

    /// Get call state for the Call Composite.
    public var callState: CallState {
        return store?.state.callingState.status.toCallCompositeCallState() ?? CallState.none
    }

    /// Create an instance of CallComposite with options.
    /// - Parameter options: The CallCompositeOptions used to configure the experience.
    @available(*, deprecated, message: "Use init with CommunicationTokenCredential instead.")
    public init(withOptions options: CallCompositeOptions? = nil) {
        events = Events()
        themeOptions = options?.themeOptions
        localizationOptions = options?.localizationOptions
        localizationProvider = LocalizationProvider(logger: logger)
        enableMultitasking = options?.enableMultitasking ?? false
        enableSystemPipWhenMultitasking = options?.enableSystemPipWhenMultitasking ?? false
        setupViewOrientationOptions = options?.setupScreenOrientation
        callingViewOrientationOptions = options?.callingScreenOrientation
        orientationProvider = OrientationProvider()
    }

    /// Create an instance of CallComposite with options.
    /// - Parameter for: The CommunicationTokenCredential used for call.
    /// - Parameter options: The CallCompositeOptions used to configure the experience.
    public init(for: CommunicationTokenCredential,
                withOptions options: CallCompositeOptions? = nil) {
        events = Events()
        themeOptions = options?.themeOptions
        localizationOptions = options?.localizationOptions
        localizationProvider = LocalizationProvider(logger: logger)
        enableMultitasking = options?.enableMultitasking ?? false
        enableSystemPipWhenMultitasking = options?.enableSystemPipWhenMultitasking ?? false
        setupViewOrientationOptions = options?.setupScreenOrientation
        callingViewOrientationOptions = options?.callingScreenOrientation
        orientationProvider = OrientationProvider()
    }

    /// Dismiss call composite. If call is in progress, user will leave a call.
    public func dismiss() {
        exitManager?.dismiss()
    }

    /// Handle push notification to receive incoming call notification.
    public func handlePushNotification(for: CallCompositePushNotification,
                                       completionHandler: ((Result<Void, Error>) -> Void)? = nil) {
    }

    /// Report incoming call to notify CallKit when in background mode.
    /// On success you can wake up application.
    public static func reportIncomingCall(for: CallCompositePushNotification,
                                          callKitOptions: CallCompositeCallKitOptions,
                                          completionHandler: ((Result<Void, Error>) -> Void)? = nil) {
    }

    /// Register device token to receive Azure Notification Hubs push notifications.
    public func registerPushNotifications(deviceRegistrationToken: Data,
                                          completionHandler: ((Result<Void, Error>) -> Void)? = nil) {
    }

    /// Unregister Azure Notification Hubs push notifications
    public func unregisterPushNotifications(completionHandler: ((Result<Void, Error>) -> Void)? = nil) {
    }

    /// Accept incoming call
    public func acceptIncomingCall(callId: String,
                                   localOptions: LocalOptions? = nil) {
    }

    /// Reject incoming call
    public func rejectIncomingCall(callId: String,
                                   completionHandler: ((Result<Void, Error>) -> Void)? = nil) {
    }

    /// Hold  call
    public func hold(completionHandler: ((Result<Void, Error>) -> Void)? = nil) {
    }

    /// Resume  call
    public func resume(completionHandler: ((Result<Void, Error>) -> Void)? = nil) {
    }

    /// Mute outgoing  audio
    public func muteOutgoingAudio(completionHandler: ((Result<Void, Error>) -> Void)? = nil) {
    }

    /// Unmute outgoing  audio
    public func unmuteOutgoingAudio(completionHandler: ((Result<Void, Error>) -> Void)? = nil) {
    }

    /// Mute incoming  audio
    public func muteIncomingAudio(completionHandler: ((Result<Void, Error>) -> Void)? = nil) {
    }

    /// Unmute incoming  audio
    public func unmuteIncomingAudio(completionHandler: ((Result<Void, Error>) -> Void)? = nil) {
    }

    @available(*, deprecated, message: "Use init with CommunicationTokenCredential instead.")
    convenience init(withOptions options: CallCompositeOptions? = nil,
                     callingSDKWrapperProtocol: CallingSDKWrapperProtocol? = nil) {
        self.init(withOptions: options)
        self.customCallingSdkWrapper = callingSDKWrapperProtocol
    }

    /// Start Call Composite experience with dialing participants.
    /// - Parameter participants: participants to dial.
    /// - Parameter localOptions: LocalOptions used to set the user participants information for the call.
    ///                            This data is not sent up to ACS.
    public func launch(participants: [CommunicationIdentifier],
                       localOptions: LocalOptions? = nil) {
    }

    /// Start Call Composite experience with joining a existing call.
    /// - Parameter locator: Join existing call.
    /// - Parameter localOptions: LocalOptions used to set the user participants information for the call.
    ///                            This data is not sent up to ACS.
    public func launch(locator: JoinLocator,
                       localOptions: LocalOptions? = nil) {
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

        if store.state.permissionState.audioPermission == .notAsked {
            store.dispatch(action: .permissionAction(.audioPermissionRequested))
        }
        if store.state.defaultUserState.audioState == .on {
            store.dispatch(action: .localUserAction(.microphonePreviewOn))
        }

        store.dispatch(action: .callingAction(.setupCall))
    }

    /// Start Call Composite experience with joining a Teams meeting.
    /// - Parameter remoteOptions: RemoteOptions used to send to ACS to locate the call.
    /// - Parameter localOptions: LocalOptions used to set the user participants information for the call.
    ///                            This data is not sent up to ACS.
        @available(*, deprecated, message: """
Use CallComposite init with CommunicationTokenCredential
and launch(locator: JoinLocator, localOptions: LocalOptions? = nil) instead.
""")
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
    private func displayCallCompositeIfWasHidden() {
        guard let store = self.store, let viewFactory = self.viewFactory else {
            logger.error("CallComposite was not launched yet. launch() method has to be called first.")
            return
        }
        self.pipManager?.stopPictureInPicture()
        if self.pipViewController != nil {
            self.events.onPictureInPictureChanged?(false)
        }
        self.pipViewController?.dismissSelf()
        self.pipViewController = nil
        self.viewController?.dismissSelf()

        let viewController = makeToolkitHostingController(
            router: NavigationRouter(store: store, logger: logger), viewFactory: viewFactory)
        self.viewController = viewController
        present(viewController)

        self.pipManager?.reset()
    }

    /// Controls if CallComposite UI is hidder. If CallComosite is created with enableSystemPipWhenMultitasking
    /// set to true, then setting isHidden to true will start syspem Picture-in-Picture view.
    public var isHidden: Bool {
        get {
            guard let store = self.store else {
                return true
            }
            return store.state.visibilityState.currentStatus != .visible
        }
        set(isHidden) {
            if isHidden {
                hide()
            } else {
                displayCallCompositeIfWasHidden()
            }
        }
    }

    private func hide() {
        self.viewController?.dismissSelf()
        self.viewController = nil
        if self.enableSystemPipWhenMultitasking && store?.state.navigationState.status == .inCall {
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
        let debugInfoManager = createDebugInfoManager(callingSDKWrapper: callingSdkWrapper)
        self.debugInfoManager = debugInfoManager
        let videoViewManager = VideoViewManager(callingSDKWrapper: callingSdkWrapper, logger: logger)

        if enableSystemPipWhenMultitasking {
            self.pipManager = createPipManager(store)
        }

        self.callHistoryService = CallHistoryService(store: store, callHistoryRepository: self.callHistoryRepository)
        let audioSessionManager = AudioSessionManager(store: store, logger: logger)
        self.audioSessionManager = audioSessionManager
        return CompositeViewFactory(
            logger: logger,
            avatarManager: avatarViewManager,
            videoViewManager: videoViewManager,
            compositeViewModelFactory: CompositeViewModelFactory(
                logger: logger,
                store: store,
                networkManager: NetworkManager(),
                audioSessionManager: audioSessionManager,
                localizationProvider: localizationProvider,
                accessibilityProvider: accessibilityProvider,
                debugInfoManager: debugInfoManager,
                localOptions: localOptions,
                enableMultitasking: enableMultitasking,
                enableSystemPipWhenMultitasking: enableSystemPipWhenMultitasking,
                eventsHandler: events,
                retrieveLogFiles: callingSdkWrapper.getLogFiles
            )
        )
    }

    private func createDebugInfoManager(callingSDKWrapper: CallingSDKWrapperProtocol) -> DebugInfoManagerProtocol {
        return DebugInfoManager(callHistoryRepository: self.callHistoryRepository,
                                getLogFiles: { return callingSDKWrapper.getLogFiles() })
    }

    private func createDebugInfoManager() -> DebugInfoManagerProtocol {
        return DebugInfoManager(callHistoryRepository: self.callHistoryRepository,
                                getLogFiles: { return [] })
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
        let setupViewOrientationMask = orientationProvider.orientationMask(for:
                                                                            setupViewOrientationOptions)
        let callingViewOrientationMask = orientationProvider.orientationMask(for:
                                                                                callingViewOrientationOptions)
        let rootView = ContainerView(router: router,
                                     logger: logger,
                                     viewFactory: viewFactory,
                                     setupViewOrientationMask: setupViewOrientationMask,
                                     callingViewOrientationMask: callingViewOrientationMask,
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
        },
                                     onPipStartFailed: {
            self.viewController?.dismissSelf()
            self.viewController = nil
        })
    }
}
