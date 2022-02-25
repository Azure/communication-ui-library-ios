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
    var controlBarViewModel: ControlBarViewModel?
    var infoHeaderViewModel: InfoHeaderViewModel?
    var localVideoViewModel: LocalVideoViewModel?
    var participantGridViewModel: ParticipantGridViewModel?
    var participantsListViewModel: ParticipantsListViewModel?
    var bannerViewModel: BannerViewModel?
    var previewAreaViewModel: PreviewAreaViewModel?
    var setupControlBarViewModel: SetupControlBarViewModel?
    var errorInfoViewModel: ErrorInfoViewModel?
    var audioDeviceListViewModel: AudioDeviceListViewModel?
    var primaryButtonViewModel: PrimaryButtonViewModel?
    var iconButtonViewModel: IconButtonViewModel?
    var setupViewModel: SetupViewModel?
    var callingViewModel: CallingViewModel?

    var createMockParticipantGridCellViewModel: ((ParticipantInfoModel) -> ParticipantGridCellViewModel?)?
    var createIconWithLabelButtonViewModel: ((CompositeIcon) -> IconWithLabelButtonViewModel?)?

    init(logger: Logger,
         store: Store<AppState>) {
        self.logger = logger
        self.store = store
    }

    func getSetupViewModel() -> SetupViewModel {
        return setupViewModel ?? SetupViewModel(compositeViewModelFactory: self,
                                                logger: logger,
                                                store: store)
    }

    func getCallingViewModel() -> CallingViewModel {
        return callingViewModel ?? CallingViewModel(compositeViewModelFactory: self,
                                                    logger: logger,
                                                    store: store)
    }

    func makeIconButtonViewModel(iconName: CompositeIcon,
                                 buttonType: IconButtonViewModel.ButtonType,
                                 isDisabled: Bool,
                                 action: @escaping (() -> Void)) -> IconButtonViewModel {
        return iconButtonViewModel ?? IconButtonViewModel(iconName: iconName,
                                                          buttonType: buttonType,
                                                          isDisabled: isDisabled,
                                                          action: action)
    }

    func makeIconWithLabelButtonViewModel(iconName: CompositeIcon,
                                          buttonTypeColor: IconWithLabelButtonViewModel.ButtonTypeColor,
                                          buttonLabel: String,
                                          isDisabled: Bool,
                                          action: @escaping (() -> Void)) -> IconWithLabelButtonViewModel {
        return createIconWithLabelButtonViewModel?(iconName) ?? IconWithLabelButtonViewModel(iconName: iconName,
                                                                                             buttonTypeColor: buttonTypeColor,
                                                                                             buttonLabel: buttonLabel,
                                                                                             isDisabled: isDisabled,
                                                                                             action: action)
    }

    func makeLocalVideoViewModel(dispatchAction: @escaping ActionDispatch) -> LocalVideoViewModel {
        return localVideoViewModel ?? LocalVideoViewModel(compositeViewModelFactory: self,
                                                          logger: logger,
                                                          dispatchAction: dispatchAction)
    }

    func makePrimaryButtonViewModel(buttonStyle: ButtonStyle,
                                    buttonLabel: String,
                                    iconName: CompositeIcon?,
                                    isDisabled: Bool,
                                    action: @escaping (() -> Void)) -> PrimaryButtonViewModel {
        return primaryButtonViewModel ?? PrimaryButtonViewModel(buttonStyle: buttonStyle,
                                                                buttonLabel: buttonLabel,
                                                                iconName: iconName,
                                                                isDisabled: isDisabled,
                                                                action: action)
    }

    func makeAudioDeviceListViewModel(dispatchAction: @escaping ActionDispatch,
                                      localUserState: LocalUserState) -> AudioDeviceListViewModel {
        return audioDeviceListViewModel ?? AudioDeviceListViewModel(dispatchAction: dispatchAction,
                                                                    localUserState: localUserState)
    }

    func makeErrorInfoViewModel() -> ErrorInfoViewModel {
        return errorInfoViewModel ?? ErrorInfoViewModel()
    }

    // MARK: CallingViewModels
    func makeControlBarViewModel(dispatchAction: @escaping ActionDispatch,
                                 endCallConfirm: @escaping (() -> Void),
                                 localUserState: LocalUserState) -> ControlBarViewModel {
        return controlBarViewModel ?? ControlBarViewModel(compositeViewModelFactory: self,
                                                          logger: logger,
                                                          dispatchAction: dispatchAction,
                                                          endCallConfirm: endCallConfirm,
                                                          localUserState: localUserState)
    }

    func makeInfoHeaderViewModel(localUserState: LocalUserState) -> InfoHeaderViewModel {
        return infoHeaderViewModel ?? InfoHeaderViewModel(compositeViewModelFactory: self,
                                                          logger: logger,
                                                          localUserState: localUserState)
    }

    func makeParticipantCellViewModel(participantModel: ParticipantInfoModel) -> ParticipantGridCellViewModel {
        return createMockParticipantGridCellViewModel?(participantModel) ?? ParticipantGridCellViewModel(compositeViewModelFactory: self,
                                                                                                         participantModel: participantModel)
    }

    func makeParticipantGridsViewModel() -> ParticipantGridViewModel {
        return participantGridViewModel ?? ParticipantGridViewModel(compositeViewModelFactory: self)
    }

    func makeParticipantsListViewModel(localUserState: LocalUserState) -> ParticipantsListViewModel {
        return participantsListViewModel ?? ParticipantsListViewModel(localUserState: localUserState)
    }

    func makeBannerViewModel() -> BannerViewModel {
        return bannerViewModel ?? BannerViewModel(compositeViewModelFactory: self)
    }

    func makeBannerTextViewModel() -> BannerTextViewModel {
        return bannerTextViewModel ??
            BannerTextViewModel()
    }

    // MARK: SetupViewModels
    func makePreviewAreaViewModel(dispatchAction: @escaping ActionDispatch) -> PreviewAreaViewModel {
        return previewAreaViewModel ?? PreviewAreaViewModel(compositeViewModelFactory: self, dispatchAction: dispatchAction)
    }

    func makeSetupControlBarViewModel(dispatchAction: @escaping ActionDispatch,
                                      localUserState: LocalUserState) -> SetupControlBarViewModel {
        return setupControlBarViewModel ?? SetupControlBarViewModel(compositeViewModelFactory: self,
                                                                    logger: logger,
                                                                    dispatchAction: dispatchAction,
                                                                    localUserState: localUserState)
    }
}
