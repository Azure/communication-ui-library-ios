//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import Combine

class SetupViewModel: ObservableObject {
    private let logger: Logger
    private let store: Store<AppState>
    private let localizationProvider: LocalizationProviderProtocol

    private var callingStatus: CallingStatus = .none

    let isRightToLeft: Bool
    let previewAreaViewModel: PreviewAreaViewModel
    let title: String

    var errorInfoViewModel: ErrorInfoViewModel
    var dismissButtonViewModel: IconButtonViewModel!
    var joinCallButtonViewModel: PrimaryButtonViewModel!
    var setupControlBarViewModel: SetupControlBarViewModel!
    var joiningCallActivityViewModel: JoiningCallActivityViewModel!
    var cancellables = Set<AnyCancellable>()

    @Published var isJoinRequested: Bool = false

    init(compositeViewModelFactory: CompositeViewModelFactoryProtocol,
         logger: Logger,
         store: Store<AppState>,
         localizationProvider: LocalizationProviderProtocol) {
        self.store = store
        self.localizationProvider = localizationProvider
        self.isRightToLeft = localizationProvider.isRightToLeft
        self.logger = logger

        title = self.localizationProvider.getLocalizedString(.setupTitle)

        previewAreaViewModel = compositeViewModelFactory.makePreviewAreaViewModel(dispatchAction: store.dispatch)

        joiningCallActivityViewModel = compositeViewModelFactory.makeJoiningCallActivityViewModel()

        errorInfoViewModel = compositeViewModelFactory.makeErrorInfoViewModel(title: "",
                                                                              subtitle: "")

        joinCallButtonViewModel = compositeViewModelFactory.makePrimaryButtonViewModel(
            buttonStyle: .primaryFilled,
            buttonLabel: self.localizationProvider
                .getLocalizedString(.joinCall),
            iconName: .meetNow,
            isDisabled: false) { [weak self] in
                guard let self = self else {
                    return
                }
                self.joinCallButtonTapped()
        }
        joinCallButtonViewModel.update(accessibilityLabel: self.localizationProvider.getLocalizedString(.joinCall))

        dismissButtonViewModel = compositeViewModelFactory.makeIconButtonViewModel(
            iconName: .leftArrow,
            buttonType: .controlButton,
            isDisabled: false) { [weak self] in
                guard let self = self else {
                    return
                }
                self.dismissButtonTapped()
        }
        dismissButtonViewModel.update(
            accessibilityLabel: self.localizationProvider.getLocalizedString(.dismissAccessibilityLabel))

        setupControlBarViewModel = compositeViewModelFactory
            .makeSetupControlBarViewModel(dispatchAction: store.dispatch,
                                          localUserState: store.state.localUserState)

        store.$state
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.receive(state)
            }.store(in: &cancellables)

        $isJoinRequested.sink { [weak self] value in
            self?.setupControlBarViewModel.update(isJoinRequested: value)
        }.store(in: &cancellables)
    }

    func setupAudioPermissions() {
        if store.state.permissionState.audioPermission == .notAsked {
            store.dispatch(action: .permissionAction(.audioPermissionRequested))
        }
    }

    func setupCall() {
        store.dispatch(action: .callingAction(.setupCall))
    }

    func joinCallButtonTapped() {
        store.dispatch(action: .callingAction(.callStartRequested))
        isJoinRequested = true
    }

    func dismissButtonTapped() {
        let isJoining = callingStatus != .none
        let action: Action = isJoining ? .callingAction(.callEndRequested) : .compositeExitAction
        store.dispatch(action: action)
    }

    func receive(_ state: AppState) {
        let newCallingStatus = state.callingState.status
        if callingStatus != newCallingStatus,
           newCallingStatus == .none {
            isJoinRequested = false
        }

        callingStatus = newCallingStatus
        let localUserState = state.localUserState
        let permissionState = state.permissionState
        let callingState = state.callingState
        previewAreaViewModel.update(localUserState: localUserState,
                                    permissionState: permissionState)
        setupControlBarViewModel.update(localUserState: localUserState,
                                        permissionState: permissionState,
                                        callingState: callingState)
        joinCallButtonViewModel.update(isDisabled: permissionState.audioPermission == .denied)
        errorInfoViewModel.update(errorState: state.errorState)
    }
}
