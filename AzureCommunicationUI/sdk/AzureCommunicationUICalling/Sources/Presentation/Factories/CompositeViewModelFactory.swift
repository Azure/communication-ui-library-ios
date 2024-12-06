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
    private let captionsRttViewManager: CaptionsAndRttViewManager
    private let events: CallComposite.Events
    private let localOptions: LocalOptions?
    private let enableMultitasking: Bool
    private let enableSystemPipWhenMultitasking: Bool
    private let capabilitiesManager: CapabilitiesManager
    private let avatarManager: AvatarViewManagerProtocol
    private let retrieveLogFiles: () -> [URL]
    private weak var setupViewModel: SetupViewModel?
    private weak var callingViewModel: CallingViewModel?
    private let setupScreenOptions: SetupScreenOptions?
    private let callScreenOptions: CallScreenOptions?
    private let callType: CompositeCallType
    /* <CUSTOM_COLOR_FEATURE> */
    private let themeOptions: ThemeOptions
    /* </CUSTOM_COLOR_FEATURE> */
    private let updatableOptionsManager: UpdatableOptionsManagerProtocol

    init(logger: Logger,
         store: Store<AppState, Action>,
         networkManager: NetworkManager,
         audioSessionManager: AudioSessionManagerProtocol,
         localizationProvider: LocalizationProviderProtocol,
         accessibilityProvider: AccessibilityProviderProtocol,
         debugInfoManager: DebugInfoManagerProtocol,
         captionsViewManager: CaptionsAndRttViewManager,
         localOptions: LocalOptions? = nil,
         enableMultitasking: Bool,
         enableSystemPipWhenMultitasking: Bool,
         eventsHandler: CallComposite.Events,
         leaveCallConfirmationMode: LeaveCallConfirmationMode,
         callType: CompositeCallType,
         setupScreenOptions: SetupScreenOptions?,
         callScreenOptions: CallScreenOptions?,
         capabilitiesManager: CapabilitiesManager,
         avatarManager: AvatarViewManagerProtocol,
         /* <CUSTOM_COLOR_FEATURE> */
         themeOptions: ThemeOptions,
         /* </CUSTOM_COLOR_FEATURE> */
         updatableOptionsManager: UpdatableOptionsManagerProtocol,
         retrieveLogFiles: @escaping () -> [URL]
         ) {
        self.logger = logger
        self.store = store
        self.networkManager = networkManager
        self.audioSessionManager = audioSessionManager
        self.accessibilityProvider = accessibilityProvider
        self.localizationProvider = localizationProvider
        self.debugInfoManager = debugInfoManager
        self.captionsRttViewManager = captionsViewManager
        self.events = eventsHandler
        self.localOptions = localOptions
        self.enableMultitasking = enableMultitasking
        self.enableSystemPipWhenMultitasking = enableSystemPipWhenMultitasking
        self.retrieveLogFiles = retrieveLogFiles
        self.setupScreenOptions = setupScreenOptions
        self.callScreenOptions = callScreenOptions
        self.capabilitiesManager = capabilitiesManager
        self.callType = callType
        /* <CUSTOM_COLOR_FEATURE> */
        self.themeOptions = themeOptions
        /* </CUSTOM_COLOR_FEATURE> */
        self.avatarManager = avatarManager
        self.updatableOptionsManager = updatableOptionsManager
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

    func getCallingViewModel(rendererViewManager: RendererViewManager) -> CallingViewModel {
        guard let viewModel = self.callingViewModel else {
            let viewModel = CallingViewModel(compositeViewModelFactory: self,
                                             store: store,
                                             localizationProvider: localizationProvider,
                                             accessibilityProvider: accessibilityProvider,
                                             isIpadInterface: UIDevice.current.userInterfaceIdiom == .pad,
                                             allowLocalCameraPreview: localOptions?.audioVideoMode
                                                != CallCompositeAudioVideoMode.audioOnly,
                                             callType: callType,
                                             captionsOptions: localOptions?.captionsOptions ?? CaptionsOptions(),
                                             capabilitiesManager: self.capabilitiesManager,
                                             callScreenOptions: callScreenOptions ?? CallScreenOptions(),
                                             rendererViewManager: rendererViewManager)
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

    func makeIconButtonViewModel(iconName: CompositeIcon,
                                 buttonType: IconButtonViewModel.ButtonType = .controlButton,
                                 isDisabled: Bool,
                                 isVisible: Bool,
                                 action: @escaping (() -> Void)) -> IconButtonViewModel {
        IconButtonViewModel(iconName: iconName,
                            buttonType: buttonType,
                            isDisabled: isDisabled,
                            isVisible: isVisible,
                            action: action)
    }
    func makeIconButtonViewModel(icon: UIImage,
                                 buttonType: IconButtonViewModel.ButtonType = .controlButton,
                                 isDisabled: Bool,
                                 isVisible: Bool,
                                 action: @escaping (() -> Void)) -> IconButtonViewModel {
        IconButtonViewModel(icon: icon,
                            buttonType: buttonType,
                            isDisabled: isDisabled,
                            isVisible: isVisible,
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
                               themeOptions: themeOptions,
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
                                   buttonActions: ButtonActions,
                                   isRttAvailable: Bool,
                                   isDisplayed: Bool) -> CaptionsListViewModel {

        return CaptionsListViewModel(compositeViewModelFactory: self,
                                     localizationProvider: localizationProvider,
                                     captionsOptions: captionsOptions,
                                     state: state,
                                     dispatchAction: dispatchAction,
                                     buttonActions: buttonActions,
                                     isRttAvailable: isRttAvailable,
                                     isDisplayed: store.state.navigationState.captionsViewVisible
                                     && store.state.visibilityState.currentStatus == .visible)
    }

    func makeCaptionsRttInfoViewModel(state: AppState,
                                      captionsOptions: CaptionsOptions) -> CaptionsAndRttInfoViewModel {
        return CaptionsAndRttInfoViewModel(state: state,
                                     captionsManager: captionsRttViewManager,
                                     captionsOptions: captionsOptions,
                                     dispatch: store.dispatch,
                                     localizationProvider: localizationProvider)
    }

    func makeCaptionsErrorViewModel(dispatchAction: @escaping ActionDispatch)
    -> CaptionsErrorViewModel {
        return CaptionsErrorViewModel(compositeViewModelFactory: self,
                                  logger: logger,
                                  localizationProvider: localizationProvider,
                                  accessibilityProvider: accessibilityProvider,
                                  dispatchAction: dispatchAction)
    }

    func makeCaptionsLangaugeCellViewModel(title: String,
                                           isSelected: Bool,
                                           accessibilityLabel: String,
                                           onSelectedAction: @escaping (() -> Void)) -> DrawerSelectableItemViewModel {
        return DrawerSelectableItemViewModel(icon: nil,
                                      title: title,
                                      accessibilityIdentifier: "",
                                             accessibilityLabel: accessibilityLabel,
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
                                themeOptions: themeOptions,
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
                                 capabilitiesManager: CapabilitiesManager,
                                 buttonViewDataState: ButtonViewDataState)
    -> ControlBarViewModel {
        ControlBarViewModel(compositeViewModelFactory: self,
                            logger: logger,
                            localizationProvider: localizationProvider,
                            dispatchAction: dispatchAction,
                            onEndCallTapped: onEndCallTapped,
                            localUserState: localUserState,
                            accessibilityProvider: accessibilityProvider,
                            audioVideoMode: localOptions?.audioVideoMode ?? .audioAndVideo,
                            capabilitiesManager: capabilitiesManager,
                            controlBarOptions: callScreenOptions?.controlBarOptions,
                            buttonViewDataState: buttonViewDataState)
    }

    func makeInfoHeaderViewModel(dispatchAction: @escaping ActionDispatch,
                                 localUserState: LocalUserState,
                                 callScreenInfoHeaderState: CallScreenInfoHeaderState,
                                 buttonViewDataState: ButtonViewDataState,
                                 controlHeaderViewData: CallScreenHeaderViewData?
    ) -> InfoHeaderViewModel {
        InfoHeaderViewModel(compositeViewModelFactory: self,
                            logger: logger,
                            localUserState: localUserState,
                            localizationProvider: localizationProvider,
                            accessibilityProvider: accessibilityProvider,
                            dispatchAction: dispatchAction,
                            enableMultitasking: enableMultitasking,
                            enableSystemPipWhenMultitasking: enableSystemPipWhenMultitasking,
                            callScreenInfoHeaderState: callScreenInfoHeaderState,
                            buttonViewDataState: buttonViewDataState,
                            controlHeaderViewData: controlHeaderViewData
        )
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

    func makeParticipantCellViewModel(participantModel: ParticipantInfoModel) -> ParticipantGridCellViewModel {
        ParticipantGridCellViewModel(localizationProvider: localizationProvider,
                                     accessibilityProvider: accessibilityProvider,
                                     participantModel: participantModel,
                                     isCameraEnabled: localOptions?.audioVideoMode != .audioOnly,
                                     captionsRttManager: captionsRttViewManager,
                                     callType: callType)
    }

    func makeParticipantGridsViewModel(isIpadInterface: Bool,
                                       rendererViewManager: RendererViewManager) -> ParticipantGridViewModel {
        ParticipantGridViewModel(compositeViewModelFactory: self,
                                 localizationProvider: localizationProvider,
                                 accessibilityProvider: accessibilityProvider,
                                 isIpadInterface: isIpadInterface,
                                 callType: callType,
                                 rendererViewManager: rendererViewManager)
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

    func makeBannerViewModel(dispatchAction: @escaping ActionDispatch) -> BannerViewModel {
        BannerViewModel(compositeViewModelFactory: self, dispatchAction: dispatchAction)
    }

    func makeBannerTextViewModel() -> BannerTextViewModel {
        BannerTextViewModel(accessibilityProvider: accessibilityProvider,
                            localizationProvider: localizationProvider)
    }

    func makeMoreCallOptionsListViewModel(
        isCaptionsAvailable: Bool,
        buttonActions: ButtonActions,
        controlBarOptions: CallScreenControlBarOptions?,
        buttonViewDataState: ButtonViewDataState,
        dispatchAction: @escaping ActionDispatch) -> MoreCallOptionsListViewModel {

        // events.onUserReportedIssue
        return MoreCallOptionsListViewModel(compositeViewModelFactory: self,
                                            localizationProvider: localizationProvider,
                                            buttonActions: buttonActions,
                                            controlBarOptions: controlBarOptions,
                                            isCaptionsAvailable: isCaptionsAvailable,
                                            isSupportFormAvailable: events.onUserReportedIssue != nil,
                                            buttonViewDataState: buttonViewDataState,
                                            dispatchAction: dispatchAction)
    }

    func makeLanguageListItemViewModel(title: String,
                                       subtitle: String?,
                                       accessibilityIdentifier: String,
                                       startIcon: CompositeIcon,
                                       endIcon: CompositeIcon?,
                                       isEnabled: Bool,
                                       action: @escaping (() -> Void)) -> DrawerGenericItemViewModel {
        DrawerGenericItemViewModel(title: title,
                                subtitle: subtitle,
                                accessibilityIdentifier: accessibilityIdentifier,
                                   accessibilityTraits: .isButton,
                                   action: action,
                                   startCompositeIcon: startIcon,
                                   endIcon: endIcon,
                                   isEnabled: isEnabled)
    }

    func makeToggleListItemViewModel(title: String,
                                     isToggleOn: Binding<Bool>,
                                     showToggle: Bool,
                                     accessibilityIdentifier: String,
                                     startIcon: CompositeIcon,
                                     isEnabled: Bool,
                                     action: @escaping (() -> Void)) -> DrawerGenericItemViewModel {
        DrawerGenericItemViewModel(title: title,
                                   accessibilityIdentifier: accessibilityIdentifier,
                                   action: action,
                                   startCompositeIcon: startIcon,
                                   showToggle: showToggle,
                                   isToggleOn: isToggleOn,
                                   isEnabled: isEnabled)
    }

    func makeDrawerListItemViewModel(icon: CompositeIcon,
                                     title: String,
                                     accessibilityIdentifier: String) -> DrawerGenericItemViewModel {
        DrawerGenericItemViewModel(title: title,
                                accessibilityIdentifier: accessibilityIdentifier,
                                action: nil,
                                startCompositeIcon: icon)
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
                                      localUserState: LocalUserState,
                                      buttonViewDataState: ButtonViewDataState) -> SetupControlBarViewModel {
        let audioVideoMode = localOptions?.audioVideoMode ?? CallCompositeAudioVideoMode.audioAndVideo

        return SetupControlBarViewModel(compositeViewModelFactory: self,
                                        logger: logger,
                                        dispatchAction: dispatchAction,
                                        updatableOptionsManager: updatableOptionsManager,
                                        localUserState: localUserState,
                                        localizationProvider: localizationProvider,
                                        audioVideoMode: audioVideoMode,
                                        setupScreenOptions: setupScreenOptions,
                                        buttonViewDataState: buttonViewDataState)
    }

    func makeJoiningCallActivityViewModel() -> JoiningCallActivityViewModel {
        JoiningCallActivityViewModel(title: self.localizationProvider.getLocalizedString(LocalizationKey.joiningCall))
    }
}
