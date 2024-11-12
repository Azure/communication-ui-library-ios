//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Combine
import Foundation

class RttInfoViewModel: ObservableObject {
    @Published var captionsData = [CallCompositeCaptionsData]()
    @Published var isDisplayed = false
    var loadingMessage = ""
    private var captionsManager: CaptionsViewManager
    private let localizationProvider: LocalizationProviderProtocol

    init(state: AppState,
         captionsManager: CaptionsViewManager,
         localizationProvider: LocalizationProviderProtocol) {
        self.captionsManager = captionsManager
        self.localizationProvider = localizationProvider
        loadingMessage = localizationProvider.getLocalizedString(LocalizationKey.captionsStartingCaptions)
        bindCaptionsUpdates()
    }

    private func bindCaptionsUpdates() {
        captionsManager.$captionData
            .receive(on: DispatchQueue.main)
            .assign(to: &$captionsData)
    }

    func update(state: AppState) {
        self.isDisplayed = state.rttState.isRttOn
    }
}
