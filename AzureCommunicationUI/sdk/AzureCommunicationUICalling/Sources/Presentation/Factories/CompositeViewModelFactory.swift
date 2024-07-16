//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import FluentUI
import Foundation
import SwiftUI

// swiftlint:disable file_length
class CompositeViewModelFactory: CompositeViewModelFactoryProtocol {
    private let logger: Logger
    private let store: Store<AppState, Action>
    private let networkManager: NetworkManager
    private let audioSessionManager: AudioSessionManagerProtocol
    private let accessibilityProvider: AccessibilityProviderProtocol
    private let localizationProvider: LocalizationProviderProtocol
    private let debugInfoManager: DebugInfoManagerProtocol
    private let captionsViewManager: CaptionsViewManager
    private let events: CallComposite.Events
    private let localOptions: LocalOptions?
    private let enableMultitasking: Bool
    private let enableSystemPipWhenMultitasking: Bool
    private let capabilitiesManager: CapabilitiesManager
    private let avatarManager: AvatarViewManagerProtocol
    private let retrieveLogFiles: () -> [URL]
    private weak var setupViewModel: SetupViewModel?
    private weak var callingViewModel: CallingViewModel?
    private var leaveCallConfirmationMode: LeaveCallConfirmationMode?
    private let setupScreenOptions: SetupScreenOptions?
    private let callType: CompositeCallType

    init(logger: Logger,
         store: Store<AppState, Action>,
         networkManager: NetworkManager,
         audioSessionManager: AudioSessionManagerProtocol,
         localizationProvider: LocalizationProviderProtocol,
         accessibilityProvider: AccessibilityProviderProtocol,
         debugInfoManager: DebugInfoManagerProtocol,
         captionsViewManager: CaptionsViewManager,
         localOptions: LocalOptions? = nil,
         enableMultitasking: Bool,
         enableSystemPipWhenMultitasking: Bool,
         eventsHandler: CallComposite.Events,
         leaveCallConfirmationMode: LeaveCallConfirmationMode,
         retrieveLogFiles: @escaping () -> [URL],
         callType: CompositeCallType,
         setupScreenOptions: SetupScreenOptions?,
         capabilitiesManager: CapabilitiesManager,
         avatarManager: AvatarViewManagerProtocol
    ) {

        self.logger = logger
        self.store = store
        self.networkManager = networkManager
        self.audioSessionManager = audioSessionManager
        self.accessibilityProvider = accessibilityProvider
        self.localizationProvider = localizationProvider
        self.debugInfoManager = debugInfoManager
        self.captionsViewManager = captionsViewManager
        self.events = eventsHandler
        self.localOptions = localOptions
        self.enableMultitasking = enableMultitasking
        self.enableSystemPipWhenMultitasking = enableSystemPipWhenMultitasking
        self.retrieveLogFiles = retrieveLogFiles
        self.leaveCallConfirmationMode = leaveCallConfirmationMode
        self.setupScreenOptions = setupScreenOptions
        self.capabilitiesManager = capabilitiesManager
        self.callType = callType
        self.avatarManager = avatarManager
    }

    func makeLeaveCallConfirmationViewModel(
        endCall: @escaping (() -> Void),
        dismissConfirmation: @escaping (() -> Void)) -> LeaveCallConfirmationViewModel {
        return LeaveCallConfirmationViewModel(
            state: store.state,
            localizationProvider: localizationProvider,
            endCall: endCall,
            dismissConfirmation: dismissConfirmation)
    }

    func makeLeaveCallConfirmationViewModel(
        endCall: @escaping (() -> Void),
        dismissConfirmation: @escaping (() -> Void)) -> LeaveCallConfirmationViewModel {
        return LeaveCallConfirmationViewModel(
            state: store.state,
            localizationProvider: localizationProvider,
            endCall: endCall,
            dismissConfirmation: dismissConfirmation)
    }

    func makeSupportFormViewModel() -> SupportFormViewModel {
        return SupportFormViewModel(
            isDisplayed: store.state.navigationState.supportFormVisible
            && store.state.visibilityState.currentStatus == .visible,
            dispatchAction: store.dispatch,
                                    events: events,
                                    localizationProvider: localizationProvider,
                                    getDebugInfo: { [self] in self.debugInfoManager.getDebugInfo() })
    }

    // MARK: CompositeViewModels
    func getSetupViewModel() -> SetupViewModel {
        guard let viewModel = self.setupViewModel else {
            let viewModel = SetupViewModel(compositeViewModelFactory: self,
                                           logger: logger,
                                           store: store,
                                           networkManager: networkManager,
                                           audioSessionManager: audioSessionManager,
                                           localizationProvider: localizationProvider,
                                           setupScreenViewData: localOptions?.setupScreenViewData,
                                           callType: callType)
            self.setupViewModel = viewModel
            self.callingViewModel = nil
            return viewModel
        }
        return viewModel
    }

    func getCallingViewModel() -> CallingViewModel {
        guard let viewModel = self.callingViewModel else {
            let viewModel = CallingViewModel(compositeViewModelFactory: self,
                                             logger: logger,
                                             store: store,
                                             localizationProvider: localizationProvider,
                                             accessibilityProvider: accessibilityProvider,
                                             isIpadInterface: UIDevice.current.userInterfaceIdiom == .pad,
                                             allowLocalCameraPreview: localOptions?.audioVideoMode
                                            != CallCompositeAudioVideoMode.audioOnly,
                                            leaveCallConfirmationMode: self.leaveCallConfirmationMode ?? .alwaysEnabled,
                                            callType: callType,
                                            captionsOptions: localOptions?.captionsOptions ?? CaptionsOptions(),
                                            capabilitiesManager: self.capabilitiesManager)
            self.setupViewModel = nil
            self.callingViewModel = viewModel
            return viewModel
        }
        return viewModel
    }

    // MARK: ComponentViewModels
    func makeIconButtonViewModel(iconName: CompositeIcon,
                                 buttonType: IconButtonViewModel.ButtonType = .controlButton,
                                 isDisabled: Bool,
                                 action: @escaping (() -> Void)) -> IconButtonViewModel {
        IconButtonViewModel(iconName: iconName,
                            buttonType: buttonType,
                            isDisabled: isDisabled,
                            action: action)
    }

    func makeIconWithLabelButtonViewModel<T: ButtonState>(
        selectedButtonState: T,
        localizationProvider: LocalizationProviderProtocol,
        buttonTypeColor: IconWithLabelButtonViewModel<T>.ButtonTypeColor,
        isDisabled: Bool,
        action: @escaping (() -> Void)) -> IconWithLabelButtonViewModel<T> {
            IconWithLabelButtonViewModel(
                selectedButtonState: selectedButtonState,
                localizationProvider: localizationProvider,
                buttonTypeColor: buttonTypeColor,
                isDisabled: isDisabled,
                action: action)
    }

    func makeLocalVideoViewModel(dispatchAction: @escaping ActionDispatch) -> LocalVideoViewModel {
        LocalVideoViewModel(compositeViewModelFactory: self,
                            logger: logger,
                            localizationProvider: localizationProvider,
                            dispatchAction: dispatchAction)
    }

    func makePrimaryButtonViewModel(buttonStyle: FluentUI.ButtonStyle,
                                    buttonLabel: String,
                                    iconName: CompositeIcon?,
                                    isDisabled: Bool = false,
                                    paddings: CompositeButton.Paddings? = nil,
                                    action: @escaping (() -> Void)) -> PrimaryButtonViewModel {
        PrimaryButtonViewModel(buttonStyle: buttonStyle,
                               buttonLabel: buttonLabel,
                               iconName: iconName,
                               isDisabled: isDisabled,
                               paddings: paddings,
                               action: action)
    }

    func makeAudioDevicesListViewModel(dispatchAction: @escaping ActionDispatch,
                                       localUserState: LocalUserState) -> AudioDevicesListViewModel {
        AudioDevicesListViewModel(compositeViewModelFactory: self,
                                  dispatchAction: dispatchAction,
                                  localUserState: localUserState,
                                  localizationProvider: localizationProvider)
    }

    func makeCaptionsLanguageListViewModel(dispatchAction: @escaping ActionDispatch,
                                           state: AppState
    ) -> CaptionsLanguageListViewModel {
        CaptionsLanguageListViewModel(compositeViewModelFactory: self,
                                      dispatchAction: dispatchAction,
                                      state: state,
                                      localizationProvider: localizationProvider)
    }

    func makeCaptionsListViewModel(state: AppState,
                                   captionsOptions: CaptionsOptions,
                                   dispatchAction: @escaping ActionDispatch,
                                   showSpokenLanguage: @escaping () -> Void,
                                   showCaptionsLanguage: @escaping () -> Void,
                                   isDisplayed: Bool) -> CaptionsListViewModel {

        return CaptionsListViewModel(compositeViewModelFactory: self,
                                     localizationProvider: localizationProvider,
                                     captionsOptions: captionsOptions,
                                     state: state,
                                     dispatchAction: dispatchAction,
                                     showSpokenLanguage: showSpokenLanguage,
                                     showCaptionsLanguage: showCaptionsLanguage,
                                     isDisplayed: store.state.navigationState.captionsViewVisible
                                     && store.state.visibilityState.currentStatus == .visible)
    }

    func makeCaptionsInfoViewModel(state: AppState) -> CaptionsInfoViewModel {
        return CaptionsInfoViewModel(state: state,
                                     captionsManager: captionsViewManager,
                                     localizationProvider: localizationProvider)
    }

    func makeCaptionsErrorViewModel(dispatchAction: @escaping ActionDispatch)
    -> CaptionsErrorViewModel {
        CaptionsErrorViewModel(compositeViewModelFactory: self,
                                  logger: logger,
                                  localizationProvider: localizationProvider,
                                  accessibilityProvider: accessibilityProvider,
                                  dispatchAction: dispatchAction)
    }

    func makeSelectableDrawerListItemViewModel(icon: CompositeIcon,
                                               title: String,
                                               isSelected: Bool,
                                               onSelectedAction: @escaping (() -> Void)) ->
    SelectableDrawerListItemViewModel {
        SelectableDrawerListItemViewModel(icon: icon,
                                          title: title,
                                          accessibilityIdentifier: "",
                                          isSelected: isSelected,
                                          action: onSelectedAction)
    }

    func makeErrorInfoViewModel(title: String,
                                subtitle: String) -> ErrorInfoViewModel {
        ErrorInfoViewModel(localizationProvider: localizationProvider,
                           title: title,
                           subtitle: subtitle)
    }
}

extension CompositeViewModelFactory {
    func makeCallDiagnosticsViewModel(dispatchAction: @escaping ActionDispatch) -> CallDiagnosticsViewModel {
        CallDiagnosticsViewModel(localizationProvider: localizationProvider,
                                 accessibilityProvider: accessibilityProvider,
                                 dispatchAction: dispatchAction)
    }

    // MARK: CallingViewModels
    func makeLobbyOverlayViewModel() -> LobbyOverlayViewModel {
        LobbyOverlayViewModel(localizationProvider: localizationProvider,
                              accessibilityProvider: accessibilityProvider)
    }
    func makeLoadingOverlayViewModel() -> LoadingOverlayViewModel {
        LoadingOverlayViewModel(localizationProvider: localizationProvider,
                                accessibilityProvider: accessibilityProvider,
                                networkManager: networkManager,
                                audioSessionManager: audioSessionManager,
                                store: store,
                                callType: callType)
    }
    func makeOnHoldOverlayViewModel(resumeAction: @escaping (() -> Void)) -> OnHoldOverlayViewModel {
        OnHoldOverlayViewModel(localizationProvider: localizationProvider,
                               compositeViewModelFactory: self,
                               logger: logger,
                               accessibilityProvider: accessibilityProvider,
                               audioSessionManager: audioSessionManager,
                               resumeAction: resumeAction)
    }
    func makeControlBarViewModel(dispatchAction: @escaping ActionDispatch,
                                 onEndCallTapped: @escaping (() -> Void),
                                 localUserState: LocalUserState,
                                 leaveCallConfirmationMode: LeaveCallConfirmationMode = .alwaysEnabled,
                                 capabilitiesManager: CapabilitiesManager)
    -> ControlBarViewModel {
        ControlBarViewModel(compositeViewModelFactory: self,
                            logger: logger,
                            localizationProvider: localizationProvider,
                            dispatchAction: dispatchAction,
                            onEndCallTapped: onEndCallTapped,
                            localUserState: localUserState,
                            audioVideoMode: localOptions?.audioVideoMode ?? .audioAndVideo,
                            leaveCallConfirmationMode: self.leaveCallConfirmationMode ?? .alwaysEnabled,
                            capabilitiesManager: capabilitiesManager)
    }

    func makeInfoHeaderViewModel(dispatchAction: @escaping ActionDispatch,
                                 localUserState: LocalUserState) -> InfoHeaderViewModel {
        InfoHeaderViewModel(compositeViewModelFactory: self,
                            logger: logger,
                            localUserState: localUserState,
                            localizationProvider: localizationProvider,
                            accessibilityProvider: accessibilityProvider,
                            dispatchAction: dispatchAction,
                            enableMultitasking: enableMultitasking,
                            enableSystemPipWhenMultitasking: enableSystemPipWhenMultitasking)
    }

    func makeLobbyWaitingHeaderViewModel(localUserState: LocalUserState,
                                         dispatchAction: @escaping ActionDispatch) -> LobbyWaitingHeaderViewModel {
        LobbyWaitingHeaderViewModel(compositeViewModelFactory: self,
                                    logger: logger,
                                    localUserState: localUserState,
                                    localizationProvider: localizationProvider,
                                    accessibilityProvider: accessibilityProvider,
                                    dispatchAction: dispatchAction)
    }

    func makeLobbyActionErrorViewModel(localUserState: LocalUserState,
                                       dispatchAction: @escaping ActionDispatch) -> LobbyErrorHeaderViewModel {
        LobbyErrorHeaderViewModel(compositeViewModelFactory: self,
                                  logger: logger,
                                  localUserState: localUserState,
                                  localizationProvider: localizationProvider,
                                  accessibilityProvider: accessibilityProvider,
                                  dispatchAction: dispatchAction)
    }

    func makeParticipantCellViewModel(participantModel: ParticipantInfoModel,
                                      lifeCycleState: LifeCycleState) -> ParticipantGridCellViewModel {
        ParticipantGridCellViewModel(localizationProvider: localizationProvider,
                                     accessibilityProvider: accessibilityProvider,
                                     participantModel: participantModel,
                                     lifeCycleState: lifeCycleState,
                                     isCameraEnabled: localOptions?.audioVideoMode != .audioOnly,
                                     callType: callType)
    }

    func makeParticipantGridsViewModel(isIpadInterface: Bool) -> ParticipantGridViewModel {
        ParticipantGridViewModel(compositeViewModelFactory: self,
                                 localizationProvider: localizationProvider,
                                 accessibilityProvider: accessibilityProvider,
                                 isIpadInterface: isIpadInterface,
                                 callType: callType)
    }

    func makeParticipantsListViewModel(localUserState: LocalUserState,
                                       isDisplayed: Bool,
                                       dispatchAction: @escaping ActionDispatch) -> ParticipantsListViewModel {
        ParticipantsListViewModel(compositeViewModelFactory: self,
                                  localUserState: localUserState,
                                  dispatchAction: dispatchAction,
                                  localizationProvider: localizationProvider,
                                  onUserClicked: { participant in
            dispatchAction(Action.showParticipantActions(participant))
        },
        avatarManager: avatarManager)
    }

    func makeParticipantMenuViewModel(localUserState: LocalUserState,
                                      isDisplayed: Bool,
                                      dispatchAction: @escaping ActionDispatch) -> ParticipantMenuViewModel {
        ParticipantMenuViewModel(compositeViewModelFactory: self,
                                 localUserState: localUserState,
                                 localizationProvider: localizationProvider,
                                 capabilitiesManager: capabilitiesManager,
                                 onRemoveUser: { user in
            dispatchAction(.remoteParticipantsAction(.remove(participantId: user.userIdentifier)))
            dispatchAction(.hideDrawer)
        },
                                 isDisplayed: isDisplayed)
    }

    func makeBannerViewModel() -> BannerViewModel {
        BannerViewModel(compositeViewModelFactory: self)
    }

    func makeBannerTextViewModel() -> BannerTextViewModel {
        BannerTextViewModel(accessibilityProvider: accessibilityProvider,
                            localizationProvider: localizationProvider)
    }

    func makeMoreCallOptionsListViewModel(
        isDisplayed: Bool,
        isCaptionsAvailable: Bool,
        showSharingViewAction: @escaping () -> Void,
        showSupportFormAction: @escaping () -> Void,
        showCaptionsViewAction: @escaping () -> Void) -> MoreCallOptionsListViewModel {

        // events.onUserReportedIssue
        return MoreCallOptionsListViewModel(compositeViewModelFactory: self,
                                     localizationProvider: localizationProvider,
                                     showSharingViewAction: showSharingViewAction,
                                     showSupportFormAction: showSupportFormAction,
                                     showCaptionsViewAction: showCaptionsViewAction,
                                     isCaptionsAvailable: isCaptionsAvailable,
                                     isSupportFormAvailable: events.onUserReportedIssue != nil,
                                     isDisplayed: isDisplayed)
    }

    func makeDrawerListItemViewModel(icon: CompositeIcon,
                                     title: String,
                                     accessibilityIdentifier: String,
                                     titleTrailingAccessoryView: CompositeIcon? =
        .rightChevron,
                                     action: @escaping (() -> Void)) -> DrawerListItemViewModel {
        DrawerListItemViewModel(icon: icon,
                                title: title,
                                accessibilityIdentifier: accessibilityIdentifier,
                                titleTrailingAccessoryView: titleTrailingAccessoryView,
                                action: action)
    }

    func makeLanguageListItemViewModel(icon: CompositeIcon,
                                       title: String,
                                       subtitle: String?,
                                       accessibilityIdentifier: String,
                                       titleTrailingAccessoryView: CompositeIcon?,
                                       isEnabled: Bool?,
                                       action: @escaping (() -> Void)) -> DrawerListItemViewModel {
        DrawerListItemViewModel(icon: icon,
                                title: title,
                                subtitle: subtitle,
                                accessibilityIdentifier: accessibilityIdentifier,
                                titleTrailingAccessoryView: titleTrailingAccessoryView,
                                isEnabled: isEnabled,
                                action: action)

    }

    func makeToggleListItemViewModel(icon: CompositeIcon,
                                     title: String,
                                     isToggleOn: Binding<Bool>,
                                     showToggle: Bool,
                                     accessibilityIdentifier: String,
                                     action: @escaping (() -> Void)) -> DrawerListItemViewModel {
        DrawerListItemViewModel(icon: icon,
                                title: title,
                                accessibilityIdentifier: accessibilityIdentifier,
                                isToggleOn: isToggleOn,
                                showToggle: showToggle,
                                action: action)
                                     action: @escaping (() -> Void)) -> DrawerGenericItemViewModel {
        DrawerGenericItemViewModel(title: title,
                                accessibilityIdentifier: accessibilityIdentifier,
                                action: action,
                                startIcon: icon)
    }

    func makeDrawerListItemViewModel(icon: CompositeIcon,
                                     title: String,
                                     accessibilityIdentifier: String) -> DrawerGenericItemViewModel {
        DrawerGenericItemViewModel(title: title,
                                accessibilityIdentifier: accessibilityIdentifier,
                                action: nil,
                                startIcon: icon)
    }

    func makeDebugInfoSharingActivityViewModel() -> DebugInfoSharingActivityViewModel {
        DebugInfoSharingActivityViewModel(accessibilityProvider: accessibilityProvider,
                                          debugInfoManager: debugInfoManager) {
            self.store.dispatch(action: .hideDrawer)
        }
    }

    func makeBottomToastViewModel(toastNotificationState: ToastNotificationState,
                                  dispatchAction: @escaping ActionDispatch) -> BottomToastViewModel {
        BottomToastViewModel(dispatchAction: dispatchAction,
                             localizationProvider: localizationProvider,
                             accessibilityProvider: accessibilityProvider,
                             toastNotificationState: toastNotificationState)
    }

    // MARK: SetupViewModels
    func makePreviewAreaViewModel(dispatchAction: @escaping ActionDispatch) -> PreviewAreaViewModel {
        PreviewAreaViewModel(compositeViewModelFactory: self,
                             dispatchAction: dispatchAction,
                             localizationProvider: localizationProvider)
    }

    func makeSetupControlBarViewModel(dispatchAction: @escaping ActionDispatch,
                                      localUserState: LocalUserState) -> SetupControlBarViewModel {
        let audioVideoMode = localOptions?.audioVideoMode ?? CallCompositeAudioVideoMode.audioAndVideo

        return SetupControlBarViewModel(compositeViewModelFactory: self,
                                 logger: logger,
                                 dispatchAction: dispatchAction,
                                 localUserState: localUserState,
                                 localizationProvider: localizationProvider,
                                 audioVideoMode: audioVideoMode,
                                 setupScreenOptions: setupScreenOptions)
    }

    func makeJoiningCallActivityViewModel() -> JoiningCallActivityViewModel {
        JoiningCallActivityViewModel(title: self.localizationProvider.getLocalizedString(LocalizationKey.joiningCall))
    }
}
