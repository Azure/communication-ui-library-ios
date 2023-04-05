//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Combine
import Foundation

class SetupViewModel: ObservableObject {
    private let logger: Logger
    private let store: Store<AppState, Action>
    private let localizationProvider: LocalizationProviderProtocol

    private var callingStatus: CallingStatus = .none

    let isRightToLeft: Bool
    let previewAreaViewModel: PreviewAreaViewModel
    var title: String
    var subTitle: String?

    var networkManager: NetworkManager
    var errorInfoViewModel: ErrorInfoViewModel
    var dismissButtonViewModel: IconButtonViewModel!
    var joinCallButtonViewModel: PrimaryButtonViewModel!
    var setupControlBarViewModel: SetupControlBarViewModel!
    var joiningCallActivityViewModel: JoiningCallActivityViewModel!
    var cancellables = Set<AnyCancellable>()

    @Published var isJoinRequested: Bool = false

    init(compositeViewModelFactory: CompositeViewModelFactoryProtocol,
         logger: Logger,
         store: Store<AppState, Action>,
         networkManager: NetworkManager,
         localizationProvider: LocalizationProviderProtocol,
         setupScreenViewData: SetupScreenViewData? = nil) {
        self.store = store
        self.networkManager = networkManager
        self.networkManager.startMonitor()
        self.localizationProvider = localizationProvider
        self.isRightToLeft = localizationProvider.isRightToLeft
        self.logger = logger

        if let title = setupScreenViewData?.title, !title.isEmpty {
            // if title is not nil/empty, use given title and optional subtitle
            self.title = title
            self.subTitle = setupScreenViewData?.subtitle
        } else {
            // else if title is nil/empty, use default title
            self.title = self.localizationProvider.getLocalizedString(.setupTitle)
            self.subTitle = nil
        }

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

    deinit {
        networkManager.stopMonitor()
    }

    func setupAudioPermissions() {
        if store.state.permissionState.audioPermission == .notAsked {
            store.dispatch(action: .permissionAction(.audioPermissionRequested))
        }
    }

    func dismissSetupScreen() {
        if store.state.callingState.operationStatus == .skipSetupRequested {
            store.dispatch(action: .callingAction(.dismissSetup))
        }
    }
    func setupCall() {
        store.dispatch(action: .callingAction(.setupCall))
    }

    func joinCallButtonTapped() {
        guard networkManager.isOnline() else {
            handleOffline()
            return
        }
        isJoinRequested = true
        store.dispatch(action: .callingAction(.callStartRequested))
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
        let defaultUserState = state.defaultUserState
        previewAreaViewModel.update(localUserState: localUserState,
                                    permissionState: permissionState)
        setupControlBarViewModel.update(localUserState: localUserState,
                                        permissionState: permissionState,
                                        callingState: callingState,
                                        defaultUserState: defaultUserState)
        joinCallButtonViewModel.update(isDisabled: permissionState.audioPermission == .denied)
        errorInfoViewModel.update(errorState: state.errorState)
    }

    func shouldShowSetupControlBarView() -> Bool {
        let cameraStatus = store.state.localUserState.cameraState.operation
        return cameraStatus == .off || !isJoinRequested
    }

    private func handleOffline() {
        store.dispatch(action: .errorAction(.statusErrorAndCallReset(internalError: .connectionFailed,
                                                                     error: nil)))
        // only show banner again when user taps on button explicitly
        // banner would not reappear when other events^1 send identical error state again
        // 1: camera on/off, audio on/off, switch to background/foreground, etc.
        errorInfoViewModel.show()
    }
}
