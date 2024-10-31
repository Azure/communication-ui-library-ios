//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import UIKit
import Combine
import SwiftUI

class CaptionsViewManager: ObservableObject {
    var isTranslationEnabled = false
    private let callingSDKWrapper: CallingSDKWrapperProtocol
    private let store: Store<AppState, Action>
    @Published var captionData = [CallCompositeCaptionsData]()
    private var subscriptions = Set<AnyCancellable>()
    private let maxCaptionsCount = 50
    private let finalizationDelay: TimeInterval = 5 // seconds

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
        isTranslationEnabled = state.captionsState.captionLanguage?.isEmpty == false
    }

    func handleNewData(_ newData: CallCompositeCaptionsData) {
        if !shouldAddCaption(newData) {
            return
        }

        self.processNewCaption(newCaption: newData)
    }

    private func processNewCaption(newCaption: CallCompositeCaptionsData) {
        guard !captionData.isEmpty else {
            captionData.append(newCaption)
            return
        }

        let lastIndex = captionData.count - 1
        var lastCaption = captionData[lastIndex]

        if lastCaption.resultType == .final {
            captionData.append(newCaption)
        } else if lastCaption.speakerRawId == newCaption.speakerRawId {
            // Update the last caption if it's not finalized and from the same speaker
            captionData[lastIndex] = newCaption
        } else {
            if shouldFinalizeLastCaption(lastCaption: lastCaption, newCaption: newCaption) {
                lastCaption.resultType = .final
                captionData[lastIndex] = lastCaption // Commit the finalization change
                captionData.append(newCaption)
            }
        }

        if captionData.count > maxCaptionsCount {
            withAnimation {
                _ = captionData.removeFirst()
            }
        }
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

    private func shouldFinalizeLastCaption(lastCaption: CallCompositeCaptionsData,
                                           newCaption: CallCompositeCaptionsData) -> Bool {
        let duration = newCaption.timestamp.timeIntervalSince(lastCaption.timestamp)
        return duration > finalizationDelay
    }
}
