//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import AzureCommunicationCalling
import AzureCommunicationCommon

import UIKit
import SwiftUI
import FluentUI

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
        /// Closure to execute when call state changes.
        public var onCallStateChanged: ((CallState) -> Void)?
        /// Closure to Call Composite dismissed.
        public var onDismissed: ((CallCompositeDismissed) -> Void)?
        /// Closure to incoming call received.
        public var onIncomingCall: ((CallCompositeIncomingCallInfo) -> Void)?
        /// Closure to incoming call ended.
        public var onIncomingCallEnded: ((CallCompositeIncomingCallEndedInfo) -> Void)?
    }

    /// Following native calling SDK, need static to manage call agent as destroying immediate on register push and join
    /// cause call agent initialization issue
    private static var callingSDKInitialization: CallingSDKInitialization?

    /// The events handler for Call Composite
    public let events: Events

    private let themeOptions: ThemeOptions?
    private let localizationOptions: LocalizationOptions?
    private let setupViewOrientationOptions: OrientationOptions?
    private let callingViewOrientationOptions: OrientationOptions?
    private let incomingCallWrapper: IncomingCallWrapper

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
    private var callHistoryService: CallHistoryService?
    private var callingSDKWrapper: CallingSDKWrapperProtocol?
    private var callingSDKEventsHandler: CallingSDKEventsHandler?
    private var callConfiguration: CallConfiguration?
    private lazy var callHistoryRepository = CallHistoryRepository(logger: logger,
        userDefaults: UserDefaults.standard)
    private let diagnosticConfig = DiagnosticConfig()

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
    public init(withOptions options: CallCompositeOptions? = nil) {
        events = Events()
        incomingCallWrapper = IncomingCallWrapper(logger: logger, events: events)
        themeOptions = options?.themeOptions
        localizationOptions = options?.localizationOptions
        localizationProvider = LocalizationProvider(logger: logger)
        setupViewOrientationOptions = options?.setupScreenOrientation
        callingViewOrientationOptions = options?.callingScreenOrientation
        orientationProvider = OrientationProvider()
    }

    /// Dismiss call composite. If call is in progress, user will leave a call.
    public func dismiss() {
        exitManager?.dismiss()
    }

    /// Dismiss composite and cleanup call agent
    public func dispose() {
        callConfiguration = nil
        dismiss()
        incomingCallWrapper.dispose()
        CallComposite.callingSDKInitialization?.dispose()
        CallComposite.callingSDKInitialization = nil
    }

    /// Handle push notification to receive incoming call
    public func handlePushNotification(remoteOptions: RemoteOptions) async throws {
        self.callConfiguration = nil
        let pushNotificationInfo = remoteOptions.pushNotificationInfo!.pushNotificationInfo
        try await constructCallingSDKInitialization(
            logger: logger).handlePushNotification(
                tags: diagnosticConfig.tags,
                credential: remoteOptions.credential,
                callKitOptions: remoteOptions.callKitOptions,
                displayName: remoteOptions.displayName,
                callNotification: pushNotificationInfo)
    }

    /// Report incoming call to notify CallKit
    /// On success you can wake up application.
    public static func reportIncomingCall(callKitOptions: CallCompositeCallKitOption,
                                          callNotification: CallCompositePushNotificationInfo,
                                          completion: @escaping (Result<Void, Error>) -> Void) {
        let callKitOptionsInternal = CallKitOptions(with: callKitOptions.cxProvideConfig)
        callKitOptionsInternal.isCallHoldSupported = callKitOptions.isCallHoldSupported
        callKitOptionsInternal.configureAudioSession = callKitOptions.configureAudioSession

        CallClient.reportIncomingCall(
            with: callNotification.pushNotificationInfo,
            callKitOptions: callKitOptionsInternal
        ) { (error) in
            if error == nil {
                completion(.success(()))
            } else {
                completion(.failure(error!))
            }
        }
    }

    /// Register device token to receive push notifications
    /// Currently, push notificatiosn are only supported with CallKit
    public func registerPushNotification(notificationOptions: CallCompositePushNotificationOptions) async throws {
        try await constructCallingSDKInitialization(
            logger: logger).registerPushNotification(notificationOptions: notificationOptions,
                                                     tags: diagnosticConfig.tags)
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

        setupColorTheming()
        setupLocalization(with: localizationProvider)

        guard let store = self.store else {
            fatalError("Construction of dependencies failed")
        }
        let toolkitHostingController = makeToolkitHostingController(
            router: NavigationRouter(store: store, logger: logger),
            logger: logger,
            viewFactory: viewFactory,
            isRightToLeft: localizationProvider.isRightToLeft
        )

        present(toolkitHostingController)

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
    ///                            This is data is not sent up to ACS.
    public func launch(remoteOptions: RemoteOptions,
                       localOptions: LocalOptions? = nil) {
        var callConfiguration: CallConfiguration?
        if let locator = remoteOptions.locator {
            callConfiguration = CallConfiguration(locator: locator,
                                                  credential: remoteOptions.credential,
                                                  displayName: remoteOptions.displayName,
                                                  callKitOptions: remoteOptions.callKitOptions,
                                                  diagnosticConfig: diagnosticConfig)
        } else if let startCallOptions = remoteOptions.startCallOptions {
            callConfiguration = CallConfiguration(startCallOptions: startCallOptions,
                                                  credential: remoteOptions.credential,
                                                  displayName: remoteOptions.displayName,
                                                  callKitOptions: remoteOptions.callKitOptions,
                                                  diagnosticConfig: diagnosticConfig)
        }
        self.callConfiguration = callConfiguration
        if let callconfig = callConfiguration {
            launch(callconfig, localOptions: localOptions)
        }
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

    private func onCallsAdded(callId: String) {
        if store?.state.callingState.callId != callId && self.callConfiguration == nil {
            guard let callingSDKInitialization = CallComposite.callingSDKInitialization,
                  let callKitOptions = callingSDKInitialization.callCompositeCallKitOptions else {
                return
            }
            let callConfiguration = CallConfiguration(callType: .oneToNCallIncoming,
                                                      diagnosticConfig: diagnosticConfig,
                                                      displayName: callingSDKInitialization.displayName,
                                                      callKitOptions: callKitOptions)
            let localOptions = LocalOptions(skipSetupScreen: true)
            DispatchQueue.main.async {
                self.launch(callConfiguration, localOptions: localOptions)
            }
        }
    }

    private func constructCallingSDKInitialization(logger: Logger) -> CallingSDKInitialization {
        if let callingSDKInitialization = CallComposite.callingSDKInitialization {
            callingSDKInitialization.callsUpdatedProtocol = incomingCallWrapper
            return callingSDKInitialization
        }
        CallComposite.callingSDKInitialization = CallingSDKInitialization(logger: logger)
        CallComposite.callingSDKInitialization?.callsUpdatedProtocol = incomingCallWrapper
        CallComposite.callingSDKInitialization?.onCallAdded = onCallsAdded
        return CallComposite.callingSDKInitialization!
    }

    private func constructViewFactoryAndDependencies(
        for callConfiguration: CallConfiguration,
        localOptions: LocalOptions?,
        callCompositeEventsHandler: CallComposite.Events,
        withCallingSDKWrapper wrapper: CallingSDKWrapperProtocol? = nil
    ) -> CompositeViewFactoryProtocol {
        let callingSDKEventsHandler = CallingSDKEventsHandler(logger: logger)
        let callingSdkWrapper = wrapper ?? CallingSDKWrapper(
            logger: logger,
            callingEventsHandler: callingSDKEventsHandler,
            callConfiguration: callConfiguration,
            callingSDKInitialization: constructCallingSDKInitialization(logger: logger)
        )
        self.callingSDKWrapper = callingSdkWrapper

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
        self.remoteParticipantsManager = RemoteParticipantsManager(
            store: store,
            callCompositeEventsHandler: callCompositeEventsHandler,
            avatarViewManager: avatarViewManager
        )
        let debugInfoManager = createDebugInfoManager()
        self.debugInfoManager = debugInfoManager
        self.callHistoryService = CallHistoryService(store: store, callHistoryRepository: self.callHistoryRepository)
        let audioSessionManager = AudioSessionManager(store: store,
                                                      logger: logger,
                                                      isCallKitEnabled: callConfiguration.callKitOptions != nil)
        self.audioSessionManager = audioSessionManager
        return CompositeViewFactory(
            logger: logger,
            avatarManager: avatarViewManager,
            videoViewManager: VideoViewManager(callingSDKWrapper: callingSdkWrapper, logger: logger),
            compositeViewModelFactory: CompositeViewModelFactory(
                logger: logger,
                store: store,
                networkManager: NetworkManager(),
                audioSessionManager: audioSessionManager,
                localizationProvider: localizationProvider,
                accessibilityProvider: accessibilityProvider,
                debugInfoManager: debugInfoManager,
                localOptions: localOptions,
                compositeCallType: callConfiguration.compositeCallType
            )
        )
    }
    private func createDebugInfoManager() -> DebugInfoManagerProtocol {
        return DebugInfoManager(callHistoryRepository: self.callHistoryRepository)
    }
    private func cleanUpManagers() {
        self.callingSDKEventsHandler?.cleanup()
        self.callingSDKWrapper?.cleanup()
        self.callingSDKWrapper = nil
        self.errorManager = nil
        self.callStateManager = nil
        self.lifeCycleManager = nil
        self.permissionManager = nil
        self.audioSessionManager = nil
        self.avatarViewManager = nil
        self.remoteParticipantsManager = nil
        self.debugInfoManager = nil
        self.callHistoryService = nil
        self.exitManager = nil
    }

    private func makeToolkitHostingController(router: NavigationRouter,
                                              logger: Logger,
                                              viewFactory: CompositeViewFactoryProtocol,
                                              isRightToLeft: Bool)
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
                                     isRightToLeft: isRightToLeft)
        let containerUIHostingController = ContainerUIHostingController(rootView: rootView,
                                                                        callComposite: self,
                                                                        isRightToLeft: isRightToLeft)
        containerUIHostingController.modalPresentationStyle = .fullScreen
        router.setDismissComposite { [weak containerUIHostingController, weak self] in
             containerUIHostingController?.dismissSelf()
             self?.exitManager?.onDismissed()
             self?.cleanUpManagers()
        }

        return containerUIHostingController
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
