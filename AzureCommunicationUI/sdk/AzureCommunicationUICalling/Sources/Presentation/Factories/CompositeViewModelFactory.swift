//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import FluentUI
import Foundation

protocol CompositeViewModelFactoryProtocol {
    // MARK: CompositeViewModels
    func getSetupViewModel() -> SetupViewModel
    func getCallingViewModel() -> CallingViewModel

    // MARK: ComponentViewModels
    func makeIconButtonViewModel(iconName: CompositeIcon,
                                 buttonType: IconButtonViewModel.ButtonType,
                                 isDisabled: Bool,
                                 action: @escaping (() -> Void)) -> IconButtonViewModel
    func makeIconWithLabelButtonViewModel<ButtonStateType>(
        selectedButtonState: ButtonStateType,
        localizationProvider: LocalizationProviderProtocol,
        buttonTypeColor: IconWithLabelButtonViewModel<ButtonStateType>.ButtonTypeColor,
        isDisabled: Bool,
        action: @escaping (() -> Void)) -> IconWithLabelButtonViewModel<ButtonStateType>
    func makeLocalVideoViewModel(dispatchAction: @escaping ActionDispatch) -> LocalVideoViewModel
    func makePrimaryButtonViewModel(buttonStyle: FluentUI.ButtonStyle,
                                    buttonLabel: String,
                                    iconName: CompositeIcon?,
                                    isDisabled: Bool,
                                    paddings: CompositeButton.Paddings?,
                                    action: @escaping (() -> Void)) -> PrimaryButtonViewModel
    func makeAudioDevicesListViewModel(dispatchAction: @escaping ActionDispatch,
                                       localUserState: LocalUserState) -> AudioDevicesListViewModel
    func makeErrorInfoViewModel(title: String,
                                subtitle: String) -> ErrorInfoViewModel
    func makeCallDiagnosticsViewModel() -> CallDiagnosticsViewModel

    // MARK: CallingViewModels
    func makeLobbyOverlayViewModel() -> LobbyOverlayViewModel
    func makeLoadingOverlayViewModel() -> LoadingOverlayViewModel
    func makeOnHoldOverlayViewModel(resumeAction: @escaping (() -> Void)) -> OnHoldOverlayViewModel
    func makeControlBarViewModel(dispatchAction: @escaping ActionDispatch,
                                 endCallConfirm: @escaping (() -> Void),
                                 localUserState: LocalUserState) -> ControlBarViewModel
    func makeInfoHeaderViewModel(localUserState: LocalUserState,
                                 dispatchAction: @escaping ActionDispatch) -> InfoHeaderViewModel
    func makeLobbyWaitingHeaderViewModel(localUserState: LocalUserState,
                                         dispatchAction: @escaping ActionDispatch) -> LobbyWaitingHeaderViewModel
    func makeLobbyActionErrorViewModel(localUserState: LocalUserState,
                                       dispatchAction: @escaping ActionDispatch) -> LobbyErrorHeaderViewModel
    func makeParticipantCellViewModel(participantModel: ParticipantInfoModel,
                                      lifeCycleState: LifeCycleState) -> ParticipantGridCellViewModel
    func makeParticipantGridsViewModel(isIpadInterface: Bool) -> ParticipantGridViewModel
    func makeParticipantsListViewModel(localUserState: LocalUserState,
                                       dispatchAction: @escaping ActionDispatch) -> ParticipantsListViewModel
    func makeBannerViewModel() -> BannerViewModel
    func makeBannerTextViewModel() -> BannerTextViewModel
    func makeLocalParticipantsListCellViewModel(localUserState: LocalUserState) -> ParticipantsListCellViewModel
    func makeParticipantsListCellViewModel(participantInfoModel: ParticipantInfoModel) -> ParticipantsListCellViewModel
    func makeMoreCallOptionsListViewModel(showSharingViewAction: @escaping () -> Void) -> MoreCallOptionsListViewModel
    func makeDebugInfoSharingActivityViewModel() -> DebugInfoSharingActivityViewModel
    func makeDrawerListItemViewModel(icon: CompositeIcon,
                                     title: String,
                                     accessibilityIdentifier: String,
                                     action: @escaping (() -> Void)) -> DrawerListItemViewModel
    func makeSelectableDrawerListItemViewModel(
        icon: CompositeIcon,
        title: String,
        isSelected: Bool,
        onSelectedAction: @escaping (() -> Void)) -> SelectableDrawerListItemViewModel

    // MARK: SetupViewModels
    func makePreviewAreaViewModel(dispatchAction: @escaping ActionDispatch) -> PreviewAreaViewModel
    func makeSetupControlBarViewModel(dispatchAction: @escaping ActionDispatch,
                                      localUserState: LocalUserState) -> SetupControlBarViewModel
    func makeJoiningCallActivityViewModel() -> JoiningCallActivityViewModel
}

extension CompositeViewModelFactoryProtocol {
    func makePrimaryButtonViewModel(buttonStyle: FluentUI.ButtonStyle,
                                    buttonLabel: String,
                                    iconName: CompositeIcon? = .none,
                                    isDisabled: Bool = false,
                                    action: @escaping (() -> Void)) -> PrimaryButtonViewModel {
        return makePrimaryButtonViewModel(buttonStyle: buttonStyle,
                                   buttonLabel: buttonLabel,
                                   iconName: iconName,
                                   isDisabled: isDisabled,
                                   paddings: nil,
                                   action: action)
    }
}

// swiftlint:disable type_body_length
class CompositeViewModelFactory: CompositeViewModelFactoryProtocol {
    private let logger: Logger
    private let store: Store<AppState, Action>
    private let networkManager: NetworkManager
    private let audioSessionManager: AudioSessionManagerProtocol
    private let accessibilityProvider: AccessibilityProviderProtocol
    private let localizationProvider: LocalizationProviderProtocol
    private let debugInfoManager: DebugInfoManagerProtocol
    private let localOptions: LocalOptions?
    private let enableMultitasking: Bool
    private let enableSystemPiPWhenMultitasking: Bool

    private weak var setupViewModel: SetupViewModel?
    private weak var callingViewModel: CallingViewModel?

    init(logger: Logger,
         store: Store<AppState, Action>,
         networkManager: NetworkManager,
         audioSessionManager: AudioSessionManagerProtocol,
         localizationProvider: LocalizationProviderProtocol,
         accessibilityProvider: AccessibilityProviderProtocol,
         debugInfoManager: DebugInfoManagerProtocol,
         localOptions: LocalOptions? = nil,
         enableMultitasking: Bool,
         enableSystemPiPWhenMultitasking: Bool) {
        self.logger = logger
        self.store = store
        self.networkManager = networkManager
        self.audioSessionManager = audioSessionManager
        self.accessibilityProvider = accessibilityProvider
        self.localizationProvider = localizationProvider
        self.debugInfoManager = debugInfoManager
        self.localOptions = localOptions
        self.enableMultitasking = enableMultitasking
        self.enableSystemPiPWhenMultitasking = enableSystemPiPWhenMultitasking
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
                                           setupScreenViewData: localOptions?.setupScreenViewData)
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
                                             isIpadInterface: UIDevice.current.userInterfaceIdiom == .pad)
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

    func makeCallDiagnosticsViewModel() -> CallDiagnosticsViewModel {
        CallDiagnosticsViewModel(localizationProvider: localizationProvider)
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
                                store: store)
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
                                 endCallConfirm: @escaping (() -> Void),
                                 localUserState: LocalUserState) -> ControlBarViewModel {
        ControlBarViewModel(compositeViewModelFactory: self,
                            logger: logger,
                            localizationProvider: localizationProvider,
                            dispatchAction: dispatchAction,
                            endCallConfirm: endCallConfirm,
                            localUserState: localUserState)
    }
    func makeInfoHeaderViewModel(localUserState: LocalUserState,
                                 dispatchAction: @escaping ActionDispatch) -> InfoHeaderViewModel {
        InfoHeaderViewModel(compositeViewModelFactory: self,
                            logger: logger,
                            localUserState: localUserState,
                            localizationProvider: localizationProvider,
                            accessibilityProvider: accessibilityProvider,
                            dispatchAction: dispatchAction,
                            enableMultitasking: enableMultitasking,
                            enableSystemPiPWhenMultitasking: enableSystemPiPWhenMultitasking)
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
                                     lifeCycleState: lifeCycleState)
    }
    func makeParticipantGridsViewModel(isIpadInterface: Bool) -> ParticipantGridViewModel {
        ParticipantGridViewModel(compositeViewModelFactory: self,
                                 localizationProvider: localizationProvider,
                                 accessibilityProvider: accessibilityProvider,
                                 isIpadInterface: isIpadInterface)
    }

    func makeParticipantsListViewModel(localUserState: LocalUserState,
                                       dispatchAction: @escaping ActionDispatch) -> ParticipantsListViewModel {
        ParticipantsListViewModel(compositeViewModelFactory: self,
                                  localUserState: localUserState,
                                  dispatchAction: dispatchAction)
    }
    func makeBannerViewModel() -> BannerViewModel {
        BannerViewModel(compositeViewModelFactory: self)
    }
    func makeBannerTextViewModel() -> BannerTextViewModel {
        BannerTextViewModel(accessibilityProvider: accessibilityProvider,
                            localizationProvider: localizationProvider)
    }

    func makeLocalParticipantsListCellViewModel(localUserState: LocalUserState) -> ParticipantsListCellViewModel {
        ParticipantsListCellViewModel(localUserState: localUserState,
                                      localizationProvider: localizationProvider)
    }

    func makeParticipantsListCellViewModel(participantInfoModel: ParticipantInfoModel)
    -> ParticipantsListCellViewModel {
        ParticipantsListCellViewModel(participantInfoModel: participantInfoModel,
                                      localizationProvider: localizationProvider)
    }

    func makeMoreCallOptionsListViewModel(showSharingViewAction: @escaping () -> Void) -> MoreCallOptionsListViewModel {
        MoreCallOptionsListViewModel(compositeViewModelFactory: self,
                                     localizationProvider: localizationProvider,
                                     showSharingViewAction: showSharingViewAction)
    }

    func makeDrawerListItemViewModel(icon: CompositeIcon,
                                     title: String,
                                     accessibilityIdentifier: String,
                                     action: @escaping (() -> Void)) -> DrawerListItemViewModel {
        DrawerListItemViewModel(icon: icon,
                                title: title,
                                accessibilityIdentifier: accessibilityIdentifier,
                                action: action)
    }

    func makeDebugInfoSharingActivityViewModel() -> DebugInfoSharingActivityViewModel {
        DebugInfoSharingActivityViewModel(accessibilityProvider: accessibilityProvider,
                                          debugInfoManager: debugInfoManager)
    }

    // MARK: SetupViewModels
    func makePreviewAreaViewModel(dispatchAction: @escaping ActionDispatch) -> PreviewAreaViewModel {
        PreviewAreaViewModel(compositeViewModelFactory: self,
                             dispatchAction: dispatchAction,
                             localizationProvider: localizationProvider)
    }

    func makeSetupControlBarViewModel(dispatchAction: @escaping ActionDispatch,
                                      localUserState: LocalUserState) -> SetupControlBarViewModel {
        SetupControlBarViewModel(compositeViewModelFactory: self,
                                 logger: logger,
                                 dispatchAction: dispatchAction,
                                 localUserState: localUserState,
                                 localizationProvider: localizationProvider)
    }

    func makeJoiningCallActivityViewModel() -> JoiningCallActivityViewModel {
        JoiningCallActivityViewModel(localizationProvider: localizationProvider)
    }
}
