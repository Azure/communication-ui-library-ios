//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import UIKit
import Combine

class CaptionsViewManager: ObservableObject {
    private let callingSDKWrapper: CallingSDKWrapperProtocol
    private let store: Store<AppState, Action>
    @Published var captionData = [CallCompositeCaptionsData]()
    private var subscriptions = Set<AnyCancellable>()
    private var isTranslationEnabled = false

    init(store: Store<AppState, Action>, callingSDKWrapper: CallingSDKWrapperProtocol) {
        self.callingSDKWrapper = callingSDKWrapper
        self.store = store
        subscribeToCaptions()
    }

    private func subscribeToCaptions() {
        callingSDKWrapper.callingEventsHandler.captionsReceived
            .receive(on: DispatchQueue.main)
            .sink { [weak self] newData in
                self?.handleNewData(newData)
            }
            .store(in: &subscriptions)
        store.$state
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.receive(state: state)
            }.store(in: &subscriptions)
    }

    private func receive(state: AppState) {
        isTranslationEnabled = !(state.captionsState.activeCaptionLanguage?.isEmpty ?? false)
    }

    private func handleNewData(_ newData: CallCompositeCaptionsData) {
        if !shouldAddCaption(newData) {
            return
        }

        DispatchQueue.main.async {
            if let lastNotFinishedMessageFromThisUserIndex = self.captionData.lastIndex(where: { data in
                data.speakerRawId == newData.speakerRawId && data.resultType == .partial
            }) {
                self.captionData[lastNotFinishedMessageFromThisUserIndex] = newData
            } else {
                self.captionData.append(newData)
            }
        }
    }

    func clearCaptions() {
        captionData.removeAll()
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
