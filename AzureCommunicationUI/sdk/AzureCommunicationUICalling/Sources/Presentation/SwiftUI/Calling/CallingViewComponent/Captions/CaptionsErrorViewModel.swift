//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

final class CaptionsErrorViewModel: ObservableObject, Identifiable {
    // The time a bottom toast should be presented for before
    // automatically being dismissed.
    private static let bottomToastBannerDismissInterval: TimeInterval = 4.0

    @Published private(set) var visible = false
    @Published private(set) var text: String = ""
    @Published private(set) var icon: CompositeIcon?

    private let dispatch: ActionDispatch
    private let logger: Logger
    private var bottomToastDismissTimer: Timer!
    private let localizationProvider: LocalizationProviderProtocol
    private let accessibilityProvider: AccessibilityProviderProtocol

    init(compositeViewModelFactory: CompositeViewModelFactoryProtocol,
         logger: Logger,
         localizationProvider: LocalizationProviderProtocol,
         accessibilityProvider: AccessibilityProviderProtocol,
         dispatchAction: @escaping ActionDispatch) {
        self.logger = logger
        self.localizationProvider = localizationProvider
        self.accessibilityProvider = accessibilityProvider
        self.dispatch = dispatchAction
    }

    func update(captionsState: CaptionsState, callingState: CallingState) {
        if callingState.status != .connected || captionsState.errors == .none {
            return
        }
        switch captionsState.errors {
        case .captionsFailedToStart:
            displayNotification(localizationKey: .captionsStartCaptionsError,
                                icon: .captionsError,
                                isPersistent: false)
        case .captionsFailedToStop:
            displayNotification(localizationKey: .captionsStopCaptionsError,
                                icon: .captionsError,
                                isPersistent: true)
        case .captionsFailedToSetSpokenLanguage:
            displayNotification(localizationKey: .captionsChangeSpokenLanguageError,
                                icon: .captionsError,
                                isPersistent: false)
        case .captionsFailedToSetCaptionLanguage:
            displayNotification(localizationKey: .captionsChangeCaptionsLanguageError,
                                icon: .captionsError,
                                isPersistent: false)
        case .none:
            self.visible = false
            return
        }
    }

    private func displayNotification(localizationKey: LocalizationKey,
                                     icon: CompositeIcon,
                                     isPersistent: Bool) {

        if !isPersistent {
            bottomToastDismissTimer =
                Timer.scheduledTimer(withTimeInterval: CaptionsErrorViewModel.bottomToastBannerDismissInterval,
                                     repeats: false) { [weak self] _ in
                    self?.dismiss()
                    self?.dispatch(.captionsAction(CaptionsAction.error(errors: .none)))
                }
        } else {
            invalidateTimer()
        }
        self.visible = true
        self.text = localizationProvider.getLocalizedString(localizationKey)
        self.icon = icon

        // Announce accessibility text when toast appear.
        accessibilityProvider.postQueuedAnnouncement(text)
    }

    private func dismiss() {
        visible = false
        invalidateTimer()
    }

    private func invalidateTimer() {
        bottomToastDismissTimer?.invalidate()
        bottomToastDismissTimer = nil
    }
}
