//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import FluentUI
@testable import AzureCommunicationUICalling
import SwiftUI

struct CompositeViewModelFactoryMocking: CompositeViewModelFactoryProtocol {
    private let logger: Logger
    private let store: Store<AppState, Action>
    private let accessibilityProvider: AccessibilityProviderProtocol
    private let localizationProvider: LocalizationProviderProtocol
    private let debugInfoManager: DebugInfoManagerProtocol
    private let capabilitiesManager: CapabilitiesManager

    var bannerTextViewModel: BannerTextViewModel?
    var controlBarViewModel: ControlBarViewModel?
    var infoHeaderViewModel: InfoHeaderViewModel?
    var lobbyWaitingHeaderViewModel: LobbyWaitingHeaderViewModel?
    var lobbyErrorHeaderViewModel: LobbyErrorHeaderViewModel?
    var localVideoViewModel: LocalVideoViewModel?
    var participantGridViewModel: ParticipantGridViewModel?
    var participantsListViewModel: ParticipantsListViewModel?
    var bannerViewModel: BannerViewModel?
    var onHoldOverlayViewModel: OnHoldOverlayViewModel?
    var previewAreaViewModel: PreviewAreaViewModel?
    var setupControlBarViewModel: SetupControlBarViewModel?
    var errorInfoViewModel: ErrorInfoViewModel?
    var callDiagnosticsViewModel: CallDiagnosticsViewModel?
    var lobbyOverlayViewModel: LobbyOverlayViewModel?
    var loadingOverlayViewModel: LoadingOverlayViewModel?
    var audioDevicesListViewModel: AudioDevicesListViewModel?
    var primaryButtonViewModel: PrimaryButtonViewModel?
    var iconButtonViewModel: IconButtonViewModel?
    var setupViewModel: SetupViewModel?
    var callingViewModel: CallingViewModel?
    var localParticipantsListCellViewModel: ParticipantsListCellViewModel?
    var audioDevicesListCellViewModel: DrawerSelectableItemViewModel?
    var moreCallOptionsListViewModel: MoreCallOptionsListViewModel?
    var debugInfoSharingActivityViewModel: DebugInfoSharingActivityViewModel?
    var supportFormViewModel: SupportFormViewModel?
    var moreCallOptionsListCellViewModel: DrawerGenericItemViewModel?
    var leaveCallConfirmationViewModel: LeaveCallConfirmationViewModel?

    var createMockParticipantGridCellViewModel: ((ParticipantInfoModel) -> ParticipantGridCellViewModel?)?
    var createParticipantsListCellViewModel: ((ParticipantInfoModel) -> ParticipantsListCellViewModel?)?
    var createIconButtonViewModel: ((CompositeIcon) -> IconButtonViewModel?)?

    var createCameraIconWithLabelButtonViewModel: ((CameraButtonState) -> IconWithLabelButtonViewModel<CameraButtonState>?)?
    var createMicIconWithLabelButtonViewModel: ((MicButtonState) -> IconWithLabelButtonViewModel<MicButtonState>?)?
    var createAudioIconWithLabelButtonViewModel: ((AudioButtonState) -> IconWithLabelButtonViewModel<AudioButtonState>?)?
    var bottomToastViewModel: BottomToastViewModel?
    var participantMenuViewModel: ParticipantMenuViewModel?

    let avatarManager: AvatarViewManagerProtocol

    init(logger: Logger,
         store: Store<AppState, Action>,
         accessibilityProvider: AccessibilityProviderProtocol = AccessibilityProviderMocking(),
         localizationProvider: LocalizationProviderProtocol = LocalizationProviderMocking(),
         debugInfoManager: DebugInfoManagerProtocol = DebugInfoManagerMocking(),
         capabilitiesManager: CapabilitiesManager = CapabilitiesManager(callType: .groupCall),
         avatarManager: AvatarViewManagerProtocol) {
        self.logger = logger
        self.store = store
        self.accessibilityProvider = accessibilityProvider
        self.localizationProvider = localizationProvider
        self.debugInfoManager = debugInfoManager
        self.capabilitiesManager = capabilitiesManager
        self.avatarManager = avatarManager
    }

    func getSetupViewModel() -> SetupViewModel {
        return setupViewModel ?? SetupViewModel(compositeViewModelFactory: self,
                                                logger: logger,
                                                store: store,
                                                networkManager: NetworkManager(),
                                                audioSessionManager: AudioSessionManager(store: store, logger: logger, isCallKitEnabled: false),
                                                localizationProvider: localizationProvider, callType: .groupCall)
    }

    func getCallingViewModel() -> CallingViewModel {
        return callingViewModel ?? CallingViewModel(compositeViewModelFactory: self,
                                                    logger: logger,
                                                    store: store,
                                                    localizationProvider: localizationProvider,
                                                    accessibilityProvider: accessibilityProvider,
                                                    isIpadInterface: false,
                                                    allowLocalCameraPreview: true,
                                                    callType: .groupCall,
                                                    captionsOptions: CaptionsOptions(),
                                                    capabilitiesManager: capabilitiesManager,
                                                    callScreenOptions: CallScreenOptions()
        )
    }

    func makeIconButtonViewModel(iconName: CompositeIcon,
                                 buttonType: IconButtonViewModel.ButtonType,
                                 isDisabled: Bool,
                                 action: @escaping (() -> Void)) -> IconButtonViewModel {
        return createIconButtonViewModel?(iconName) ?? IconButtonViewModel(iconName: iconName,
                                                                           buttonType: buttonType,
                                                                           isDisabled: isDisabled,
                                                                           action: action)
    }

    func makeIconButtonViewModel(iconName: AzureCommunicationUICalling.CompositeIcon, buttonType: AzureCommunicationUICalling.IconButtonViewModel.ButtonType, isDisabled: Bool, isVisible: Bool, action: @escaping (() -> Void)) -> AzureCommunicationUICalling.IconButtonViewModel {
        return createIconButtonViewModel?(iconName) ?? IconButtonViewModel(iconName: iconName,
                                                                           buttonType: buttonType,
                                                                           isDisabled: isDisabled,
                                                                           action: action)
    }

    func makeIconWithLabelButtonViewModel<ButtonStateType>(
        selectedButtonState: ButtonStateType,
        localizationProvider: LocalizationProviderProtocol,
        buttonTypeColor: IconWithLabelButtonViewModel<ButtonStateType>.ButtonTypeColor,
        isDisabled: Bool,
        action: @escaping (() -> Void)) -> IconWithLabelButtonViewModel<ButtonStateType> where ButtonStateType: ButtonState {
            if let cameraStateClosure = createCameraIconWithLabelButtonViewModel,
               let cameraState = selectedButtonState as? CameraButtonState,
               let vm = cameraStateClosure(cameraState) as? IconWithLabelButtonViewModel<ButtonStateType> {
                return vm
            }
            if let micStateClosure = createMicIconWithLabelButtonViewModel,
               let micState = selectedButtonState as? MicButtonState,
               let vm = micStateClosure(micState) as? IconWithLabelButtonViewModel<ButtonStateType> {
                return vm
            }
            if let audioStateClosure = createAudioIconWithLabelButtonViewModel,
               let audioState = selectedButtonState as? AudioButtonState,
               let vm = audioStateClosure(audioState) as? IconWithLabelButtonViewModel<ButtonStateType> {
                return vm
            }
            return IconWithLabelButtonViewModel(
                selectedButtonState: selectedButtonState,
                localizationProvider: localizationProvider,
                buttonTypeColor: buttonTypeColor,
                isDisabled: isDisabled,
                action: action)
        }

    func makeLocalVideoViewModel(dispatchAction: @escaping ActionDispatch) -> LocalVideoViewModel {
        return localVideoViewModel ?? LocalVideoViewModel(compositeViewModelFactory: self,
                                                          logger: logger,
                                                          localizationProvider: localizationProvider,
                                                          dispatchAction: dispatchAction)
    }

    func makePrimaryButtonViewModel(buttonStyle: FluentUI.ButtonStyle,
                                    buttonLabel: String,
                                    iconName: CompositeIcon?,
                                    isDisabled: Bool,
                                    paddings: CompositeButton.Paddings?,
                                    action: @escaping (() -> Void)) -> PrimaryButtonViewModel {
        return primaryButtonViewModel ?? PrimaryButtonViewModel(buttonStyle: buttonStyle,
                                                                buttonLabel: buttonLabel,
                                                                iconName: iconName,
                                                                isDisabled: isDisabled,
                                                                action: action)
    }

    func makeAudioDevicesListViewModel(dispatchAction: @escaping ActionDispatch,
                                       localUserState: LocalUserState) -> AudioDevicesListViewModel {
        return audioDevicesListViewModel ?? AudioDevicesListViewModel(compositeViewModelFactory: self,
                                                                      dispatchAction: dispatchAction,
                                                                      localUserState: localUserState,
                                                                      localizationProvider: localizationProvider)
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
        }, isDisplayed: isDisplayed)
    }

    func makeErrorInfoViewModel(title: String,
                                subtitle: String) -> ErrorInfoViewModel {
        return errorInfoViewModel ?? ErrorInfoViewModel(localizationProvider: localizationProvider,
                                                        title: title,
                                                        subtitle: subtitle)
    }

    func makeCallDiagnosticsViewModel(dispatchAction: @escaping ActionDispatch) -> CallDiagnosticsViewModel {
        return callDiagnosticsViewModel ?? CallDiagnosticsViewModel(localizationProvider: localizationProvider,
                                                                    accessibilityProvider: accessibilityProvider,
                                                                    dispatchAction: dispatchAction)
    }

    func makeSelectableDrawerListItemViewModel(icon: CompositeIcon,
                                               title: String,
                                               isSelected: Bool,
                                               onSelectedAction: @escaping (() -> Void)) -> DrawerSelectableItemViewModel {
        return audioDevicesListCellViewModel ?? DrawerSelectableItemViewModel(icon: icon,
                                                                                  title: title,
                                                                              accessibilityIdentifier: "", accessibilityLabel: "",
                                                                                  isSelected: isSelected,
                                                                                  action: onSelectedAction)
    }

    func makeLeaveCallConfirmationViewModel(
        endCall: @escaping (() -> Void),
        dismissConfirmation: @escaping (() -> Void)) -> LeaveCallConfirmationViewModel {
            leaveCallConfirmationViewModel ?? LeaveCallConfirmationViewModel(state: store.state,
                                                  localizationProvider: localizationProvider,
                                                  endCall: {}, dismissConfirmation: {})
    }

    // MARK: CallingViewModels
    func makeLobbyOverlayViewModel() -> LobbyOverlayViewModel {
        return lobbyOverlayViewModel ?? LobbyOverlayViewModel(localizationProvider: localizationProvider,
                                                              accessibilityProvider: accessibilityProvider)
    }

    func makeLoadingOverlayViewModel() -> LoadingOverlayViewModel {
        return loadingOverlayViewModel ?? LoadingOverlayViewModel(localizationProvider: localizationProvider,
                                                                  accessibilityProvider: accessibilityProvider,
                                                                  networkManager: NetworkManager(),
                                                                  audioSessionManager: AudioSessionManager(store: store, logger: logger, isCallKitEnabled: false),
                                                                  store: store,
                                                                  callType: .groupCall
        )
    }

    func makeControlBarViewModel(dispatchAction: @escaping ActionDispatch,
                                 onEndCallTapped: @escaping (() -> Void),
                                 localUserState: LocalUserState,
                                 capabilitiesManager: CapabilitiesManager) -> ControlBarViewModel {
        return controlBarViewModel ?? ControlBarViewModel(compositeViewModelFactory: self,
                                                          logger: logger,
                                                          localizationProvider: localizationProvider,
                                                          dispatchAction: dispatchAction,
                                                          onEndCallTapped: onEndCallTapped,
                                                          localUserState: localUserState,
                                                          audioVideoMode: .audioAndVideo,
                                                          capabilitiesManager: capabilitiesManager, controlBarOptions: nil)
    }

    func makeInfoHeaderViewModel(dispatchAction: @escaping AzureCommunicationUICalling.ActionDispatch,
                                 localUserState: LocalUserState) -> InfoHeaderViewModel {
        return infoHeaderViewModel ?? InfoHeaderViewModel(compositeViewModelFactory: self,
                                                          logger: logger,
                                                          localUserState: localUserState,
                                                          localizationProvider: localizationProvider,
                                                          accessibilityProvider: accessibilityProvider,
                                                          dispatchAction: dispatchAction,
                                                          enableMultitasking: true,
                                                          enableSystemPipWhenMultitasking: true
                                                          /* <TIMER_TITLE_FEATURE> */
                                                          ,
                                                          callScreenHeaderViewData:
                                                            CallScreenHeaderViewData()
                                                          /* </TIMER_TITLE_FEATURE> */ )
    }

    func makeParticipantCellViewModel(participantModel: ParticipantInfoModel, lifeCycleState: LifeCycleState) -> ParticipantGridCellViewModel {
        return createMockParticipantGridCellViewModel?(participantModel) ?? ParticipantGridCellViewModel(
            localizationProvider: localizationProvider,
            accessibilityProvider: accessibilityProvider,
            participantModel: participantModel,
            lifeCycleState: lifeCycleState,
            isCameraEnabled: true,
            callType: .groupCall)
    }

    func makeCaptionsErrorViewModel(dispatchAction: @escaping AzureCommunicationUICalling.ActionDispatch)
    -> AzureCommunicationUICalling.CaptionsErrorViewModel {
        return CaptionsErrorViewModel(compositeViewModelFactory: self,
                                            logger: logger,
                                            localizationProvider: localizationProvider,
                                            accessibilityProvider: accessibilityProvider,
                                            dispatchAction: dispatchAction)
    }

    func makeToggleListItemViewModel(title: String, isToggleOn: Binding<Bool>, showToggle: Bool, accessibilityIdentifier: String, startIcon: AzureCommunicationUICalling.CompositeIcon, action: @escaping (() -> Void)) -> AzureCommunicationUICalling.DrawerGenericItemViewModel {
        return DrawerGenericItemViewModel(
            title: "",
            subtitle: "",
            accessibilityIdentifier: "",
            action: {})
    }

    func makeLanguageListItemViewModel(title: String, subtitle: String?, accessibilityIdentifier: String, startIcon: AzureCommunicationUICalling.CompositeIcon, endIcon: AzureCommunicationUICalling.CompositeIcon?, isEnabled: Bool, action: @escaping (() -> Void)) -> AzureCommunicationUICalling.DrawerGenericItemViewModel {
        return DrawerGenericItemViewModel(
            title: "",
            subtitle: "",
            accessibilityIdentifier: "",
            action: {})
    }

    func makeCaptionsLangaugeCellViewModel(title: String,
                                           isSelected: Bool,
                                           accessibilityLabel: String,
                                           onSelectedAction: @escaping (() -> Void)) -> AzureCommunicationUICalling.DrawerSelectableItemViewModel {
        return DrawerSelectableItemViewModel(
            icon: .none,
            title: "",
            accessibilityIdentifier: "",
            accessibilityLabel: "",
            isSelected: true,
            action: {})
    }

    func makeParticipantGridsViewModel(isIpadInterface: Bool) -> ParticipantGridViewModel {
        return participantGridViewModel ?? ParticipantGridViewModel(compositeViewModelFactory: self,
                                                                    localizationProvider: localizationProvider,
                                                                    accessibilityProvider: accessibilityProvider,
                                                                    isIpadInterface: isIpadInterface,
                                                                    callType: .groupCall)
    }

    func makeParticipantsListViewModel(localUserState: AzureCommunicationUICalling.LocalUserState, isDisplayed: Bool, dispatchAction: @escaping AzureCommunicationUICalling.ActionDispatch) -> AzureCommunicationUICalling.ParticipantsListViewModel {
        return participantsListViewModel ?? ParticipantsListViewModel(compositeViewModelFactory: self,
                                                                      localUserState: localUserState,
                                                                      dispatchAction: dispatchAction,
                                                                      localizationProvider: localizationProvider,
                                                                      onUserClicked: { participant in
            dispatchAction(Action.showParticipantActions(participant))
        }, avatarManager: avatarManager)
    }

    func makeBannerViewModel(dispatchAction: @escaping AzureCommunicationUICalling.ActionDispatch) -> BannerViewModel {
        return bannerViewModel ?? BannerViewModel(compositeViewModelFactory: self, dispatchAction: dispatchAction)
    }

    func makeBannerTextViewModel() -> BannerTextViewModel {
        return bannerTextViewModel ?? BannerTextViewModel(accessibilityProvider: accessibilityProvider,
                                                          localizationProvider: localizationProvider)
    }

    func makeLocalParticipantsListCellViewModel(localUserState: LocalUserState) -> ParticipantsListCellViewModel {
        localParticipantsListCellViewModel ?? ParticipantsListCellViewModel(localUserState: localUserState,
                                                                            localizationProvider: localizationProvider)
    }

    func makeMoreCallOptionsListViewModel(isDisplayed: Bool,
                                          isCaptionsAvailable: Bool,
                                          controlBarOptions: AzureCommunicationUICalling.CallScreenControlBarOptions?,
                                          showSharingViewAction: @escaping () -> Void,
                                          showSupportFormAction: @escaping () -> Void,
                                          showCaptionsViewAction: @escaping () -> Void,
                                          dispatchAction: @escaping ActionDispatch) -> MoreCallOptionsListViewModel {
        moreCallOptionsListViewModel ?? MoreCallOptionsListViewModel(compositeViewModelFactory: self,
                                                                     localizationProvider: localizationProvider,
                                                                     showSharingViewAction: showSharingViewAction,
                                                                     showSupportFormAction: showSupportFormAction, showCaptionsViewAction: showCaptionsViewAction,
                                                                     controlBarOptions: CallScreenControlBarOptions(),
                                                                     isCaptionsAvailable: true,
                                                                     isSupportFormAvailable: false,
                                                                     isDisplayed: isDisplayed,
                                                                     dispatchAction: store.dispatch)
    }

    func makeDebugInfoSharingActivityViewModel() -> DebugInfoSharingActivityViewModel {
        debugInfoSharingActivityViewModel ??
        DebugInfoSharingActivityViewModel(accessibilityProvider: accessibilityProvider,
                                          debugInfoManager: debugInfoManager) {}
    }

    func makeSupportFormViewModel() -> AzureCommunicationUICalling.SupportFormViewModel {
        return supportFormViewModel ?? SupportFormViewModel(
            isDisplayed: false,
            dispatchAction: store.dispatch,
            events: CallComposite.Events(),
            localizationProvider: localizationProvider,
            getDebugInfo: { [self] in self.debugInfoManager.getDebugInfo() })
    }

    // MARK: SetupViewModels
    func makePreviewAreaViewModel(dispatchAction: @escaping ActionDispatch) -> PreviewAreaViewModel {
        return previewAreaViewModel ?? PreviewAreaViewModel(compositeViewModelFactory: self,
                                                            dispatchAction: dispatchAction,
                                                            localizationProvider: localizationProvider)
    }

    func makeSetupControlBarViewModel(dispatchAction: @escaping ActionDispatch,
                                      localUserState: LocalUserState) -> SetupControlBarViewModel {
        return setupControlBarViewModel ?? SetupControlBarViewModel(compositeViewModelFactory: self,
                                                                    logger: logger,
                                                                    dispatchAction: dispatchAction,
                                                                    localUserState: localUserState,
                                                                    localizationProvider: localizationProvider,
                                                                    audioVideoMode: .audioAndVideo,
                                                                    setupScreenOptions: nil)
    }

    func makeJoiningCallActivityViewModel() -> JoiningCallActivityViewModel {
        JoiningCallActivityViewModel(title: "")
    }

    func makeOnHoldOverlayViewModel(resumeAction: @escaping (() -> Void)) -> OnHoldOverlayViewModel {
        return onHoldOverlayViewModel ?? OnHoldOverlayViewModel(localizationProvider: localizationProvider,
                                                                compositeViewModelFactory: self,
                                                                logger: logger,
                                                                accessibilityProvider: accessibilityProvider,
                                                                audioSessionManager: AudioSessionManager(store: store, logger: logger, isCallKitEnabled: false),
                                                                resumeAction: {})
    }

    func makeLobbyWaitingHeaderViewModel(localUserState: LocalUserState,
                                         dispatchAction: @escaping ActionDispatch) -> LobbyWaitingHeaderViewModel {
        return lobbyWaitingHeaderViewModel ?? LobbyWaitingHeaderViewModel(compositeViewModelFactory: self,
                                                                          logger: logger,
                                                                          localUserState: localUserState,
                                                                          localizationProvider: localizationProvider,
                                                                          accessibilityProvider: accessibilityProvider,
                                                                          dispatchAction: dispatchAction)
    }

    func makeLobbyActionErrorViewModel(localUserState: AzureCommunicationUICalling.LocalUserState,
                                       dispatchAction: @escaping AzureCommunicationUICalling.ActionDispatch)
    -> LobbyErrorHeaderViewModel {
        return lobbyErrorHeaderViewModel ?? LobbyErrorHeaderViewModel(compositeViewModelFactory: self,
                                                                      logger: logger,
                                                                      localUserState: localUserState,
                                                                      localizationProvider: localizationProvider,
                                                                      accessibilityProvider: accessibilityProvider,
                                                                      dispatchAction: dispatchAction)
    }

    func makeCaptionsInfoViewModel(dispatchAction: @escaping AzureCommunicationUICalling.ActionDispatch) -> AzureCommunicationUICalling.CaptionsInfoViewModel {
        return CaptionsInfoViewModel(state: store.state, captionsManager: CaptionsViewManager(
            store: store,
            callingSDKWrapper: CallingSDKWrapperMocking()), localizationProvider: localizationProvider)
    }

    func makeCaptionsListViewModel(showCaptionsLanguage: @escaping () -> Void,
                                   showSpokenLanguage: @escaping () -> Void,
                                   isDisplayed: Bool) -> AzureCommunicationUICalling.CaptionsListViewModel {
        return CaptionsListViewModel(
            compositeViewModelFactory: self,
            localizationProvider: localizationProvider,
            captionsOptions: CaptionsOptions(),
            state: store.state,
            dispatchAction: store.dispatch(action:),
            showSpokenLanguage: showSpokenLanguage,
            showCaptionsLanguage: showSpokenLanguage,
            isDisplayed: true)
    }

    func makeCaptionsLanguageListViewModel(dispatchAction: @escaping AzureCommunicationUICalling.ActionDispatch, state: AzureCommunicationUICalling.AppState) -> AzureCommunicationUICalling.CaptionsLanguageListViewModel {
        return CaptionsLanguageListViewModel(
            compositeViewModelFactory: self,
            dispatchAction: dispatchAction,
            state: state,
            localizationProvider: localizationProvider)
    }

    func makeCaptionsInfoViewModel(state: AzureCommunicationUICalling.AppState) -> AzureCommunicationUICalling.CaptionsInfoViewModel {
        return CaptionsInfoViewModel(state: state,
                                     captionsManager: CaptionsViewManager(
                                        store: store,
                                        callingSDKWrapper: CallingSDKWrapperMocking()),
                                     localizationProvider: localizationProvider)
    }

    func makeMoreCallOptionsListViewModel(isDisplayed: Bool,
                                          isCaptionsAvailable: Bool,
                                          showSharingViewAction: @escaping () -> Void,
                                          showSupportFormAction: @escaping () -> Void,
                                          showCaptionsViewAction: @escaping () -> Void,
                                          dispatchAction: @escaping AzureCommunicationUICalling.ActionDispatch
    ) -> AzureCommunicationUICalling.MoreCallOptionsListViewModel {
        return MoreCallOptionsListViewModel(
            compositeViewModelFactory: self,
            localizationProvider: localizationProvider,
            showSharingViewAction: showSharingViewAction,
            showSupportFormAction: showSupportFormAction,
            showCaptionsViewAction: showCaptionsViewAction,
            controlBarOptions: nil,
            isCaptionsAvailable: true,
            isSupportFormAvailable: true,
            isDisplayed: true,
            dispatchAction: dispatchAction)
    }

    func makeCaptionsListViewModel(state: AzureCommunicationUICalling.AppState,
                                   captionsOptions: AzureCommunicationUICalling.CaptionsOptions,
                                   dispatchAction: @escaping AzureCommunicationUICalling.ActionDispatch,
                                   showSpokenLanguage: @escaping () -> Void,
                                   showCaptionsLanguage: @escaping () -> Void,
                                   isDisplayed: Bool) -> AzureCommunicationUICalling.CaptionsListViewModel {
        return CaptionsListViewModel(
            compositeViewModelFactory: self,
            localizationProvider: localizationProvider,
            captionsOptions: CaptionsOptions(),
            state: state,
            dispatchAction: dispatchAction,
            showSpokenLanguage: showSpokenLanguage,
            showCaptionsLanguage: showCaptionsLanguage,
            isDisplayed: true)
    }
    func makeBottomToastViewModel(toastNotificationState: AzureCommunicationUICalling.ToastNotificationState,
                                  dispatchAction: @escaping AzureCommunicationUICalling.ActionDispatch)
    -> AzureCommunicationUICalling.BottomToastViewModel {
        return bottomToastViewModel ?? BottomToastViewModel(dispatchAction: dispatchAction,
                                                            localizationProvider: localizationProvider,
                                                            accessibilityProvider: accessibilityProvider,
                                                            toastNotificationState: ToastNotificationState())
    }
}
