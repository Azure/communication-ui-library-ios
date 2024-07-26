//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import Combine

internal protocol AccessibilityAnnouncementManagerProtocol {}

// Interface for Hooks to Implement (A hook is a single use-case of Accessibility Announcement
internal protocol AccessibilityAnnouncementHookProtocol {
    func shouldAnnounce(oldState: AppState,
                        newState: AppState) -> Bool
    func announcement(oldState: AppState,
                      newState: AppState,
                      localizationProvider: LocalizationProviderProtocol) -> String
}

/* Handles watching state and making relevant announcements*/
internal class AccessibilityAnnouncementManager: AccessibilityAnnouncementManagerProtocol {
    private let store: Store<AppState, Action>
    private let accessibilityProvider: AccessibilityProviderProtocol
    private let localizationProvider: LocalizationProviderProtocol
    private var lastState: AppState
    private let hooks = [ParticipantsChangedHook()]

    var cancellables = Set<AnyCancellable>()

    init(store: Store<AppState, Action>,
         accessibilityProvider: AccessibilityProviderProtocol,
         localizationProvider: LocalizationProviderProtocol) {
        self.store = store
        self.lastState = store.state
        self.accessibilityProvider = accessibilityProvider
        self.localizationProvider = localizationProvider

        store.$state
            .receive(on: RunLoop.main)
            .sink { [weak self] state in
                self?.receive(state)
            }.store(in: &cancellables)
    }

    private func receive(_ state: AppState) {
        for hook in hooks where hook.shouldAnnounce(oldState: lastState, newState: state) {
            accessibilityProvider.postQueuedAnnouncement(hook.announcement(
                oldState: lastState,
                newState: state,
                localizationProvider: localizationProvider))
        }
        lastState = state
    }
}
