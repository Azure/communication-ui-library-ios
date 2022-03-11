//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import Combine

class SetupViewModel: ObservableObject {
    private let logger: Logger
    private let store: Store<AppState>
    private let localizationProvider: LocalizationProvider
    private var callingStatus: CallingStatus = .none
    var cancellables = Set<AnyCancellable>()

    @Published var isJoinRequested: Bool = false
    let isRightToLeft: Bool

    let previewAreaViewModel: PreviewAreaViewModel
    var errorInfoViewModel: ErrorInfoViewModel
    var dismissButtonViewModel: IconButtonViewModel!
    var joinCallButtonViewModel: PrimaryButtonViewModel!
    var setupControlBarViewModel: SetupControlBarViewModel!
    var joiningCallActivityViewModel: JoiningCallActivityViewModel!

    init(compositeViewModelFactory: CompositeViewModelFactory,
         logger: Logger,
         store: Store<AppState>,
         localizationProvider: LocalizationProvider) {
        self.store = store
        self.localizationProvider = localizationProvider
        self.isRightToLeft = localizationProvider.isRightToLeft
        self.logger = logger
        self.previewAreaViewModel = compositeViewModelFactory.makePreviewAreaViewModel(dispatchAction: store.dispatch)
        self.joiningCallActivityViewModel = compositeViewModelFactory.makeJoiningCallActivityViewModel()
        self.errorInfoViewModel = compositeViewModelFactory.makeErrorInfoViewModel()
        self.joinCallButtonViewModel = compositeViewModelFactory.makePrimaryButtonViewModel(
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

        self.dismissButtonViewModel = compositeViewModelFactory.makeIconButtonViewModel(
            iconName: .leftArrow,
            buttonType: .controlButton,
            isDisabled: false) { [weak self] in
                guard let self = self else {
                    return
                }
                self.dismissButtonTapped()
        }
        self.setupControlBarViewModel = compositeViewModelFactory
            .makeSetupControlBarViewModel(dispatchAction: store.dispatch,
                                          localUserState: store.state.localUserState)

        store.$state
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.receive(state)
            }.store(in: &cancellables)
    }

    func setupAudioPermissions() {
        if store.state.permissionState.audioPermission == .notAsked {
            store.dispatch(action: PermissionAction.AudioPermissionRequested())
        }
    }

    func setupCall() {
        store.dispatch(action: CallingAction.SetupCall())
    }

    func joinCallButtonTapped() {
        store.dispatch(action: CallingAction.CallStartRequested())
        isJoinRequested = true
    }

    func dismissButtonTapped() {
        let isJoining = callingStatus != .none
        let action: Action = isJoining ? CallingAction.CallEndRequested() : CompositeExitAction()
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
