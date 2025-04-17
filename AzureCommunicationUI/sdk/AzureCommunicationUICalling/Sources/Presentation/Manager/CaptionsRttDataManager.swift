//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import UIKit
import Combine
import SwiftUI

class CaptionsRttDataManager: ObservableObject {
    // MARK: - Properties

    @Published var captionsRttData = [CaptionsRttRecord]()
    @Published var isAutoCommit = false

    var isTranslationEnabled = false

    private let callingSDKWrapper: CallingSDKWrapperProtocol
    private let store: Store<AppState, Action>
    private var subscriptions = Set<AnyCancellable>()

    private let maxDataCount = 50
    private let finalizationDelay: TimeInterval = 5 // seconds
    private var hasInsertedRttInfo = false

    // MARK: - Initialization

    init(store: Store<AppState, Action>, callingSDKWrapper: CallingSDKWrapperProtocol) {
        self.callingSDKWrapper = callingSDKWrapper
        self.store = store
        subscribeToEvents()
    }

    // MARK: - Subscription Setup

    private func subscribeToEvents() {
        subscribeToCaptions()
        subscribeToRtt()
        subscribeToStore()
    }

    private func subscribeToCaptions() {
        callingSDKWrapper.callingEventsHandler.captionsReceived
            .receive(on: DispatchQueue.main)
            .sink { [weak self] captions in
                let displayData = captions.toDisplayData()
                self?.handleNewData(displayData)
            }
            .store(in: &subscriptions)
    }

    private func subscribeToRtt() {
        callingSDKWrapper.callingEventsHandler.rttReceived
            .receive(on: DispatchQueue.main)
            .sink { [weak self] rtt in
                let displayData = rtt.toDisplayData()
                self?.handleNewData(displayData)
            }
            .store(in: &subscriptions)
    }

    private func subscribeToStore() {
        store.$state
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.updateState(from: state)
            }
            .store(in: &subscriptions)
    }

    // MARK: - State Handling

    private func updateState(from state: AppState) {
        isTranslationEnabled = !(state.captionsState.captionLanguage?.isEmpty ?? true)
        let captionsEnabled = state.captionsState.isCaptionsOn

        if state.rttState.isRttOn && !hasInsertedRttInfo {
            insertRttInfoMessage()
        }

        filterCaptionsRttData(captionsEnabled: captionsEnabled)
    }

    private func filterCaptionsRttData(captionsEnabled: Bool) {
        if !captionsEnabled {
            // If captions are disabled, keep RTT and RTT info messages
            captionsRttData = captionsRttData.filter {
                $0.captionsRttType == .rtt || $0.captionsRttType == .rttInfo
            }
        }
    }

    // MARK: - Data Handling

    func handleNewData(_ newData: CaptionsRttRecord) {
        guard shouldAddData(newData) else {
            return
        }
        if newData.captionsRttType == .rtt && !store.state.rttState.isRttOn {
            store.dispatch(action: .rttAction(.turnOnRtt))
        }

        manageAutoCommit(for: newData)
        processAndStore(newData)
    }

    private func shouldAddData(_ data: CaptionsRttRecord) -> Bool {
        if data.captionsRttType == .captions {
            return shouldAddCaption(data)
        }
        return true // Always add RTT data
    }

    private func shouldAddCaption(_ data: CaptionsRttRecord) -> Bool {
        if isTranslationEnabled {
            // Add only if translation is enabled and caption text is not empty.
            return !(data.captionsText?.isEmpty ?? true)
        }

        // Additional check: skip caption if identical RTT already exists
        if data.isFinal,
            store.state.callingState.transcriptionStatus == .on,
           let lastRtt = captionsRttData.last(where: {
               $0.captionsRttType == .rtt &&
               data.displayRawId.contains($0.displayRawId) &&
               $0.isFinal
           }),
           isContentEqual(rtt: lastRtt, caption: data) {
            return false
        }
        // Add caption regardless of text if translation is not enabled.
        return true
    }

    private func isContentEqual(rtt: CaptionsRttRecord, caption: CaptionsRttRecord) -> Bool {
        return rtt.text == caption.captionsText &&
               rtt.isFinal &&
               caption.isFinal
    }

    private func manageAutoCommit(for data: CaptionsRttRecord) {
        if data.isLocal && data.captionsRttType == .rtt && data.isFinal {
            isAutoCommit = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
                self?.isAutoCommit = false
            }
        }
    }

    private func processAndStore(_ newData: CaptionsRttRecord) {
        if newData.captionsRttType == .rtt && newData.text.isEmpty {
            // Remove non-final RTT entries with the same displayRawId.
            captionsRttData.removeAll {
                $0.displayRawId == newData.displayRawId && !$0.isFinal
            }
            return
        }

        if newData.captionsRttType == .rtt && !hasInsertedRttInfo {
            insertRttInfoMessage()
        }

        if captionsRttData.isEmpty {
            captionsRttData.append(newData)
            return
        }

        // Update existing non-final entry if present.
        if let existingIndex = captionsRttData.firstIndex(where: {
            $0.displayRawId == newData.displayRawId &&
            !$0.isFinal &&
            $0.captionsRttType == newData.captionsRttType
        }) {
            captionsRttData[existingIndex] = newData
        } else {
            captionsRttData.append(newData)
        }

        // Finalize the previous message if the delay has passed.
        finalizePreviousMessageIfNeeded(with: newData)

        // Sort the data to maintain order.
        captionsRttData.sort(by: sortCaptions)

        // Enforce the maximum data count.
        enforceMaxDataCount()
    }

    private func finalizePreviousMessageIfNeeded(with newData: CaptionsRttRecord) {
        if let lastIndex = captionsRttData.lastIndex(where: {
            $0.displayRawId == newData.displayRawId &&
            $0.captionsRttType == newData.captionsRttType &&
            !$0.isFinal
        }), shouldFinalize(lastData: captionsRttData[lastIndex], newData: newData) {
            captionsRttData[lastIndex].isFinal = true
            captionsRttData = captionsRttData // Trigger a refresh by reassigning
        }
    }

    private func shouldFinalize(lastData: CaptionsRttRecord,
                                newData: CaptionsRttRecord) -> Bool {
        let duration = newData.createdTimestamp.timeIntervalSince(lastData.createdTimestamp)
        return duration > finalizationDelay
    }

    private func sortCaptions(_ first: CaptionsRttRecord,
                              _ second: CaptionsRttRecord) -> Bool {
        // Rule 0: RTT Info messages should always be before RTT messages
        if first.captionsRttType == .rttInfo {
            return true  // Always keep RTT Info at the top
        }
        if second.captionsRttType == .rttInfo {
            return false // Ensure RTT Info is above RTT messages
        }
        // Rule 1: Local non-final messages always at the bottom.
        if first.isLocal && !first.isFinal {
            return false // `first` stays below `second`.
        }
        if second.isLocal && !second.isFinal {
            return true // `second` stays below `first`.
        }

        // Rule 2: Non-final RTT messages below finalized RTT messages.
        if first.captionsRttType == .rtt
            && !first.isFinal
            && second.captionsRttType == .rtt
            && second.isFinal {
            return false
        }
        if second.captionsRttType == .rtt
            && !second.isFinal
            && first.captionsRttType == .rtt
            && first.isFinal {
            return true
        }

        // Rule 3: For finalized RTT messages, use updatedTimestamp for sorting.
        if first.captionsRttType == .rtt && first.isFinal || second.captionsRttType == .rtt && second.isFinal {
            return first.updatedTimestamp < second.updatedTimestamp
        }

        // Default sorting based on updatedTimestamp.
        return first.createdTimestamp < second.createdTimestamp
    }

    // MARK: - RTT Info Message

    private func insertRttInfoMessage() {
        let rttInfo = CaptionsRttRecord(
            displayRawId: UUID().uuidString, // Unique ID
            displayName: "",
            text: "",
            spokenText: "",
            captionsText: "",
            spokenLanguage: "",
            captionsLanguage: "",
            captionsRttType: .rttInfo,
            createdTimestamp: Date(),
            updatedTimestamp: Date(),
            isFinal: true,
            isLocal: false
        )
        DispatchQueue.main.async {
            // Find the first RTT message index
            if let firstRttIndex = self.captionsRttData.firstIndex(where: { $0.captionsRttType == .rtt }) {
                self.captionsRttData.insert(rttInfo, at: firstRttIndex) // Insert before the first RTT
            } else {
                self.captionsRttData.append(rttInfo) // If no RTT, append at the end
            }
        }
        hasInsertedRttInfo = true
    }

    // MARK: - Data Management

    private func enforceMaxDataCount() {
        if captionsRttData.count > maxDataCount {
            withAnimation {
                captionsRttData.removeFirst(captionsRttData.count - maxDataCount)
            }
        }
    }
}
