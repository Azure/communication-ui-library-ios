//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Combine
import Foundation

class LoadingOverlayViewModel: OverlayViewModelProtocol {
    private let localizationProvider: LocalizationProviderProtocol
    private let accessibilityProvider: AccessibilityProviderProtocol
    private let store: Store<AppState, Action>
    private var callingStatus: CallingStatus = .none
    private var operationStatus: OperationStatus = .skipSetupRequested
    private var audioPermission: AppPermission.Status = .unknown
    var cancellables = Set<AnyCancellable>()
    var networkManager: NetworkManager

    init(localizationProvider: LocalizationProviderProtocol,
         accessibilityProvider: AccessibilityProviderProtocol,
         networkManager: NetworkManager,
         store: Store<AppState, Action>
    ) {
        self.localizationProvider = localizationProvider
        self.accessibilityProvider = accessibilityProvider
        self.networkManager = networkManager
        self.networkManager.startMonitor()
        self.store = store
        self.audioPermission = store.state.permissionState.audioPermission
        store.$state
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.receive(state)
            }.store(in: &cancellables)
    }

    deinit {
        networkManager.stopMonitor()
    }

    var title: String {
        return localizationProvider.getLocalizedString(.joiningCall)
    }

    var subtitle: String = ""

    @Published var isDisplayed: Bool = false

    func receive(_ state: AppState) {
        let permissionState = state.permissionState
        let callingState = state.callingState
        callingStatus = callingState.status
        operationStatus = callingState.operationStatus
        let shouldDisplay = operationStatus == .skipSetupRequested && callingStatus != .connected &&
        callingState.status != .inLobby

        if shouldDisplay != isDisplayed {
            isDisplayed = shouldDisplay
            accessibilityProvider.moveFocusToFirstElement()
        }

        if isDisplayed && permissionState.audioPermission == .denied {
            store.dispatch(action: .errorAction(.fatalErrorUpdated(
                internalError: .callJoinFailedByMicPermission, error: nil)))
        }
    }
    func setupAudioPermissions() {
        if audioPermission == .notAsked {
            store.dispatch(action: .permissionAction(.audioPermissionRequested))
        }
    }
    func handleOffline() {
        guard networkManager.isOnline() else {
            if operationStatus == .skipSetupRequested {
                store.dispatch(action: .errorAction(
                    .fatalErrorUpdated(internalError: .networkConnectionNotAvailable, error: nil)))
            }
            return
        }
    }
}
