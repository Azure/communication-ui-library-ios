//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import UIKit
import Combine
import SwiftUI

class CaptionsAndRttViewManager: ObservableObject {
    var isTranslationEnabled = false
    private let callingSDKWrapper: CallingSDKWrapperProtocol
    private let store: Store<AppState, Action>
    @Published var captionsRttData = [CallCompositeRttCaptionsDisplayData]()
    private var subscriptions = Set<AnyCancellable>()
    private let maxDataCount = 50
    private let finalizationDelay: TimeInterval = 5 // seconds

    init(store: Store<AppState, Action>, callingSDKWrapper: CallingSDKWrapperProtocol) {
        self.callingSDKWrapper = callingSDKWrapper
        self.store = store
        subscribeToCaptionsAndRtt()
    }

    private func subscribeToCaptionsAndRtt() {
        callingSDKWrapper.callingEventsHandler.captionsReceived
            .receive(on: DispatchQueue.main)
            .sink { [weak self] newData in
                self?.handleNewData(newData.toDisplayData(), isCaption: true)
            }
            .store(in: &subscriptions)

        callingSDKWrapper.callingEventsHandler.rttReceived
            .receive(on: DispatchQueue.main)
            .sink { [weak self] newData in
                self?.handleNewData(newData.toDisplayData(), isCaption: false)
            }
            .store(in: &subscriptions)

        store.$state
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.receive(state: state)
            }
            .store(in: &subscriptions)
    }

    private func receive(state: AppState) {
        isTranslationEnabled = state.captionsState.captionLanguage?.isEmpty == false
        let captionsEnabled = state.captionsState.isCaptionsOn
        let rttEnabled = state.rttState.isRttOn

        switch (captionsEnabled, rttEnabled) {
        case (true, true):
            // Both captions and RTT are enabled, no need to clear data
            break
        case (true, false):
            // Only captions are enabled, filter out RTT data
            captionsRttData = captionsRttData.filter { $0.captionsRttType == .captions }
        case (false, true):
            // Only RTT is enabled, filter out captions data
            captionsRttData = captionsRttData.filter { $0.captionsRttType == .rtt }
        case (false, false):
            // Neither is enabled, clear all data
            captionsRttData = []
        }
    }

    private func handleNewData(_ newData: CallCompositeRttCaptionsDisplayData, isCaption: Bool) {
        if isCaption && !shouldAddCaption(newData) {
            return
        }

        processData(newData, isCaption: isCaption)
    }

    // Decide if a new caption should be added to the list
    private func shouldAddCaption(_ caption: CallCompositeRttCaptionsDisplayData) -> Bool {
        if isTranslationEnabled {
            // Only add caption if translation is enabled and caption text is not empty
            return !(caption.captionsText?.isEmpty ?? true)
        }
        // Always add caption if translation is not enabled
        return true
    }

    private func processData(_ newData: CallCompositeRttCaptionsDisplayData, isCaption: Bool) {
        if captionsRttData.isEmpty {
            captionsRttData.append(newData)
            return
        }

        let lastIndex = captionsRttData.count - 1
        var lastData = captionsRttData[lastIndex]

        if lastData.isFinal {
            captionsRttData.append(newData)
        } else if lastData.displayRawId == newData.displayRawId && lastData.captionsRttType == .captions {
            // Update the last entry if it's from the same sender and of the same type (caption/RTT)
            captionsRttData[lastIndex] = newData
        } else {
            if shouldFinalize(lastData: lastData, newData: newData) {
                lastData.isFinal = true
                captionsRttData[lastIndex] = lastData // Commit the finalization change
                captionsRttData.append(newData)
            }
        }

        if captionsRttData.count > maxDataCount {
            withAnimation {
                _ = captionsRttData.removeFirst()
            }
        }
    }

    private func shouldFinalize(lastData: CallCompositeRttCaptionsDisplayData,
                                newData: CallCompositeRttCaptionsDisplayData) -> Bool {
        let duration = newData.timestamp.timeIntervalSince(lastData.timestamp)
        return duration > finalizationDelay
    }
}
