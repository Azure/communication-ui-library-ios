//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import FluentUI
import Foundation
import SwiftUI

protocol CompositeViewModelFactoryProtocol {
    // MARK: CompositeViewModels
    func getSetupViewModel() -> SetupViewModel
    func getCallingViewModel(rendererViewManager: RendererViewManager) -> CallingViewModel
    // MARK: ComponentViewModels
    func makeIconButtonViewModel(iconName: CompositeIcon,
                                 buttonType: IconButtonViewModel.ButtonType,
                                 isDisabled: Bool,
                                 action: @escaping (() -> Void)) -> IconButtonViewModel
    func makeIconButtonViewModel(iconName: CompositeIcon,
                                 buttonType: IconButtonViewModel.ButtonType,
                                 isDisabled: Bool,
                                 isVisible: Bool,
                                 action: @escaping (() -> Void)) -> IconButtonViewModel
    func makeIconButtonViewModel(icon: UIImage,
                                 buttonType: IconButtonViewModel.ButtonType,
                                 isDisabled: Bool,
                                 isVisible: Bool,
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
    func makeCaptionsLanguageListViewModel (dispatchAction: @escaping ActionDispatch,
                                            state: AppState) -> CaptionsLanguageListViewModel
    func makeCaptionsRttInfoViewModel (state: AppState,
                                       captionsOptions: CaptionsOptions) -> CaptionsRttInfoViewModel
    func makeCaptionsErrorViewModel (dispatchAction: @escaping ActionDispatch) -> CaptionsErrorViewModel
    func makeErrorInfoViewModel(title: String,
                                subtitle: String) -> ErrorInfoViewModel
    // MARK: CallingViewModels
    func makeLobbyOverlayViewModel() -> LobbyOverlayViewModel
    func makeLoadingOverlayViewModel() -> LoadingOverlayViewModel
    func makeOnHoldOverlayViewModel(resumeAction: @escaping (() -> Void)) -> OnHoldOverlayViewModel
    func makeControlBarViewModel(dispatchAction: @escaping ActionDispatch,
                                 onEndCallTapped: @escaping (() -> Void),
                                 localUserState: LocalUserState,
                                 capabilitiesManager: CapabilitiesManager,
                                 buttonViewDataState: ButtonViewDataState) -> ControlBarViewModel
    func makeInfoHeaderViewModel(dispatchAction: @escaping ActionDispatch,
                                 localUserState: LocalUserState,
                                 callScreenInfoHeaderState: CallScreenInfoHeaderState,
                                 buttonViewDataState: ButtonViewDataState,
                                 controlHeaderViewData: CallScreenHeaderViewData?
    ) -> InfoHeaderViewModel
    func makeLobbyWaitingHeaderViewModel(localUserState: LocalUserState,
                                         dispatchAction: @escaping ActionDispatch) -> LobbyWaitingHeaderViewModel
    func makeLobbyActionErrorViewModel(localUserState: LocalUserState,
                                       dispatchAction: @escaping ActionDispatch) -> LobbyErrorHeaderViewModel
    func makeParticipantGridsViewModel(isIpadInterface: Bool,
                                       rendererViewManager: RendererViewManager) -> ParticipantGridViewModel

    func makeParticipantCellViewModel(participantModel: ParticipantInfoModel) -> ParticipantGridCellViewModel

    func makeParticipantsListViewModel(localUserState: LocalUserState,
                                       isDisplayed: Bool,
                                       dispatchAction: @escaping ActionDispatch) -> ParticipantsListViewModel

    func makeParticipantMenuViewModel(localUserState: LocalUserState,
                                      isDisplayed: Bool,
                                      dispatchAction: @escaping ActionDispatch) -> ParticipantMenuViewModel

    func makeBannerViewModel(dispatchAction: @escaping ActionDispatch) -> BannerViewModel
    func makeBannerTextViewModel() -> BannerTextViewModel
    func makeMoreCallOptionsListViewModel(
        isCaptionsAvailable: Bool,
        buttonActions: ButtonActions,
        controlBarOptions: CallScreenControlBarOptions?,
        buttonViewDataState: ButtonViewDataState,
        dispatchAction: @escaping ActionDispatch) -> MoreCallOptionsListViewModel
    func makeCaptionsRttListViewModel(state: AppState,
                                      captionsOptions: CaptionsOptions,
                                      dispatchAction: @escaping ActionDispatch,
                                      buttonActions: ButtonActions,
                                      isDisplayed: Bool) -> CaptionsRttListViewModel
    func makeDebugInfoSharingActivityViewModel() -> DebugInfoSharingActivityViewModel

    func makeToggleListItemViewModel(title: String,
                                     isToggleOn: Binding<Bool>,
                                     showToggle: Bool,
                                     accessibilityIdentifier: String,
                                     startIcon: CompositeIcon,
                                     isEnabled: Bool,
                                     action: @escaping (() -> Void)) -> DrawerGenericItemViewModel

    func makeLanguageListItemViewModel(title: String,
                                       subtitle: String?,
                                       accessibilityIdentifier: String,
                                       startIcon: CompositeIcon,
                                       endIcon: CompositeIcon?,
                                       isEnabled: Bool,
                                       action: @escaping (() -> Void)) -> DrawerGenericItemViewModel
    func makeCaptionsLangaugeCellViewModel(title: String,
                                           isSelected: Bool,
                                           accessibilityLabel: String,
                                           onSelectedAction: @escaping (() -> Void)) -> DrawerSelectableItemViewModel
    func makeLeaveCallConfirmationViewModel(
        endCall: @escaping (() -> Void),
        dismissConfirmation: @escaping (() -> Void)) -> LeaveCallConfirmationViewModel

    func makeSupportFormViewModel() -> SupportFormViewModel
    func makeCallDiagnosticsViewModel(dispatchAction: @escaping ActionDispatch) -> CallDiagnosticsViewModel
    func makeBottomToastViewModel(toastNotificationState: ToastNotificationState,
                                  dispatchAction: @escaping ActionDispatch) -> BottomToastViewModel
    // MARK: SetupViewModels
    func makePreviewAreaViewModel(dispatchAction: @escaping ActionDispatch) -> PreviewAreaViewModel
    func makeSetupControlBarViewModel(dispatchAction: @escaping ActionDispatch,
                                      localUserState: LocalUserState,
                                      buttonViewDataState: ButtonViewDataState) -> SetupControlBarViewModel
    func makeJoiningCallActivityViewModel(title: String) -> JoiningCallActivityViewModel
}

extension CompositeViewModelFactoryProtocol {
    func makePrimaryButtonViewModel(buttonStyle: FluentUI.ButtonStyle,
                                    buttonLabel: String,
                                    iconName: CompositeIcon? = CompositeIcon.none,
                                    isDisabled: Bool = false,
                                    action: @escaping (() -> Void)) -> PrimaryButtonViewModel {
        return makePrimaryButtonViewModel(buttonStyle: buttonStyle,
                                          buttonLabel: buttonLabel,
                                          iconName: iconName,
                                          isDisabled: isDisabled,
                                          paddings: nil,
                                          action: action)
    }

    func makeJoiningCallActivityViewModel(title: String) -> JoiningCallActivityViewModel {
        return JoiningCallActivityViewModel(title: title)
    }
}
