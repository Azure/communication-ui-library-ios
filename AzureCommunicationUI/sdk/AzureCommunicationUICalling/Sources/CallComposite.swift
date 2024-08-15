//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import AzureCommunicationCommon
/* <SDK_CX_PROVIDER_SUPPORT>
import AzureCommunicationCalling
</SDK_CX_PROVIDER_SUPPORT> */

import UIKit
import SwiftUI
import FluentUI
import AVKit
import Combine
/* <SDK_CX_PROVIDER_SUPPORT>
import CallKit
</SDK_CX_PROVIDER_SUPPORT> */

// swiftlint:disable file_length
// swiftlint:disable type_body_length
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
        public var onIncomingCall: ((IncomingCall) -> Void)?
        /// Closure to incoming call cancelled.
        public var onIncomingCallCancelled: ((IncomingCallCancelled) -> Void)?
        /// Closure to incoming call id accepted by CallKit.
        public var onIncomingCallAcceptedFromCallKit: ((_ callId: String) -> Void)?
        /// Closure to execute when participant has left a call inside Call Composite
        public var onRemoteParticipantLeave: (([CommunicationIdentifier]) -> Void)?
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
    private var callDurationManager: CallDurationManager?
    private var callHistoryService: CallHistoryService?
    private lazy var callHistoryRepository = CallHistoryRepository(logger: logger,
        userDefaults: UserDefaults.standard)
    private var leaveCallConfirmationMode: LeaveCallConfirmationMode = .alwaysEnabled
    private var setupScreenOptions: SetupScreenOptions?

    private var viewFactory: CompositeViewFactoryProtocol?
    private var viewController: UIViewController?
    private var pipViewController: UIViewController?
    private var cancellables = Set<AnyCancellable>()
    private var callKitOptions: CallKitOptions?
    private var callKitRemoteInfo: CallKitRemoteInfo?
    private var credential: CommunicationTokenCredential?
    private var userId: CommunicationIdentifier?
    private var displayName: String?
    private var disableInternalPushForIncomingCall = false
    private var callingSDKInitializer: CallingSDKInitializer?
    private var callConfiguration: CallConfiguration?
    private var compositeUILaunched = false
    private var incomingCallAcceptedByCallKitCallId: String?
    private var videoViewManager: VideoViewManager?
    private var callingSDKEventsHandler: CallingSDKEventsHandler?
    private var callingSDKWrapper: CallingSDKWrapperProtocol?
    private var customTimer: CallDurationTimer?
    private var callScreenHeaderOptions: CallScreenHeaderOptions?

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
        credential = nil
        events = Events()
        userId = options?.userId
        themeOptions = options?.themeOptions
        localizationOptions = options?.localizationOptions
        localizationProvider = LocalizationProvider(logger: logger)
        enableMultitasking = options?.enableMultitasking ?? false
        enableSystemPipWhenMultitasking = options?.enableSystemPipWhenMultitasking ?? false
        setupViewOrientationOptions = options?.setupScreenOrientation
        callingViewOrientationOptions = options?.callingScreenOrientation
        orientationProvider = OrientationProvider()
        leaveCallConfirmationMode =
               options?.callScreenOptions?.controlBarOptions?.leaveCallConfirmationMode ?? .alwaysEnabled
        setupScreenOptions = options?.setupScreenOptions
        callKitOptions = options?.callKitOptions
        displayName = options?.displayName
        if let disableInternalPushForIncomingCall = options?.disableInternalPushForIncomingCall {
            self.disableInternalPushForIncomingCall = disableInternalPushForIncomingCall
        }
    }

    /// Create an instance of CallComposite with options.
    /// - Parameter credential: The CommunicationTokenCredential used for call.
    /// - Parameter options: The CallCompositeOptions used to configure the experience.
    public init(credential: CommunicationTokenCredential,
                withOptions options: CallCompositeOptions? = nil) {
        self.credential = credential
        userId = options?.userId
        events = Events()
        themeOptions = options?.themeOptions
        localizationOptions = options?.localizationOptions
        localizationProvider = LocalizationProvider(logger: logger)
        enableMultitasking = options?.enableMultitasking ?? false
        enableSystemPipWhenMultitasking = options?.enableSystemPipWhenMultitasking ?? false
        setupViewOrientationOptions = options?.setupScreenOrientation
        callingViewOrientationOptions = options?.callingScreenOrientation
        callScreenHeaderOptions = options?.callScreenOptions?.callScreenHeaderOptions
        orientationProvider = OrientationProvider()
        leaveCallConfirmationMode =
               options?.callScreenOptions?.controlBarOptions?.leaveCallConfirmationMode ?? .alwaysEnabled
        setupScreenOptions = options?.setupScreenOptions
        callKitOptions = options?.callKitOptions
        displayName = options?.displayName
        if let disableInternalPushForIncomingCall = options?.disableInternalPushForIncomingCall {
            self.disableInternalPushForIncomingCall = disableInternalPushForIncomingCall
        }
    }

    /// Dismiss call composite. If call is in progress, user will leave a call.
    public func dismiss() {
        logger.debug( "CallComposite dismiss")
        exitManager?.dismiss()
        if !compositeUILaunched {
            disposeSDKWrappers()
            callingSDKInitializer?.dispose()
            callingSDKInitializer = nil
            logger.debug( "CallComposite callingSDKInitializer dispose")
            let exitManagerCache = exitManager
            cleanUpManagers()
            exitManagerCache?.onDismissed()
        }
    }

    /* <SDK_CX_PROVIDER_SUPPORT>
     /// Get CXProvider
     public static func getCXProvider() -> CXProvider? {
         return CallClient.getCXProviderInstance()
     }
    </SDK_CX_PROVIDER_SUPPORT> */

    /// Handle push notification to receive incoming call notification.
    /// - Parameter pushNotification: The push notification received.
    /// - Parameter completionHandler: The completion handler that receives `Result` enum value with either
    ///                               a `Void` or an `Error`.
     public func handlePushNotification(pushNotification: PushNotification,
                                        completionHandler: ((Result<Void, Error>) -> Void)? = nil) {
         guard self.credential != nil else {
             completionHandler?(.failure(CommunicationTokenCredentialError.communicationTokenCredentialNotSet))
             return
         }
         getCallingSDKInitializer().handlePushNotification(pushNotification: pushNotification,
                                                           completionHandler: completionHandler)
     }

     /// Report incoming call to notify CallKit when in background mode.
     /// On success you can wake up application.
     /// - Parameter pushNotification: The push notification received.
     /// - Parameter callKitOptions: The CallKitOptions used to configure the incoming call.
     /// - Parameter completionHandler: The completion handler that receives `Result` enum value with either
     ///                               a `Void` or an `Error`.
     public static func reportIncomingCall(pushNotification: PushNotification,
                                           callKitOptions: CallKitOptions,
                                           completionHandler: ((Result<Void, Error>) -> Void)? = nil) {
         CallingSDKInitializer.reportIncomingCall(pushNotification: pushNotification,
                                                            callKitOptions: callKitOptions,
                                                            completionHandler: completionHandler)
     }

     /// Register device token to receive Azure Notification Hubs push notifications.
     /// - Parameter deviceRegistrationToken: The device registration token.
     /// - Parameter completionHandler: The completion handler that receives `Result` enum value with either
     public func registerPushNotifications(deviceRegistrationToken: Data,
                                           completionHandler: ((Result<Void, Error>) -> Void)? = nil) {
         guard self.credential != nil else {
             completionHandler?(.failure(CommunicationTokenCredentialError.communicationTokenCredentialNotSet))
             return
         }
         getCallingSDKInitializer().registerPushNotification(deviceRegistrationToken:
                                                                    deviceRegistrationToken,
                                                                  completionHandler: completionHandler)
     }

     /// Unregister Azure Notification Hubs push notifications
     /// - Parameter completionHandler: The completion handler that receives `Result` enum value with either
     public func unregisterPushNotifications(completionHandler: ((Result<Void, Error>) -> Void)? = nil) {
         guard self.credential != nil else {
             completionHandler?(.failure(CommunicationTokenCredentialError.communicationTokenCredentialNotSet))
             return
         }
         getCallingSDKInitializer().unregisterPushNotifications(completionHandler: completionHandler)
     }

     /// Accept incoming call
     /// - Parameter incomingCallId: The incoming call id.
     /// - Parameter callKitRemoteInfo: The CallKitRemoteInfo used to set the CallKit information for the outgoing call.
     /// - Parameter localOptions: LocalOptions used to set the user participants information for the call.
     ///                            This is data is not sent up to ACS.
     public func accept(incomingCallId: String,
                        callKitRemoteInfo: CallKitRemoteInfo? = nil,
                        localOptions: LocalOptions? = nil) {
         self.callKitRemoteInfo = callKitRemoteInfo
         let callConfiguration = CallConfiguration(locator: nil,
                                               participants: nil,
                                               callId: incomingCallId)
         self.callConfiguration = callConfiguration
         launch(callConfiguration, localOptions: localOptions)
     }

     /// Reject incoming call
     /// - Parameter incomingCallId: The incoming call id.
     /// - Parameter completionHandler: The completion handler that receives `Result` enum value with either
     public func reject(incomingCallId: String,
                        completionHandler: ((Result<Void, Error>) -> Void)? = nil) {
         guard self.credential != nil else {
             completionHandler?(.failure(CommunicationTokenCredentialError.communicationTokenCredentialNotSet))
             return
         }
        getCallingSDKInitializer().reject(incomingCallId: incomingCallId, completionHandler: completionHandler)
     }

     /// Hold  call
     /// - Parameter completionHandler: The completion handler that receives `Result` enum value with either
     ///                                a `Void` or an `Error`.
     public func hold(completionHandler: ((Result<Void, Error>) -> Void)? = nil) {
         guard let callingSDKWrapper = callingSDKWrapper else {
             completionHandler?(.failure((CallError.callIsNotInProgress)))
            return
         }
         Task {
             do {
                 try await callingSDKWrapper.holdCall()
                 completionHandler?(.success(()))
             } catch {
                 completionHandler?(.failure(error))
             }
         }
     }

     /// Resume  call
     /// - Parameter completionHandler: The completion handler that receives `Result` enum value with either
     ///                                a `Void` or an `Error`.
     public func resume(completionHandler: ((Result<Void, Error>) -> Void)? = nil) {
         guard let callingSDKWrapper = callingSDKWrapper else {
             completionHandler?(.failure((CallError.callIsNotInProgress)))
            return
         }
         Task {
             do {
                 try await callingSDKWrapper.resumeCall()
                 completionHandler?(.success(()))
             } catch {
                 completionHandler?(.failure(error))
             }
         }
     }

    convenience init(withOptions options: CallCompositeOptions? = nil,
                     callingSDKWrapperProtocol: CallingSDKWrapperProtocol? = nil) {
        self.init(withOptions: options)
        self.customCallingSdkWrapper = callingSDKWrapperProtocol
    }

    deinit {
        logger.debug("CallComposite Call Composite deallocated")
    }

    private func launch(_ callConfiguration: CallConfiguration,
                        localOptions: LocalOptions?) {
        logger.debug("CallComposite launch composite experience")
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
            fatalError("CallComposite Construction of dependencies failed")
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
        } else {
            store.dispatch(action: .callingAction(.setupCall))
        }
        compositeUILaunched = true
    }

    /// Start Call Composite experience with joining a Teams meeting.
    /// - Parameter remoteOptions: RemoteOptions used to send to ACS to locate the call.
    /// - Parameter localOptions: LocalOptions used to set the user participants information for the call.
    ///                            This is data is not sent up to ACS.
    @available(*, deprecated, message: """
Use CallComposite init with CommunicationTokenCredential
and launch(locator: JoinLocator, localOptions: LocalOptions? = nil) instead.
""")
    public func launch(remoteOptions: RemoteOptions,
                       localOptions: LocalOptions? = nil) {
        let configuration = CallConfiguration(locator: remoteOptions.locator,
                                                  participants: nil,
                                                  callId: nil)
        self.credential = remoteOptions.credential
        self.displayName = remoteOptions.displayName
        self.callConfiguration = configuration
        launch(configuration, localOptions: localOptions)
    }

    /// Start Call Composite experience with joining an existing call.
    /// - Parameter locator: Join existing call.
    /// - Parameter callKitRemoteInfo: CallKitRemoteInfo used to set the
    ///                            CallKit information for the outgoing call.
    /// - Parameter localOptions: LocalOptions used to set the user participants information for the call.
    ///                            This is data is not sent up to ACS.
    public func launch(locator: JoinLocator,
                       callKitRemoteInfo: CallKitRemoteInfo? = nil,
                       localOptions: LocalOptions? = nil) {
        self.callKitRemoteInfo = callKitRemoteInfo
        let configuration = CallConfiguration(locator: locator,
                                              participants: nil,
                                              callId: nil)
        self.callConfiguration = configuration
        launch(configuration, localOptions: localOptions)
    }

    /// Start Call Composite experience with dialing participants.
    /// - Parameter participants: participants to dial.
    /// - Parameter callKitRemoteInfo: CallKitRemoteInfo used to set the
    /// CallKit information for the outgoing call.
    /// - Parameter localOptions: LocalOptions used to set the user participants information for the call.
    ///                            This data is not sent up to ACS.
    public func launch(participants: [CommunicationIdentifier],
                       callKitRemoteInfo: CallKitRemoteInfo? = nil,
                       localOptions: LocalOptions? = nil) {
        self.callKitRemoteInfo = callKitRemoteInfo
        let configuration = CallConfiguration(locator: nil,
                                              participants: participants,
                                              callId: nil)
        self.callConfiguration = configuration
        launch(configuration, localOptions: localOptions)
    }

    /// Start Call Composite experience with call accepted from CallKit.
    /// - Parameter callIdAcceptedFromCallKit: call id accepted from CallKit.
    /// - Parameter callKitRemoteInfo: CallKitRemoteInfo used to set the
    /// CallKit information for the accepted call.
    /// - Parameter localOptions: LocalOptions used to set the user participants information for the call.
    ///                           This data is not sent up to ACS.
    ///                           skipSetupScreen will be forced true as call is already accepted.
    ///                           cameraOn will be false, default CallKit option
    ///                           microphoneOn will be true, default CallKit option
    public func launch(callIdAcceptedFromCallKit: String,
                       localOptions: LocalOptions? = nil) {
        logger.debug( "launch \(callIdAcceptedFromCallKit)")
        let configuration = CallConfiguration(locator: nil,
                                              participants: nil,
                                              callId: callIdAcceptedFromCallKit)
        self.callConfiguration = configuration
        let acceptedCallLocalOptions = LocalOptions(participantViewData: localOptions?.participantViewData,
                                                   setupScreenViewData: localOptions?.setupScreenViewData,
                                                   cameraOn: false,
                                                   microphoneOn: false,
                                                   skipSetupScreen: true,
                                                   audioVideoMode: localOptions?.audioVideoMode ?? .audioAndVideo)
        launch(configuration, localOptions: acceptedCallLocalOptions)
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

    /// Native SDK do not follow call state change order for End and Accept 
    /// Any state can be received first:  disconnected for existing call or connected for newly accepted call
    /// Notify once UI is closed by disconnected state before notifying for new call accept
    private func onCallAdded(callId: String) {
        if let incomingCall = callingSDKInitializer?.getIncomingCall() {
            if incomingCall.id == callId {
                incomingCallAcceptedByCallKitCallId = callId
                notifyOnCallKitCallAccepted()
            }
        }
    }

    /// On incoming call accepted by callkit
    /// It is possible that composite is in existing call, then on previous call disconnect this function will be called
    /// CompositeUILaunched will be set to false once existing call is disconnected
    private func notifyOnCallKitCallAccepted() {
        logger.debug("CallComposite notifyOnCallKitCallAccepted start")
        if !compositeUILaunched,
           pipViewController == nil,
           let incomingCall = callingSDKInitializer?.getIncomingCall(),
           let callId = incomingCallAcceptedByCallKitCallId,
           incomingCall.id == callId,
           let onIncomingCallAcceptedByCallKit = events.onIncomingCallAcceptedFromCallKit {
            onIncomingCallAcceptedByCallKit(callId)
            incomingCallAcceptedByCallKitCallId = nil
        }
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
                if self.enableSystemPipWhenMultitasking {
                    store?.dispatch(action: .visibilityAction(.pipModeRequested))
                } else if self.enableMultitasking {
                    store?.dispatch(action: .visibilityAction(.hideRequested))
                }
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
    // swiftlint:disable function_body_length
    private func constructViewFactoryAndDependencies(
        for callConfiguration: CallConfiguration,
        localOptions: LocalOptions?,
        callCompositeEventsHandler: CallComposite.Events,
        withCallingSDKWrapper wrapper: CallingSDKWrapperProtocol? = nil
    ) -> CompositeViewFactoryProtocol {
        let callingSDKEventsHandler = CallingSDKEventsHandler(logger: logger)
        self.callingSDKEventsHandler = callingSDKEventsHandler
        let callingSdkWrapper = wrapper ?? CallingSDKWrapper(
            logger: logger,
            callingEventsHandler: callingSDKEventsHandler,
            callConfiguration: callConfiguration,
            callKitRemoteInfo: callKitRemoteInfo,
            callingSDKInitializer: getCallingSDKInitializer())
        self.callingSDKWrapper = callingSdkWrapper

        let store = Store.constructStore(
            logger: logger,
            callingService: CallingService(logger: logger, callingSDKWrapper: callingSdkWrapper),
            displayName: localOptions?.participantViewData?.displayName ?? displayName,
            startWithCameraOn: localOptions?.cameraOn,
            startWithMicrophoneOn: localOptions?.microphoneOn,
            skipSetupScreen: localOptions?.skipSetupScreen,
            callType: callConfiguration.compositeCallType
        )
        self.store = store

        // Construct managers
        let avatarViewManager = AvatarViewManager(
            store: store,
            localParticipantId: userId ?? createCommunicationIdentifier(fromRawId: ""),
            localParticipantViewData: localOptions?.participantViewData
        )
        self.avatarViewManager = avatarViewManager
        let audioSessionManager = AudioSessionManager(store: store,
                                                      logger: logger,
                                                      isCallKitEnabled: callKitOptions != nil)

        self.errorManager = CompositeErrorManager(store: store, callCompositeEventsHandler: callCompositeEventsHandler)
        self.callStateManager = CallStateManager(store: store, callCompositeEventsHandler: callCompositeEventsHandler)
        self.exitManager = CompositeExitManager(store: store, callCompositeEventsHandler: callCompositeEventsHandler)
        self.lifeCycleManager = UIKitAppLifeCycleManager(store: store, logger: logger)
        self.permissionManager = PermissionsManager(store: store)
        self.audioSessionManager = audioSessionManager
        self.remoteParticipantsManager = RemoteParticipantsManager(
            store: store,
            callCompositeEventsHandler: callCompositeEventsHandler,
            avatarViewManager: avatarViewManager
        )
        let debugInfoManager = createDebugInfoManager(callingSDKWrapper: callingSdkWrapper)
        self.debugInfoManager = debugInfoManager
        let videoViewManager = VideoViewManager(callingSDKWrapper: callingSdkWrapper, logger: logger)
        self.videoViewManager = videoViewManager
        if enableSystemPipWhenMultitasking {
            self.pipManager = createPipManager(store)
        }
        if(self.callScreenHeaderOptions?.callDurationTimer != nil) {
            self.callScreenHeaderOptions?.callDurationTimer?.callTimerAPI = CallDurationManager()
        }

        self.callHistoryService = CallHistoryService(store: store, callHistoryRepository: self.callHistoryRepository)

        let captionsViewManager = CaptionsViewManager(
            store: store,
            callingSDKWrapper: callingSdkWrapper
        )
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
                captionsViewManager: captionsViewManager,
                localOptions: localOptions,
                enableMultitasking: enableMultitasking,
                enableSystemPipWhenMultitasking: enableSystemPipWhenMultitasking,
                eventsHandler: events,
                leaveCallConfirmationMode: leaveCallConfirmationMode,
                callType: callConfiguration.compositeCallType,
                setupScreenOptions: setupScreenOptions,
                capabilitiesManager: CapabilitiesManager(callType: callConfiguration.compositeCallType),
                avatarManager: avatarViewManager,
                callScreenHeaderOptions: callScreenHeaderOptions!,
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
        self.callingSDKWrapper?.dispose()
        self.callingSDKWrapper = nil
        self.callDurationManager = nil
    }

    private func disposeSDKWrappers() {
        self.callingSDKEventsHandler = nil
        self.callingSDKWrapper = nil
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

    private func getCallingSDKInitializer() -> CallingSDKInitializer {
        if let callingSDKInitializer = callingSDKInitializer {
            return callingSDKInitializer
        }
        guard let credential = credential else {
            if let didFail = events.onError {
                let compositeError = CallCompositeError(
                    code: CallCompositeErrorCode.communicationTokenCredentialNotSet,
                    error: CommunicationTokenCredentialError.communicationTokenCredentialNotSet)
                didFail(compositeError)
            }
            fatalError("CommunicationTokenCredential cannot be nil, use init with credentials.")
        }
        let callingSDKInitializer = CallingSDKInitializer(tags: self.callConfiguration?.diagnosticConfig.tags
                                                          ?? DiagnosticConfig().tags,
                                                          credential: credential,
                                                          callKitOptions: callKitOptions,
                                                          displayName: displayName,
                                                          disableInternalPushForIncomingCall:
                                                            disableInternalPushForIncomingCall,
                                                          logger: logger,
                                                          events: events,
                                                          onCallAdded: onCallAdded)
        self.callingSDKInitializer = callingSDKInitializer
        return callingSDKInitializer
    }
}
// swiftlint:enable function_body_length
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
            self?.logger.debug( "CallComposite setDismissComposite")
            self?.disposeSDKWrappers()
            self?.callStateManager?.onCompositeExit()
            self?.viewController = nil
            self?.pipViewController = nil
            self?.viewFactory = nil
            UIApplication.shared.isIdleTimerDisabled = false
            let exitManagerCache = self?.exitManager
            self?.cleanUpManagers()
            if let hostingController = containerUIHostingController {
                hostingController.dismissSelf {
                    self?.videoViewManager?.disposeViews()
                    self?.logger.debug( "CallComposite hostingController dismissed")
                    self?.compositeUILaunched = false
                    exitManagerCache?.onDismissed()
                    self?.notifyOnCallKitCallAccepted()
                }
            } else {
                self?.videoViewManager?.disposeViews()
                self?.compositeUILaunched = false
                exitManagerCache?.onDismissed()
                self?.notifyOnCallKitCallAccepted()
            }
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
// swiftlint:enable type_body_length
