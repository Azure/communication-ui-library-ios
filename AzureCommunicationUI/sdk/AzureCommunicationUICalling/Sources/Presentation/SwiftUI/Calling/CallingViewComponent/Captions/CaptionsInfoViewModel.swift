//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Combine
import Foundation

class CaptionsInfoViewModel: ObservableObject {
    @Published var captionsData = [CallCompositeCaptionsData]()
    @Published var isDisplayed = false
    private var captionsManager: CaptionsViewManager

    init(state: AppState, captionsManager: CaptionsViewManager) {
        self.captionsManager = captionsManager
        bindCaptionsUpdates()
    }

    private func bindCaptionsUpdates() {
        captionsManager.$captionData
            .receive(on: DispatchQueue.main)
            .assign(to: &$captionsData)
    }

    func update(state: AppState) {
        self.isDisplayed = state.captionsState.isStarted
    }
}
