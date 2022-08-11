//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import FluentUI

protocol CompositeViewModelFactoryProtocol {
    // MARK: CompositeViewModels
    func getSetupViewModel() -> SetupViewModel
    func getCallingViewModel() -> CallingViewModel

    // MARK: ComponentViewModels
    func makeIconButtonViewModel(iconName: CompositeIcon,
                                 buttonType: IconButtonViewModel.ButtonType,
                                 isDisabled: Bool,
                                 action: @escaping (() -> Void)) -> IconButtonViewModel
    func makeIconWithLabelButtonViewModel(iconName: CompositeIcon,
                                          buttonTypeColor: IconWithLabelButtonViewModel.ButtonTypeColor,
                                          buttonLabel: String,
                                          isDisabled: Bool,
                                          action: @escaping (() -> Void)) -> IconWithLabelButtonViewModel
    func makeLocalVideoViewModel(dispatchAction: @escaping ActionDispatch) -> LocalVideoViewModel
    func makePrimaryButtonViewModel(buttonStyle: FluentUI.ButtonStyle,
                                    buttonLabel: String,
                                    iconName: CompositeIcon?,
                                    isDisabled: Bool,
                                    action: @escaping (() -> Void)) -> PrimaryButtonViewModel
    func makeAudioDevicesListViewModel(dispatchAction: @escaping ActionDispatch,
                                       localUserState: LocalUserState) -> AudioDevicesListViewModel
    func makeAudioDevicesListCellViewModel(icon: CompositeIcon,
                                           title: String,
                                           isSelected: Bool,
                                           onSelectedAction: @escaping (() -> Void)) -> AudioDevicesListCellViewModel
    func makeErrorInfoViewModel(title: String,
                                subtitle: String) -> ErrorInfoViewModel

    // MARK: CallingViewModels
    func makeLobbyOverlayViewModel() -> LobbyOverlayViewModel
    func makeOnHoldOverlayViewModel(resumeAction: @escaping (() -> Void)) -> OnHoldOverlayViewModel
    func makeControlBarViewModel(dispatchAction: @escaping ActionDispatch,
                                 endCallConfirm: @escaping (() -> Void),
                                 localUserState: LocalUserState) -> ControlBarViewModel
    func makeInfoHeaderViewModel(localUserState: LocalUserState) -> InfoHeaderViewModel
    func makeParticipantCellViewModel(participantModel: ParticipantInfoModel) -> ParticipantGridCellViewModel
    func makeParticipantGridsViewModel(isIpadInterface: Bool) -> ParticipantGridViewModel
    func makeParticipantsListViewModel(localUserState: LocalUserState) -> ParticipantsListViewModel
    func makeBannerViewModel() -> BannerViewModel
    func makeBannerTextViewModel() -> BannerTextViewModel
    func makeLocalParticipantsListCellViewModel(localUserState: LocalUserState) -> ParticipantsListCellViewModel
    func makeParticipantsListCellViewModel(participantInfoModel: ParticipantInfoModel) -> ParticipantsListCellViewModel

    // MARK: SetupViewModels
    func makePreviewAreaViewModel(dispatchAction: @escaping ActionDispatch) -> PreviewAreaViewModel
    func makeSetupControlBarViewModel(dispatchAction: @escaping ActionDispatch,
                                      localUserState: LocalUserState) -> SetupControlBarViewModel
    func makeJoiningCallActivityViewModel() -> JoiningCallActivityViewModel
}

class CompositeViewModelFactory: CompositeViewModelFactoryProtocol {
    private let logger: Logger
    private let store: Store<AppState>
    private let accessibilityProvider: AccessibilityProviderProtocol
    private let localizationProvider: LocalizationProviderProtocol
    private let localOptions: LocalOptions?

    private weak var setupViewModel: SetupViewModel?
    private weak var callingViewModel: CallingViewModel?

    init(logger: Logger,
         store: Store<AppState>,
         localizationProvider: LocalizationProviderProtocol,
         accessibilityProvider: AccessibilityProviderProtocol,
         localOptions: LocalOptions?) {
        self.logger = logger
        self.store = store
        self.accessibilityProvider = accessibilityProvider
        self.localizationProvider = localizationProvider
        self.localOptions = localOptions
    }

    // MARK: CompositeViewModels
    func getSetupViewModel() -> SetupViewModel {
        guard let viewModel = self.setupViewModel else {
            let viewModel = SetupViewModel(compositeViewModelFactory: self,
                                           logger: logger,
                                           store: store,
                                           localizationProvider: localizationProvider,
                                           navigationBarViewData: localOptions?.navigationBarViewData)
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
    func makeIconWithLabelButtonViewModel(iconName: CompositeIcon,
                                          buttonTypeColor: IconWithLabelButtonViewModel.ButtonTypeColor,
                                          buttonLabel: String,
                                          isDisabled: Bool,
                                          action: @escaping (() -> Void)) -> IconWithLabelButtonViewModel {
        IconWithLabelButtonViewModel(iconName: iconName,
                                     buttonTypeColor: buttonTypeColor,
                                     buttonLabel: buttonLabel,
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
                                    action: @escaping (() -> Void)) -> PrimaryButtonViewModel {
        PrimaryButtonViewModel(buttonStyle: buttonStyle,
                               buttonLabel: buttonLabel,
                               iconName: iconName,
                               isDisabled: isDisabled,
                               action: action)
    }
    func makeAudioDevicesListViewModel(dispatchAction: @escaping ActionDispatch,
                                       localUserState: LocalUserState) -> AudioDevicesListViewModel {
        AudioDevicesListViewModel(compositeViewModelFactory: self,
                                  dispatchAction: dispatchAction,
                                  localUserState: localUserState,
                                  localizationProvider: localizationProvider)
    }

    func makeAudioDevicesListCellViewModel(icon: CompositeIcon,
                                           title: String,
                                           isSelected: Bool,
                                           onSelectedAction: @escaping (() -> Void)) -> AudioDevicesListCellViewModel {
        AudioDevicesListCellViewModel(icon: icon,
                                      title: title,
                                      isSelected: isSelected,
                                      onSelected: onSelectedAction)
    }

    func makeErrorInfoViewModel(title: String,
                                subtitle: String) -> ErrorInfoViewModel {
        ErrorInfoViewModel(localizationProvider: localizationProvider,
                           title: title,
                           subtitle: subtitle)
    }

    // MARK: CallingViewModels
    func makeLobbyOverlayViewModel() -> LobbyOverlayViewModel {
        LobbyOverlayViewModel(localizationProvider: localizationProvider,
                              accessibilityProvider: accessibilityProvider)
    }
    func makeOnHoldOverlayViewModel(resumeAction: @escaping (() -> Void)) -> OnHoldOverlayViewModel {
        OnHoldOverlayViewModel(localizationProvider: localizationProvider,
                               compositeViewModelFactory: self,
                               logger: logger,
                               accessibilityProvider: accessibilityProvider,
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
    func makeInfoHeaderViewModel(localUserState: LocalUserState) -> InfoHeaderViewModel {
        InfoHeaderViewModel(compositeViewModelFactory: self,
                            logger: logger,
                            localUserState: localUserState,
                            localizationProvider: localizationProvider,
                            accessibilityProvider: accessibilityProvider)
    }

    func makeParticipantCellViewModel(participantModel: ParticipantInfoModel) -> ParticipantGridCellViewModel {
        ParticipantGridCellViewModel(localizationProvider: localizationProvider,
                                     accessibilityProvider: accessibilityProvider,
                                     participantModel: participantModel)
    }
    func makeParticipantGridsViewModel(isIpadInterface: Bool) -> ParticipantGridViewModel {
        ParticipantGridViewModel(compositeViewModelFactory: self,
                                 localizationProvider: localizationProvider,
                                 accessibilityProvider: accessibilityProvider,
                                 isIpadInterface: isIpadInterface)
    }

    func makeParticipantsListViewModel(localUserState: LocalUserState) -> ParticipantsListViewModel {
        ParticipantsListViewModel(compositeViewModelFactory: self,
                                  localUserState: localUserState)
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
