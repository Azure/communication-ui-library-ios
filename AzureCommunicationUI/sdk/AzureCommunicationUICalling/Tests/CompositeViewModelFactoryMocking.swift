//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import FluentUI
@testable import AzureCommunicationUICalling

struct CompositeViewModelFactoryMocking: CompositeViewModelFactoryProtocol {
    private let logger: Logger
    private let store: Store<AppState, Action>
    private let accessibilityProvider: AccessibilityProviderProtocol
    private let localizationProvider: LocalizationProviderProtocol
    private let debugInfoManager: DebugInfoManagerProtocol

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
    var lobbyOverlayViewModel: LobbyOverlayViewModel?
    var loadingOverlayViewModel: LoadingOverlayViewModel?
    var audioDevicesListViewModel: AudioDevicesListViewModel?
    var primaryButtonViewModel: PrimaryButtonViewModel?
    var iconButtonViewModel: IconButtonViewModel?
    var setupViewModel: SetupViewModel?
    var callingViewModel: CallingViewModel?
    var localParticipantsListCellViewModel: ParticipantsListCellViewModel?
    var audioDevicesListCellViewModel: SelectableDrawerListItemViewModel?
    var moreCallOptionsListViewModel: MoreCallOptionsListViewModel?
    var debugInfoSharingActivityViewModel: DebugInfoSharingActivityViewModel?
    var moreCallOptionsListCellViewModel: DrawerListItemViewModel?

    var createMockParticipantGridCellViewModel: ((ParticipantInfoModel) -> ParticipantGridCellViewModel?)?
    var createParticipantsListCellViewModel: ((ParticipantInfoModel) -> ParticipantsListCellViewModel?)?
    var createIconButtonViewModel: ((CompositeIcon) -> IconButtonViewModel?)?

    var createCameraIconWithLabelButtonViewModel: ((CameraButtonState) -> IconWithLabelButtonViewModel<CameraButtonState>?)?
    var createMicIconWithLabelButtonViewModel: ((MicButtonState) -> IconWithLabelButtonViewModel<MicButtonState>?)?
    var createAudioIconWithLabelButtonViewModel: ((AudioButtonState) -> IconWithLabelButtonViewModel<AudioButtonState>?)?

    init(logger: Logger,
         store: Store<AppState, Action>,
         accessibilityProvider: AccessibilityProviderProtocol = AccessibilityProviderMocking(),
         localizationProvider: LocalizationProviderProtocol = LocalizationProviderMocking(),
         debugInfoManager: DebugInfoManagerProtocol = DebugInfoManagerMocking()) {
        self.logger = logger
        self.store = store
        self.accessibilityProvider = accessibilityProvider
        self.localizationProvider = localizationProvider
        self.debugInfoManager = debugInfoManager
    }

    func getSetupViewModel() -> SetupViewModel {
        return setupViewModel ?? SetupViewModel(compositeViewModelFactory: self,
                                                logger: logger,
                                                store: store,
                                                networkManager: NetworkManager(),
                                                audioSessionManager: AudioSessionManager(store: store, logger: logger),
                                                localizationProvider: localizationProvider)
    }

    func getCallingViewModel() -> CallingViewModel {
        return callingViewModel ?? CallingViewModel(compositeViewModelFactory: self,
                                                    logger: logger,
                                                    store: store,
                                                    localizationProvider: localizationProvider,
                                                    accessibilityProvider: accessibilityProvider,
                                                    isIpadInterface: false)
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

    func makePrimaryButtonViewModel(buttonStyle: ButtonStyle,
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

    func makeErrorInfoViewModel(title: String,
                                subtitle: String) -> ErrorInfoViewModel {
        return errorInfoViewModel ?? ErrorInfoViewModel(localizationProvider: localizationProvider,
                                                        title: title,
                                                        subtitle: subtitle)
    }

    func makeSelectableDrawerListItemViewModel(icon: CompositeIcon,
                                               title: String,
                                               isSelected: Bool,
                                               onSelectedAction: @escaping (() -> Void)) -> SelectableDrawerListItemViewModel {
        return audioDevicesListCellViewModel ?? SelectableDrawerListItemViewModel(icon: icon,
                                                                                  title: title,
                                                                                  accessibilityIdentifier: "",
                                                                              isSelected: isSelected,
                                                                              action: onSelectedAction)
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
                                                                  audioSessionManager: AudioSessionManager(store: store, logger: logger),
                                                                  store: store
        )
    }

    func makeControlBarViewModel(dispatchAction: @escaping ActionDispatch,
                                 endCallConfirm: @escaping (() -> Void),
                                 localUserState: LocalUserState) -> ControlBarViewModel {
        return controlBarViewModel ?? ControlBarViewModel(compositeViewModelFactory: self,
                                                          logger: logger,
                                                          localizationProvider: localizationProvider,
                                                          dispatchAction: dispatchAction,
                                                          endCallConfirm: endCallConfirm,
                                                          localUserState: localUserState)
    }

    func makeInfoHeaderViewModel(localUserState: LocalUserState,
                                 dispatchAction: @escaping AzureCommunicationUICalling.ActionDispatch) -> InfoHeaderViewModel {
        return infoHeaderViewModel ?? InfoHeaderViewModel(compositeViewModelFactory: self,
                                                          logger: logger,
                                                          localUserState: localUserState,
                                                          localizationProvider: localizationProvider,
                                                          accessibilityProvider: accessibilityProvider,
                                                          dispatchAction: dispatchAction,
                                                          enableMultitasking: true,
                                                          enableSystemPiPWhenMultitasking: true)
    }

    func makeParticipantCellViewModel(participantModel: ParticipantInfoModel, lifeCycleState: LifeCycleState) -> ParticipantGridCellViewModel {
        return createMockParticipantGridCellViewModel?(participantModel) ?? ParticipantGridCellViewModel(
            localizationProvider: localizationProvider,
            accessibilityProvider: accessibilityProvider,
            participantModel: participantModel,
            lifeCycleState: lifeCycleState)
    }

    func makeParticipantGridsViewModel(isIpadInterface: Bool) -> ParticipantGridViewModel {
        return participantGridViewModel ?? ParticipantGridViewModel(compositeViewModelFactory: self,
                                                                    localizationProvider: localizationProvider,
																	accessibilityProvider: accessibilityProvider,
                                                                    isIpadInterface: isIpadInterface)
    }

    func makeParticipantsListViewModel(localUserState: LocalUserState,
                                       dispatchAction: @escaping AzureCommunicationUICalling.ActionDispatch) -> ParticipantsListViewModel {
        return participantsListViewModel ?? ParticipantsListViewModel(compositeViewModelFactory: self,
                                                                      localUserState: localUserState,
                                                                      dispatchAction: dispatchAction)
    }

    func makeBannerViewModel() -> BannerViewModel {
        return bannerViewModel ?? BannerViewModel(compositeViewModelFactory: self)
    }

    func makeBannerTextViewModel() -> BannerTextViewModel {
        return bannerTextViewModel ?? BannerTextViewModel(accessibilityProvider: accessibilityProvider,
                                                          localizationProvider: localizationProvider)
    }

    func makeLocalParticipantsListCellViewModel(localUserState: LocalUserState) -> ParticipantsListCellViewModel {
        localParticipantsListCellViewModel ?? ParticipantsListCellViewModel(localUserState: localUserState,
                                                                            localizationProvider: localizationProvider)
    }

    func makeParticipantsListCellViewModel(participantInfoModel: ParticipantInfoModel) -> ParticipantsListCellViewModel {
        createParticipantsListCellViewModel?(participantInfoModel) ?? ParticipantsListCellViewModel(participantInfoModel: participantInfoModel,
                                                                                                    localizationProvider: localizationProvider)
    }

    func makeMoreCallOptionsListViewModel(showSharingViewAction: @escaping () -> Void) -> MoreCallOptionsListViewModel {
        moreCallOptionsListViewModel ?? MoreCallOptionsListViewModel(compositeViewModelFactory: self,
                                                                     localizationProvider: localizationProvider,
                                                                     showSharingViewAction: showSharingViewAction)
    }

    func makeDrawerListItemViewModel(icon: CompositeIcon,
                                     title: String,
                                     accessibilityIdentifier: String,
                                     action: @escaping (() -> Void)) -> DrawerListItemViewModel {
        moreCallOptionsListCellViewModel ?? DrawerListItemViewModel(icon: icon,
                                                                             title: title,
                                                                             accessibilityIdentifier: accessibilityIdentifier,
                                                                             action: action)
    }

    func makeDebugInfoSharingActivityViewModel() -> DebugInfoSharingActivityViewModel {
        debugInfoSharingActivityViewModel ??
        DebugInfoSharingActivityViewModel(accessibilityProvider: accessibilityProvider,
                                          debugInfoManager: debugInfoManager)
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
                                                                    localizationProvider: localizationProvider)
    }

    func makeJoiningCallActivityViewModel() -> JoiningCallActivityViewModel {
        JoiningCallActivityViewModel(localizationProvider: localizationProvider)
    }

    func makeOnHoldOverlayViewModel(resumeAction: @escaping (() -> Void)) -> OnHoldOverlayViewModel {
        return onHoldOverlayViewModel ?? OnHoldOverlayViewModel(localizationProvider: localizationProvider,
                                      compositeViewModelFactory: self,
                                      logger: logger,
                                      accessibilityProvider: accessibilityProvider,
                                      audioSessionManager: AudioSessionManager(store: store, logger: logger),
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

}
