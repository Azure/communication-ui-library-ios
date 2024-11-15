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
    @Published var rttData = [CallCompositeRttData]()
    @Published var captionsRttData = [CallCompositeRttCaptionsDisplayData]()
    private var subscriptions = Set<AnyCancellable>()
    private let maxCaptionsCount = 50
    private let maxRttCount = 50
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
                self?.handleNewCaptionsData(newData)
            }
            .store(in: &subscriptions)
        callingSDKWrapper.callingEventsHandler.rttReceived
            .receive(on: DispatchQueue.main)
            .sink { [weak self] newData in
                self?.handleNewRttData(newData)
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
        let captionsEnabled = state.captionsState.isCaptionsOn
        let rttEnabled = state.rttState.isRttOn

        switch (captionsEnabled, rttEnabled) {
        case (true, true):
            // Merge both captions and RTT data
            mapAndCombineData()
        case (true, false):
            // Handle captions only
            rttData = []
            captionsRttData = captionData.map { $0.toDisplayData() }
        case (false, true):
            // Handle RTT only
            captionData = []
            captionsRttData = rttData.map { $0.toDisplayData() }
        case (false, false):
            // Clear combined data if neither is enabled
            captionsRttData = []
        }
    }

    func handleNewCaptionsData(_ newData: CallCompositeCaptionsData) {
        if !shouldAddCaption(newData) {
            return
        }

        self.processNewCaption(newCaption: newData)
    }

    func handleNewRttData(_ newData: CallCompositeRttData) {
        self.processNewRtt(newRtt: newData)
    }

    private func processNewRtt(newRtt: CallCompositeRttData) {
        guard !rttData.isEmpty else {
            rttData.append(newRtt)
            mapAndCombineData()
            return
        }

        let lastIndex = rttData.count - 1
        var lastRtt = rttData[lastIndex]

        if lastRtt.resultType == .final {
            rttData.append(newRtt)
        } else if lastRtt.senderRawId == newRtt.senderRawId {
            // Update the last RTT entry if it's from the same speaker and not finalized
            rttData[lastIndex] = newRtt
        } else {
            if shouldFinalizeLastRtt(lastRtt: lastRtt, newRtt: newRtt) {
                lastRtt.resultType = .final
                rttData[lastIndex] = lastRtt
                rttData.append(newRtt)
            }
        }

        // Keep RTT data within the max limit
        if rttData.count > maxRttCount {
            withAnimation {
                _ = rttData.removeFirst()
            }
        }

        mapAndCombineData()
    }

    private func shouldFinalizeLastRtt(lastRtt: CallCompositeRttData,
                                       newRtt: CallCompositeRttData) -> Bool {
        let duration = newRtt.localUpdatedTime.timeIntervalSince(lastRtt.localUpdatedTime)
        return duration > finalizationDelay
    }

    private func processNewCaption(newCaption: CallCompositeCaptionsData) {
        guard !captionData.isEmpty else {
            captionData.append(newCaption)
            mapAndCombineData()
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
        mapAndCombineData()
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

    private func mapAndCombineData() {
        // Map captions to the common display type
        let captionsDisplayData = captionData.map { $0.toDisplayData() }

        // Map RTT data to the common display type
        let rttDisplayData = rttData.map { $0.toDisplayData() }

        // Combine both arrays
        var combinedData = captionsDisplayData + rttDisplayData

        // Sort by timestamp (assuming RTT and captions are mapped with different timestamps)
        combinedData.sort { lhs, rhs in
            let lhsTimestamp = timestamp(for: lhs)
            let rhsTimestamp = timestamp(for: rhs)
            return lhsTimestamp < rhsTimestamp
        }

        // Update the combined property
        captionsRttData = combinedData
    }

    // Helper method to get the timestamp for sorting
    private func timestamp(for data: CallCompositeRttCaptionsDisplayData) -> Date {
        if let caption = captionData.first(where: { $0.toDisplayData() == data }) {
            return caption.timestamp
        } else if let rtt = rttData.first(where: { $0.toDisplayData() == data }) {
            return rtt.localCreatedTime
        }
        return Date.distantPast // Fallback
    }

}
