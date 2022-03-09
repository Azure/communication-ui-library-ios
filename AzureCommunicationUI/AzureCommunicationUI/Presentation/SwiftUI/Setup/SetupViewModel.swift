//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import Combine

class SetupViewModel: ObservableObject {
    private let logger: Logger
    private let store: Store<AppState>
    var cancellables = Set<AnyCancellable>()

    let previewAreaViewModel: PreviewAreaViewModel
    let dismissButtonViewModel: IconButtonViewModel
    var errorInfoViewModel: ErrorInfoViewModel
    var startCallButtonViewModel: PrimaryButtonViewModel!
    var setupControlBarViewModel: SetupControlBarViewModel!

    init(compositeViewModelFactory: CompositeViewModelFactory,
         logger: Logger,
         store: Store<AppState>) {
        self.store = store
        self.logger = logger

        self.previewAreaViewModel = compositeViewModelFactory.makePreviewAreaViewModel(dispatchAction: store.dispatch)

        self.dismissButtonViewModel = compositeViewModelFactory.makeIconButtonViewModel(
            iconName: .leftArrow,
            buttonType: .controlButton,
            isDisabled: false) {
                store.dispatch(action: CallingAction.DismissSetup())
        }
        self.dismissButtonViewModel.accessibilityLabel = "Back"

        self.errorInfoViewModel = compositeViewModelFactory.makeErrorInfoViewModel()

        self.startCallButtonViewModel = compositeViewModelFactory.makePrimaryButtonViewModel(
            buttonStyle: .primaryFilled,
            buttonLabel: "Join Call",
            iconName: .meetNow,
            isDisabled: false) { [weak self] in
                guard let self = self else {
                    return
                }
                self.startCallButtonTapped()
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

    func getTitle() -> String {
        return "Setup" // Replace with contextual title
    }

    func setupAudioPermissions() {
        if store.state.permissionState.audioPermission == .notAsked {
            store.dispatch(action: PermissionAction.AudioPermissionRequested())
        }
    }

    func setupCall() {
        store.dispatch(action: CallingAction.SetupCall())
    }

    func startCallButtonTapped() {
        store.dispatch(action: CallingViewLaunched())
    }

    func receive(_ state: AppState) {
        let localUserState = state.localUserState
        let permissionState = state.permissionState

        previewAreaViewModel.update(localUserState: localUserState,
                                    permissionState: permissionState)
        setupControlBarViewModel.update(localUserState: localUserState,
                                        permissionState: permissionState)
        startCallButtonViewModel.update(isDisabled: permissionState.audioPermission == .denied)
        errorInfoViewModel.update(errorState: state.errorState)
    }
}
