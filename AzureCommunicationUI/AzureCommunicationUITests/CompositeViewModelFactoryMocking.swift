//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import FluentUI
@testable import AzureCommunicationUI

class CompositeViewModelFactoryMocking: CompositeViewModelFactory {
    var logger: Logger
    var store: Store<AppState>

    var bannerTextViewModel: BannerTextViewModel?

    init(logger: Logger,
         store: Store<AppState>) {
        self.logger = logger
        self.store = store
    }

    func getSetupViewModel() -> SetupViewModel {
        return SetupViewModel(compositeViewModelFactory: self, logger: logger, store: store)
    }

    func getCallingViewModel() -> CallingViewModel {
        return CallingViewModel(compositeViewModelFactory: self, logger: logger, store: store)
    }

    func makeIconButtonViewModel(iconName: CompositeIcon,
                                 buttonType: IconButtonViewModel.ButtonType,
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
        LocalVideoViewModel(compositeViewModelFactory: self, logger: logger, dispatchAction: dispatchAction)
    }

    func makePrimaryButtonViewModel(buttonStyle: ButtonStyle,
                                    buttonLabel: String,
                                    iconName: CompositeIcon?,
                                    isDisabled: Bool,
                                    action: @escaping (() -> Void)) -> PrimaryButtonViewModel {
        PrimaryButtonViewModel(buttonStyle: buttonStyle,
                               buttonLabel: buttonLabel,
                               iconName: iconName,
                               isDisabled: isDisabled,
                               action: action)
    }
    func makeAudioDeviceListViewModel(dispatchAction: @escaping ActionDispatch,
                                      localUserState: LocalUserState) -> AudioDeviceListViewModel {
        AudioDeviceListViewModel(dispatchAction: dispatchAction,
                                 localUserState: localUserState)
    }
    func makeErrorInfoViewModel() -> ErrorInfoViewModel {
        ErrorInfoViewModel()
    }

    // MARK: CallingViewModels
    func makeControlBarViewModel(dispatchAction: @escaping ActionDispatch,
                                 endCallConfirm: @escaping (() -> Void),
                                 localUserState: LocalUserState) -> ControlBarViewModel {
        ControlBarViewModel(compositeViewModelFactory: self,
                            logger: logger,
                            dispatchAction: dispatchAction,
                            endCallConfirm: endCallConfirm,
                            localUserState: localUserState)
    }

    func makeInfoHeaderViewModel(localUserState: LocalUserState) -> InfoHeaderViewModel {
        InfoHeaderViewModel(compositeViewModelFactory: self,
                            logger: logger,
                            localUserState: localUserState)
    }
    func makeParticipantCellViewModel(participantModel: ParticipantInfoModel) -> ParticipantGridCellViewModel {
        ParticipantGridCellViewModel(compositeViewModelFactory: self, participantModel: participantModel)
    }
    func makeParticipantGridsViewModel() -> ParticipantGridViewModel {
        ParticipantGridViewModel(compositeViewModelFactory: self)
    }
    func makeParticipantsListViewModel(localUserState: LocalUserState) -> ParticipantsListViewModel {
        ParticipantsListViewModel(localUserState: localUserState)
    }
    func makeBannerViewModel() -> BannerViewModel {
        BannerViewModel(compositeViewModelFactory: self)
    }


    func makeBannerTextViewModel() -> BannerTextViewModel {
        return bannerTextViewModel ??
            BannerTextViewModel()
    }

    // MARK: SetupViewModels
    func makePreviewAreaViewModel(dispatchAction: @escaping ActionDispatch) -> PreviewAreaViewModel {
        PreviewAreaViewModel(compositeViewModelFactory: self, dispatchAction: dispatchAction)
    }

    func makeSetupControlBarViewModel(dispatchAction: @escaping ActionDispatch,
                                      localUserState: LocalUserState) -> SetupControlBarViewModel {
        SetupControlBarViewModel(compositeViewModelFactory: self,
                                 logger: logger,
                                 dispatchAction: dispatchAction,
                                 localUserState: localUserState)
    }
}
