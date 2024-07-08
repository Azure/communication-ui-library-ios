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
    func makeCaptionsLanguageListViewModel (dispatchAction: @escaping ActionDispatch,
                                            state: AppState) -> CaptionsLanguageListViewModel
    func makeCaptionsInfoViewModel (state: AppState) -> CaptionsInfoViewModel
    func makeCaptionsErrorViewModel (dispatchAction: @escaping ActionDispatch) -> CaptionsErrorHeaderViewModel
    func makeErrorInfoViewModel(title: String,
                                subtitle: String) -> ErrorInfoViewModel
    func makeCallDiagnosticsViewModel(dispatchAction: @escaping ActionDispatch) -> CallDiagnosticsViewModel
    // MARK: CallingViewModels
    func makeLobbyOverlayViewModel() -> LobbyOverlayViewModel
    func makeLoadingOverlayViewModel() -> LoadingOverlayViewModel
    func makeOnHoldOverlayViewModel(resumeAction: @escaping (() -> Void)) -> OnHoldOverlayViewModel
    func makeControlBarViewModel(dispatchAction: @escaping ActionDispatch,
                                 onEndCallTapped: @escaping (() -> Void),
                                 localUserState: LocalUserState,
                                 leaveCallConfirmationMode: LeaveCallConfirmationMode) -> ControlBarViewModel
    func makeInfoHeaderViewModel(dispatchAction: @escaping ActionDispatch,
                                 localUserState: LocalUserState) -> InfoHeaderViewModel
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
    func makeMoreCallOptionsListViewModel(
        isDisplayed: Bool,
        isCaptionsAvailable: Bool,
        showSharingViewAction: @escaping () -> Void,
        showSupportFormAction: @escaping () -> Void,
        showCaptionsViewAction: @escaping () -> Void) -> MoreCallOptionsListViewModel
    func makeCaptionsListViewModel(state: AppState,
                                   captionsOptions: CaptionsOptions,
                                   dispatchAction: @escaping ActionDispatch,
                                   showSpokenLanguage: @escaping () -> Void,
                                   showCaptionsLanguage: @escaping () -> Void,
                                   isDisplayed: Bool) -> CaptionsListViewModel
    func makeDebugInfoSharingActivityViewModel() -> DebugInfoSharingActivityViewModel
    func makeDrawerListItemViewModel(icon: CompositeIcon,
                                     title: String,
                                     accessibilityIdentifier: String,
                                     titleTrailingAccessoryView: CompositeIcon?,
                                     action: @escaping (() -> Void)) -> DrawerListItemViewModel

    func makeToggleListItemViewModel(icon: CompositeIcon,
                                     title: String,
                                     isToggleOn: Binding<Bool>,
                                     showToggle: Bool,
                                     accessibilityIdentifier: String,
                                     action: @escaping (() -> Void)) -> DrawerListItemViewModel

    func makeLanguageListItemViewModel(icon: CompositeIcon,
                                       title: String,
                                       subtitle: String?,
                                       accessibilityIdentifier: String,
                                       titleTrailingAccessoryView: CompositeIcon?,
                                       isEnabled: Bool?,
                                       action: @escaping (() -> Void)) -> DrawerListItemViewModel
    func makeLeaveCallConfirmationViewModel(
        endCall: @escaping (() -> Void),
        dismissConfirmation: @escaping (() -> Void)) -> LeaveCallConfirmationViewModel

    func makeSelectableDrawerListItemViewModel(
        icon: CompositeIcon,
        title: String,
        isSelected: Bool,
        onSelectedAction: @escaping (() -> Void)) -> SelectableDrawerListItemViewModel
    func makeSupportFormViewModel() -> SupportFormViewModel
    // MARK: SetupViewModels
    func makePreviewAreaViewModel(dispatchAction: @escaping ActionDispatch) -> PreviewAreaViewModel
    func makeSetupControlBarViewModel(dispatchAction: @escaping ActionDispatch,
                                      localUserState: LocalUserState) -> SetupControlBarViewModel
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
