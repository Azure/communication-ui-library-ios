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
                self?.handleNewData(newData.toDisplayData())
            }
            .store(in: &subscriptions)

        callingSDKWrapper.callingEventsHandler.rttReceived
            .receive(on: DispatchQueue.main)
            .sink { [weak self] newData in
                self?.handleNewData(newData.toDisplayData())
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

    private func handleNewData(_ newData: CallCompositeRttCaptionsDisplayData) {
        if newData.captionsRttType == .captions && !shouldAddCaption(newData) {
            return
        }

        if newData.captionsRttType == .rtt && !store.state.rttState.isRttOn {
            store.dispatch(action: .rttAction(.turnOnRtt))
        }

        processData(newData)
    }

    // Decide if a new caption should be added to the list
    private func shouldAddCaption(_ displayData: CallCompositeRttCaptionsDisplayData) -> Bool {
        if isTranslationEnabled {
            // Only add caption if translation is enabled and caption text is not empty
            return !(displayData.captionsText?.isEmpty ?? true)
        }
        // Always add caption if translation is not enabled
        return true
    }

    private func processData(_ newData: CallCompositeRttCaptionsDisplayData) {

        if newData.captionsRttType == .rtt && newData.text.isEmpty {
            // Remove the entry if it already exists in `captionsRttData`
            captionsRttData.removeAll { $0.displayRawId == newData.displayRawId && !$0.isFinal }
            return
        }

        // Check if there is no data yet
        if captionsRttData.isEmpty {
            captionsRttData.append(newData)
            return
        }

        // Find an existing non-final entry with the same sender ID and type
        if let existingIndex = captionsRttData.firstIndex(where: {
            $0.displayRawId == newData.displayRawId &&
            !$0.isFinal &&
            $0.captionsRttType == newData.captionsRttType
        }) {
            // Update the non-final entry
            captionsRttData[existingIndex] = newData
        } else {
            // If no matching partial entry exists, append the new message
            captionsRttData.append(newData)
        }

        // Finalize the previous message if needed
        if let lastIndex = captionsRttData.lastIndex(where: {
            $0.displayRawId == newData.displayRawId &&
            $0.captionsRttType == newData.captionsRttType &&
            !$0.isFinal
        }), shouldFinalize(lastData: captionsRttData[lastIndex], newData: newData) {
            captionsRttData[lastIndex].isFinal = true
        }

        // Sort the data to ensure non-final local messages are always at the bottom
        captionsRttData.sort(by: sortCaptions)

        // Limit the total count of messages to `maxDataCount`
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

    private func sortCaptions(
        _ first: CallCompositeRttCaptionsDisplayData,
        _ second: CallCompositeRttCaptionsDisplayData
    ) -> Bool {
        // Rule 1: Local non-final messages always at the bottom
        if first.isLocal && !first.isFinal {
            return false // Keep `first` below `second`
        }
        if second.isLocal && !second.isFinal {
            return true // Keep `second` below `first`
        }

        // Rule 2: Non-final messages should appear below finalized messages
        if !first.isFinal && second.isFinal {
            return false // Keep `first` below `second`
        }
        if first.isFinal && !second.isFinal {
            return true // Keep `second` below `first`
        }

        // Rule 3: For other cases, preserve the insertion order
        return first.timestamp < second.timestamp
    }

}
