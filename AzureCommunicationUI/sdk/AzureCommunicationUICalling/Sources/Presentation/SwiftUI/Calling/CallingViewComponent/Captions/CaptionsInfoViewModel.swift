//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Combine
import Foundation

class CaptionsInfoViewModel: ObservableObject {
    @Published var captionsData = [CallCompositeCaptionsData]()
    @Published var isDisplayed = false
    private var isTranslationEnabled = false
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

    private func handleNewCaption(_ newCaption: CallCompositeCaptionsData) {
        guard shouldAddCaption(newCaption) else {
              return
        }

        // Check if the new caption updates an existing caption
        if let lastCaption = captionsData.last,
           lastCaption.speakerRawId == newCaption.speakerRawId,
           lastCaption.resultType != .final {
            // Update the last caption if it's from the same speaker and not finalized
            captionsData[captionsData.count - 1] = newCaption
        } else {
            // Add new caption otherwise
            captionsData.append(newCaption)
        }

        if captionsData.count > 50 {
            captionsData.removeFirst(captionsData.count - 50)
        }
    }

    func update(state: AppState) {
        self.isDisplayed = state.captionsState.isStarted
        self.isTranslationEnabled = state.captionsState.activeCaptionLanguage != nil
    }

    // Decide if a new caption should be added to the list
    private func shouldAddCaption(_ caption: CallCompositeCaptionsData) -> Bool {
        if isTranslationEnabled {
            // Only add caption if translation is enabled and caption text is not empty
            return !(caption.captionText?.isEmpty ?? true)
        }
        // Always add caption if translation is not enabled
        return true
    }
}
