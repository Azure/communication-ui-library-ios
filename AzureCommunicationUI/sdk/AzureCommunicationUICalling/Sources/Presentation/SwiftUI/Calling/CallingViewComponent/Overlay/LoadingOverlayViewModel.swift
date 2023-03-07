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
    private var operationStatus: OperationStatus = .bypassRequested
    private var audioPermission: AppPermission.Status = .unknown
    var cancellables = Set<AnyCancellable>()

    init(compositeViewModelFactory: CompositeViewModelFactoryProtocol,
         localizationProvider: LocalizationProviderProtocol,
         accessibilityProvider: AccessibilityProviderProtocol,
         store: Store<AppState, Action>
    ) {
        self.localizationProvider = localizationProvider
        self.accessibilityProvider = accessibilityProvider
        self.store = store
        self.audioPermission = store.state.permissionState.audioPermission
        store.$state
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.receive(state)
            }.store(in: &cancellables)
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
        let shouldDisplay = operationStatus == .bypassRequested && callingStatus != .connected

        if shouldDisplay != isDisplayed {
            isDisplayed = shouldDisplay
            accessibilityProvider.moveFocusToFirstElement()
        }

        if isDisplayed && permissionState.audioPermission == .denied {
            store.dispatch(action: .callingAction(.callEndRequested))
        }
    }
    func setupAudioPermissions() {
        if audioPermission == .notAsked || audioPermission == .denied {
            store.dispatch(action: .permissionAction(.audioPermissionRequested))
        }
    }
}
