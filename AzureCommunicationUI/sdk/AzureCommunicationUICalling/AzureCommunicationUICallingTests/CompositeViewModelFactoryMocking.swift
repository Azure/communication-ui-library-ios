//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import FluentUI
@testable import AzureCommunicationUICalling

class CompositeViewModelFactoryMocking: CompositeViewModelFactoryProtocol {
    private let logger: Logger
    private let store: Store<AppState>
    private let accessibilityProvider: AccessibilityProviderProtocol

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
    var lobbyOverlayViewModel: LobbyOverlayViewModel?
    var audioDevicesListViewModel: AudioDevicesListViewModel?
    var primaryButtonViewModel: PrimaryButtonViewModel?
    var iconButtonViewModel: IconButtonViewModel?
    var setupViewModel: SetupViewModel?
    var callingViewModel: CallingViewModel?
    var localParticipantsListCellViewModel: ParticipantsListCellViewModel?
    var audioDevicesListCellViewModel: AudioDevicesListCellViewModel?

    var createMockParticipantGridCellViewModel: ((ParticipantInfoModel) -> ParticipantGridCellViewModel?)?
    var createParticipantsListCellViewModel: ((ParticipantInfoModel) -> ParticipantsListCellViewModel?)?
    var createIconWithLabelButtonViewModel: ((CompositeIcon) -> IconWithLabelButtonViewModel?)?
    var createIconButtonViewModel: ((CompositeIcon) -> IconButtonViewModel?)?

    init(logger: Logger,
         store: Store<AppState>,
         accessibilityProvider: AccessibilityProviderProtocol = AccessibilityProviderMocking()) {
        self.logger = logger
        self.store = store
        self.accessibilityProvider = accessibilityProvider
    }

    func getSetupViewModel() -> SetupViewModel {
        return setupViewModel ?? SetupViewModel(compositeViewModelFactory: self,
                                                logger: logger,
                                                store: store,
                                                localizationProvider: LocalizationProviderMocking())
    }

    func getCallingViewModel() -> CallingViewModel {
        return callingViewModel ?? CallingViewModel(compositeViewModelFactory: self,
                                                    logger: logger,
                                                    store: store,
                                                    localizationProvider: LocalizationProviderMocking(),
                                                    accessibilityProvider: accessibilityProvider,
                                                    isIPadInterface: false)
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
                                                          localizationProvider: LocalizationProviderMocking(),
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

    func makeAudioDevicesListViewModel(dispatchAction: @escaping ActionDispatch,
                                       localUserState: LocalUserState) -> AudioDevicesListViewModel {
        return audioDevicesListViewModel ?? AudioDevicesListViewModel(compositeViewModelFactory: self,
                                                                      dispatchAction: dispatchAction,
                                                                      localUserState: localUserState,
                                                                      localizationProvider: LocalizationProviderMocking())
    }

    func makeErrorInfoViewModel() -> ErrorInfoViewModel {
        return errorInfoViewModel ?? ErrorInfoViewModel(localizationProvider: LocalizationProviderMocking())
    }

    func makeAudioDevicesListCellViewModel(icon: CompositeIcon,
                                           title: String,
                                           isSelected: Bool,
                                           onSelectedAction: @escaping (() -> Void)) -> AudioDevicesListCellViewModel {
        return audioDevicesListCellViewModel ?? AudioDevicesListCellViewModel(icon: icon,
                                                                              title: title,
                                                                              isSelected: isSelected,
                                                                              onSelected: onSelectedAction)
    }

    // MARK: CallingViewModels
    func makeLobbyOverlayViewModel() -> LobbyOverlayViewModel {
        return lobbyOverlayViewModel ?? LobbyOverlayViewModel(localizationProvider: LocalizationProviderMocking())
    }
    func makeControlBarViewModel(dispatchAction: @escaping ActionDispatch,
                                 endCallConfirm: @escaping (() -> Void),
                                 localUserState: LocalUserState) -> ControlBarViewModel {
        return controlBarViewModel ?? ControlBarViewModel(compositeViewModelFactory: self,
                                                          logger: logger,
                                                          localizationProvider: LocalizationProviderMocking(),
                                                          dispatchAction: dispatchAction,
                                                          endCallConfirm: endCallConfirm,
                                                          localUserState: localUserState)
    }

    func makeInfoHeaderViewModel(localUserState: LocalUserState) -> InfoHeaderViewModel {
        return infoHeaderViewModel ?? InfoHeaderViewModel(compositeViewModelFactory: self,
                                                          logger: logger,
                                                          localUserState: localUserState,
                                                          localizationProvider: LocalizationProviderMocking(),
                                                          accessibilityProvider: accessibilityProvider)
    }

    func makeParticipantCellViewModel(participantModel: ParticipantInfoModel) -> ParticipantGridCellViewModel {
        return createMockParticipantGridCellViewModel?(participantModel) ?? ParticipantGridCellViewModel(
            localizationProvider: LocalizationProviderMocking(),
            accessibilityProvider: AccessibilityProviderMocking(),
            participantModel: participantModel)
    }

    func makeParticipantGridsViewModel(isIpadInterface: Bool) -> ParticipantGridViewModel {
        return participantGridViewModel ?? ParticipantGridViewModel(compositeViewModelFactory: self,
                                                                    localizationProvider: LocalizationProviderMocking(),
																	accessibilityProvider: accessibilityProvider,
                                                                    isIPadInterface: isIpadInterface)
    }

    func makeParticipantsListViewModel(localUserState: LocalUserState) -> ParticipantsListViewModel {
        return participantsListViewModel ?? ParticipantsListViewModel(compositeViewModelFactory: self,
                                                                      localUserState: localUserState)
    }

    func makeBannerViewModel() -> BannerViewModel {
        return bannerViewModel ?? BannerViewModel(compositeViewModelFactory: self)
    }

    func makeBannerTextViewModel() -> BannerTextViewModel {
        return bannerTextViewModel ?? BannerTextViewModel(accessibilityProvider: accessibilityProvider,
                                                          localizationProvider: LocalizationProviderMocking())
    }

    func makeLocalParticipantsListCellViewModel(localUserState: LocalUserState) -> ParticipantsListCellViewModel {
        localParticipantsListCellViewModel ?? ParticipantsListCellViewModel(localUserState: localUserState,
                                                                            localizationProvider: LocalizationProviderMocking())
    }

    func makeParticipantsListCellViewModel(participantInfoModel: ParticipantInfoModel) -> ParticipantsListCellViewModel {
        createParticipantsListCellViewModel?(participantInfoModel) ?? ParticipantsListCellViewModel(participantInfoModel: participantInfoModel,
                                                                                                    localizationProvider: LocalizationProviderMocking())
    }

    // MARK: SetupViewModels
    func makePreviewAreaViewModel(dispatchAction: @escaping ActionDispatch) -> PreviewAreaViewModel {
        return previewAreaViewModel ?? PreviewAreaViewModel(compositeViewModelFactory: self,
                                                            dispatchAction: dispatchAction,
                                                            localizationProvider: LocalizationProviderMocking())
    }

    func makeSetupControlBarViewModel(dispatchAction: @escaping ActionDispatch,
                                      localUserState: LocalUserState) -> SetupControlBarViewModel {
        return setupControlBarViewModel ?? SetupControlBarViewModel(compositeViewModelFactory: self,
                                                                    logger: logger,
                                                                    dispatchAction: dispatchAction,
                                                                    localUserState: localUserState,
                                                                    localizationProvider: LocalizationProviderMocking())
    }

    func makeJoiningCallActivityViewModel() -> JoiningCallActivityViewModel {
        JoiningCallActivityViewModel(localizationProvider: LocalizationProviderMocking())
    }
}
