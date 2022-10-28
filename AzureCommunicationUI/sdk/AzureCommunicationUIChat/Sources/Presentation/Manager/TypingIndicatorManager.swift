//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Combine
import Foundation

protocol TypingParticipantsManagerProtocol {}

class TypingParticipantsManager: TypingParticipantsManagerProtocol {
    private let store: Store<AppState>
    private var timer: Timer?
    private var cancellables = Set<AnyCancellable>()

    // made it internal and var for unit tests
    enum Constants {
        static var timeout: Int = 8
        // margin of error
        static var checkInterval: Double = 1.0
    }

    init(store: Store<AppState>) {
        self.store = store
        store.$state
            .receive(on: RunLoop.main)
            .sink { [weak self] state in
                self?.receive(state)
            }.store(in: &cancellables)
    }

    private func receive(_ state: AppState) {
        clearIndicators(for: state.participantsState.typingParticipants)
    }

    private func clearIndicators(for participants: [UserEventTimestampModel]) {
        timer?.invalidate()
        guard !participants.isEmpty else {
            return
        }
        self.timer =
        Timer.scheduledTimer(withTimeInterval: Constants.checkInterval, repeats: true, block: { _ in
            // filteredParticiapants is the list of participants that are within 8 seconds removal timeout
            let filteredParticiapants = participants.filter {
                let timestamp = $0.timestamp.value
                let differenceInSeconds = Int(Date().timeIntervalSince(timestamp))
                return differenceInSeconds < Constants.timeout
            }
            DispatchQueue.main.async {
                self.store.dispatch(action: .participantsAction(
                    .setTypingIndicator(participant: filteredParticiapants)))
            }
        })
    }
}
