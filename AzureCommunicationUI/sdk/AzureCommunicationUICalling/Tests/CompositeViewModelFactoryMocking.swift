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
    private let localizationProvider: LocalizationProviderProtocol

    var bannerTextViewModel: BannerTextViewModel?
    var controlBarViewModel: ControlBarViewModel?
    var infoHeaderViewModel: InfoHeaderViewModel?
    var localVideoViewModel: LocalVideoViewModel?
    var participantGridViewModel: ParticipantGridViewModel?
    var participantsListViewModel: ParticipantsListViewModel?
    var bannerViewModel: BannerViewModel?
    var onHoldOverlayViewModel: OnHoldOverlayViewModel?
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
    var createIconButtonViewModel: ((CompositeIcon) -> IconButtonViewModel?)?

    init(logger: Logger,
         store: Store<AppState>,
         accessibilityProvider: AccessibilityProviderProtocol = AccessibilityProviderMocking(),
         localizationProvider: LocalizationProviderProtocol = LocalizationProviderMocking()) {
        self.logger = logger
        self.store = store
        self.accessibilityProvider = accessibilityProvider
        self.localizationProvider = localizationProvider
    }

    func getSetupViewModel() -> SetupViewModel {
        return setupViewModel ?? SetupViewModel(compositeViewModelFactory: self,
                                                logger: logger,
                                                store: store,
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
                                        return IconWithLabelButtonViewModel(selectedButtonState: selectedButtonState,
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
        return lobbyOverlayViewModel ?? LobbyOverlayViewModel(localizationProvider: localizationProvider,
                                                              accessibilityProvider: accessibilityProvider)
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

    func makeInfoHeaderViewModel(localUserState: LocalUserState) -> InfoHeaderViewModel {
        return infoHeaderViewModel ?? InfoHeaderViewModel(compositeViewModelFactory: self,
                                                          logger: logger,
                                                          localUserState: localUserState,
                                                          localizationProvider: localizationProvider,
                                                          accessibilityProvider: accessibilityProvider)
    }

    func makeParticipantCellViewModel(participantModel: ParticipantInfoModel) -> ParticipantGridCellViewModel {
        return createMockParticipantGridCellViewModel?(participantModel) ?? ParticipantGridCellViewModel(
            localizationProvider: localizationProvider,
            accessibilityProvider: accessibilityProvider,
            participantModel: participantModel)
    }

    func makeParticipantGridsViewModel(isIpadInterface: Bool) -> ParticipantGridViewModel {
        return participantGridViewModel ?? ParticipantGridViewModel(compositeViewModelFactory: self,
                                                                    localizationProvider: localizationProvider,
																	accessibilityProvider: accessibilityProvider,
                                                                    isIpadInterface: isIpadInterface)
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
                                      resumeAction: {})
    }
}

class CompositeVmButtonFactoryMocking: CompositeViewModelFactoryMocking {
    var createCameraIconWithLabelButtonViewModel: ((CameraState) -> IconWithLabelButtonViewModel<CameraState>?)?
    var createMicIconWithLabelButtonViewModel: ((MicState) -> IconWithLabelButtonViewModel<MicState>?)?
    var createAudioIconWithLabelButtonViewModel: ((AudioState) -> IconWithLabelButtonViewModel<AudioState>?)?

    override init(logger: Logger, store: Store<AppState>, accessibilityProvider: AccessibilityProviderProtocol = AccessibilityProviderMocking(), localizationProvider: LocalizationProviderProtocol = LocalizationProviderMocking()) {
        super.init(logger: logger, store: store, accessibilityProvider: accessibilityProvider, localizationProvider: localizationProvider)
    }

    override func makeIconWithLabelButtonViewModel<ButtonStateType>(
        selectedButtonState: ButtonStateType,
        localizationProvider: LocalizationProviderProtocol,
        buttonTypeColor: IconWithLabelButtonViewModel<ButtonStateType>.ButtonTypeColor,
        isDisabled: Bool,
        action: @escaping (() -> Void)
    ) -> IconWithLabelButtonViewModel<ButtonStateType> {

        if let cameraStateClosure = createCameraIconWithLabelButtonViewModel,
           let cameraState = selectedButtonState as? CameraState,
           let vm = cameraStateClosure(cameraState) as? IconWithLabelButtonViewModel<ButtonStateType> {
            return vm
        }

        if let micStateClosure = createMicIconWithLabelButtonViewModel,
           let micState = selectedButtonState as? MicState,
           let vm = micStateClosure(micState) as? IconWithLabelButtonViewModel<ButtonStateType> {
            return vm
        }

        return super.makeIconWithLabelButtonViewModel(
            selectedButtonState: selectedButtonState,
            localizationProvider: localizationProvider,
            buttonTypeColor: buttonTypeColor,
            isDisabled: isDisabled,
            action: action
        )
    }
}
