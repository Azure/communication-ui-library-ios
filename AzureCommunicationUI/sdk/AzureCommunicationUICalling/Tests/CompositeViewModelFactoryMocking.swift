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
    private let updatableOptionsManager: UpdatableOptionsManager

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
         avatarManager: AvatarViewManagerProtocol,
         updatableOptionsManager: UpdatableOptionsManager
    ) {
        self.logger = logger
        self.store = store
        self.accessibilityProvider = accessibilityProvider
        self.localizationProvider = localizationProvider
        self.debugInfoManager = debugInfoManager
        self.capabilitiesManager = capabilitiesManager
        self.avatarManager = avatarManager
        self.updatableOptionsManager = updatableOptionsManager
    }

    func getSetupViewModel() -> SetupViewModel {
        return setupViewModel ?? SetupViewModel(compositeViewModelFactory: self,
                                                logger: logger,
                                                store: store,
                                                networkManager: NetworkManager(),
                                                audioSessionManager: AudioSessionManager(store: store, logger: logger, isCallKitEnabled: false),
                                                localizationProvider: localizationProvider, callType: .groupCall)
    }

    func getCallingViewModel(rendererViewManager: any AzureCommunicationUICalling.RendererViewManager) -> CallingViewModel {
        return callingViewModel ?? CallingViewModel(compositeViewModelFactory: self,
                                                    store: store,
                                                    localizationProvider: localizationProvider,
                                                    accessibilityProvider: accessibilityProvider,
                                                    isIpadInterface: false,
                                                    allowLocalCameraPreview: true,
                                                    callType: .groupCall,
                                                    captionsOptions: CaptionsOptions(),
                                                    capabilitiesManager: capabilitiesManager,
                                                    callScreenOptions: CallScreenOptions(),
                                                    rendererViewManager: rendererViewManager
        )
    }
    func makeIconButtonViewModel(icon: UIImage,
                                 buttonType: IconButtonViewModel.ButtonType,
                                 isDisabled: Bool,
                                 isVisible: Bool,
                                 action: @escaping (() -> Void)) -> AzureCommunicationUICalling.IconButtonViewModel {
        return IconButtonViewModel(icon: icon,
                                   buttonType: buttonType,
                                   isDisabled: isDisabled,
                                   action: action)
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
                                                                themeOptions: MockThemeOptions(),
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
                                                                  audioSessionManager: AudioSessionManager(store: store, logger: logger, isCallKitEnabled: false), themeOptions: MockThemeOptions(),
                                                                  store: store,
                                                                  callType: .groupCall
        )
    }

    func makeControlBarViewModel(dispatchAction: @escaping ActionDispatch,
                                 onEndCallTapped: @escaping (() -> Void),
                                 localUserState: LocalUserState,
                                 capabilitiesManager: CapabilitiesManager,
                                 buttonViewDataState: AzureCommunicationUICalling.ButtonViewDataState) -> ControlBarViewModel {
        return controlBarViewModel ?? ControlBarViewModel(compositeViewModelFactory: self,
                                                          logger: logger,
                                                          localizationProvider: localizationProvider,
                                                          dispatchAction: dispatchAction,
                                                          onEndCallTapped: onEndCallTapped,
                                                          localUserState: localUserState,
                                                          accessibilityProvider: accessibilityProvider,
                                                          audioVideoMode: .audioAndVideo,
                                                          capabilitiesManager: capabilitiesManager,
                                                          controlBarOptions: nil,
                                                          buttonViewDataState: buttonViewDataState)
    }

    func makeInfoHeaderViewModel(dispatchAction: @escaping AzureCommunicationUICalling.ActionDispatch,
                                 localUserState: LocalUserState,
                                 callScreenInfoHeaderState: CallScreenInfoHeaderState,
                                 buttonViewDataState: ButtonViewDataState,
                                 controlHeaderViewData: CallScreenHeaderViewData?
    ) -> InfoHeaderViewModel {
        return infoHeaderViewModel ?? InfoHeaderViewModel(compositeViewModelFactory: self,
                                                          logger: logger,
                                                          localUserState: localUserState,
                                                          localizationProvider: localizationProvider,
                                                          accessibilityProvider: accessibilityProvider,
                                                          dispatchAction: dispatchAction,
                                                          enableMultitasking: true,
                                                          enableSystemPipWhenMultitasking: true,
                                                          callScreenInfoHeaderState: callScreenInfoHeaderState,
                                                          buttonViewDataState: buttonViewDataState,
                                                          controlHeaderViewData: controlHeaderViewData
        )
    }

    func makeParticipantCellViewModel(participantModel: ParticipantInfoModel) -> ParticipantGridCellViewModel {
        return createMockParticipantGridCellViewModel?(participantModel) ?? ParticipantGridCellViewModel(
            localizationProvider: localizationProvider,
            accessibilityProvider: accessibilityProvider,
            participantModel: participantModel,
            isCameraEnabled: true,
            captionsRttManager: CaptionsAndRttViewManager(
                store: store,
                callingSDKWrapper: CallingSDKWrapperMocking()
            ),
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

    func makeToggleListItemViewModel(title: String, isToggleOn: Binding<Bool>, showToggle: Bool, accessibilityIdentifier: String, startIcon: AzureCommunicationUICalling.CompositeIcon, isEnabled: Bool, action: @escaping (() -> Void)) -> AzureCommunicationUICalling.DrawerGenericItemViewModel {
        return DrawerGenericItemViewModel(
            title: "",
            subtitle: "",
            accessibilityIdentifier: "",
            action: {},
            isEnabled: isEnabled)
    }

    func makeLanguageListItemViewModel(title: String, subtitle: String?, accessibilityIdentifier: String, startIcon: AzureCommunicationUICalling.CompositeIcon, endIcon: AzureCommunicationUICalling.CompositeIcon?, isEnabled: Bool, action: @escaping (() -> Void)) -> AzureCommunicationUICalling.DrawerGenericItemViewModel {
        return DrawerGenericItemViewModel(
            title: "",
            subtitle: "",
            accessibilityIdentifier: "",
            action: {})
    }

    func makeCaptionsRttInfoViewModel(state: AzureCommunicationUICalling.AppState, captionsOptions: AzureCommunicationUICalling.CaptionsOptions) -> AzureCommunicationUICalling.CaptionsAndRttInfoViewModel {
        return CaptionsAndRttInfoViewModel(
            state: state,
            captionsManager: CaptionsAndRttViewManager(
                store: store,
                callingSDKWrapper: CallingSDKWrapperMocking()
            ),
            captionsOptions: captionsOptions,
            dispatch: store.dispatch,
            localizationProvider: localizationProvider)
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

    func makeParticipantGridsViewModel(isIpadInterface: Bool, rendererViewManager: any AzureCommunicationUICalling.RendererViewManager) -> ParticipantGridViewModel {
        return participantGridViewModel ?? ParticipantGridViewModel(compositeViewModelFactory: self,
                                                                    localizationProvider: localizationProvider,
                                                                    accessibilityProvider: accessibilityProvider,
                                                                    isIpadInterface: isIpadInterface,
                                                                    callType: .groupCall,
                                                                    rendererViewManager: rendererViewManager)
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
                                      localUserState: LocalUserState,
                                      buttonViewDataState: AzureCommunicationUICalling.ButtonViewDataState) -> SetupControlBarViewModel {
        return setupControlBarViewModel ?? SetupControlBarViewModel(compositeViewModelFactory: self,
                                                                    logger: logger,
                                                                    dispatchAction: dispatchAction,
                                                                    updatableOptionsManager: updatableOptionsManager,
                                                                    localUserState: localUserState,
                                                                    localizationProvider: localizationProvider,
                                                                    audioVideoMode: .audioAndVideo,
                                                                    setupScreenOptions: nil,
                                                                    buttonViewDataState: buttonViewDataState)
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

    func makeCaptionsListViewModel(buttonActions: ButtonActions,
                                   isRttAvailable: Bool,
                                   isDisplayed: Bool) -> AzureCommunicationUICalling.CaptionsListViewModel {
        return CaptionsListViewModel(
            compositeViewModelFactory: self,
            localizationProvider: localizationProvider,
            captionsOptions: CaptionsOptions(),
            state: store.state,
            dispatchAction: store.dispatch(action:),
            buttonActions: buttonActions,
            isRttAvailable: true,
            isDisplayed: true)
    }

    func makeCaptionsLanguageListViewModel(dispatchAction: @escaping AzureCommunicationUICalling.ActionDispatch, state: AzureCommunicationUICalling.AppState) -> AzureCommunicationUICalling.CaptionsLanguageListViewModel {
        return CaptionsLanguageListViewModel(
            compositeViewModelFactory: self,
            dispatchAction: dispatchAction,
            state: state,
            localizationProvider: localizationProvider)
    }

    func makeMoreCallOptionsListViewModel(
        isCaptionsAvailable: Bool,
        buttonActions: AzureCommunicationUICalling.ButtonActions,
        controlBarOptions: AzureCommunicationUICalling.CallScreenControlBarOptions?,
        buttonViewDataState: AzureCommunicationUICalling.ButtonViewDataState,
        dispatchAction: @escaping AzureCommunicationUICalling.ActionDispatch) -> AzureCommunicationUICalling.MoreCallOptionsListViewModel {
            return MoreCallOptionsListViewModel(
                compositeViewModelFactory: self,
                localizationProvider: localizationProvider,
                buttonActions: buttonActions,
                controlBarOptions: controlBarOptions,
                isCaptionsAvailable: true,
                isSupportFormAvailable: true,
                buttonViewDataState: buttonViewDataState,
                dispatchAction: dispatchAction)
    }

    func makeCaptionsListViewModel(state: AzureCommunicationUICalling.AppState,
                                   captionsOptions: AzureCommunicationUICalling.CaptionsOptions,
                                   dispatchAction: @escaping AzureCommunicationUICalling.ActionDispatch,
                                   buttonActions: AzureCommunicationUICalling.ButtonActions,
                                   isRttAvailable: Bool,
                                   isDisplayed: Bool) -> AzureCommunicationUICalling.CaptionsListViewModel {
        return CaptionsListViewModel(
            compositeViewModelFactory: self,
            localizationProvider: localizationProvider,
            captionsOptions: CaptionsOptions(),
            state: state,
            dispatchAction: dispatchAction,
            buttonActions: buttonActions,
            isRttAvailable: isRttAvailable,
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
