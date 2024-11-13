//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Combine
import Foundation

class CaptionsInfoViewModel: ObservableObject {
    @Published var captionsData = [CallCompositeCaptionsData]()
    @Published var isDisplayed = false
    @Published var isRttDisplayed = false
    @Published var isLoading = false
    @Published var items: [BaseDrawerItemViewModel] = []
    var loadingMessage = ""
    private var captionsManager: CaptionsViewManager
    private let localizationProvider: LocalizationProviderProtocol
    private let dispatch: ActionDispatch

    init(state: AppState,
         captionsManager: CaptionsViewManager,
         dispatch: @escaping ActionDispatch,
         localizationProvider: LocalizationProviderProtocol) {
        self.captionsManager = captionsManager
        self.localizationProvider = localizationProvider
        loadingMessage = localizationProvider.getLocalizedString(LocalizationKey.captionsStartingCaptions)
        self.dispatch = dispatch
        bindCaptionsUpdates()
        setupItems(state: state)
    }

    private func bindCaptionsUpdates() {
        captionsManager.$captionData
            .receive(on: DispatchQueue.main)
            .assign(to: &$captionsData)
    }

    private func setupItems(state: AppState) {
        items.removeAll()
        let buttonViewDataState = state.buttonViewDataState
        let titleInfoModel = TitleDrawerListItemViewModel(
            title: localizationProvider.getLocalizedString(.captionsListTitile),
            endIcon: .rtt,
            expandIcon: .maximize,
            accessibilityIdentifier: ""
        )
        items.append(titleInfoModel)
    }

    func update(state: AppState) {
        self.isDisplayed = state.captionsState.isCaptionsOn && state.captionsState.errors != .captionsFailedToStart
        self.isLoading = isDisplayed && !state.captionsState.isStarted
        self.isRttDisplayed = state.rttState.isRttOn
    }
}
