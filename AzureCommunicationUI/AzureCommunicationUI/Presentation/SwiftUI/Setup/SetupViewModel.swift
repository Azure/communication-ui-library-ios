//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import Combine

class SetupViewModel: ObservableObject {
    private let logger: Logger
    private let store: Store<AppState>
    private var callingStatus: CallingStatus = .none
    var cancellables = Set<AnyCancellable>()

    let previewAreaViewModel: PreviewAreaViewModel
    var errorInfoViewModel: ErrorInfoViewModel
    var dismissButtonViewModel: IconButtonViewModel!
    var joinCallButtonViewModel: PrimaryButtonViewModel!
    var setupControlBarViewModel: SetupControlBarViewModel!

    @Published var isJoinRequested: Bool = false
    @Published var isPermissionsDenied: Bool = false

    init(compositeViewModelFactory: CompositeViewModelFactory,
         logger: Logger,
         store: Store<AppState>) {
        self.store = store
        self.logger = logger
        self.previewAreaViewModel = compositeViewModelFactory.makePreviewAreaViewModel(dispatchAction: store.dispatch)
        self.errorInfoViewModel = compositeViewModelFactory.makeErrorInfoViewModel()
        self.joinCallButtonViewModel = compositeViewModelFactory.makePrimaryButtonViewModel(
            buttonStyle: .primaryFilled,
            buttonLabel: "Join Call",
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

        $isJoinRequested.sink { [weak self] value in
            self?.setupControlBarViewModel.update(isJoinRequested: value)
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
        update(permissionState: permissionState)
        previewAreaViewModel.update(localUserState: localUserState,
                                    permissionState: permissionState)
        setupControlBarViewModel.update(localUserState: localUserState,
                                        permissionState: permissionState,
                                        callingState: callingState)
        joinCallButtonViewModel.update(isDisabled: permissionState.audioPermission == .denied)

        errorInfoViewModel.update(errorState: state.errorState)
    }

    private func update(permissionState: PermissionState) {
        let cameraPermission = permissionState.cameraPermission
        let audioPermission = permissionState.audioPermission
        let isPermissionDenied = cameraPermission == .denied || audioPermission == .denied
        if isPermissionDenied != self.isPermissionsDenied {
            self.isPermissionsDenied = isPermissionDenied
        }
    }

}
