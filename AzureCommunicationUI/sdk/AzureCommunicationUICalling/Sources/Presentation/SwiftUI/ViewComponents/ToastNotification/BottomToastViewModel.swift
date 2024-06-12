//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

final class BottomToastViewModel: ObservableObject, Identifiable {
    // The time a bottom toast should be presented for before
    // automatically being dismissed.
    private static let bottomToastBannerDismissInterval: TimeInterval = 4.0

    @Published private(set) var visible = false
    @Published private(set) var text: String = ""
    @Published private(set) var icon: CompositeIcon?

    private let dispatch: ActionDispatch
    private var bottomToastDismissTimer: Timer!
    private let localizationProvider: LocalizationProviderProtocol
    private let accessibilityProvider: AccessibilityProviderProtocol

    init(dispatchAction: @escaping ActionDispatch,
         localizationProvider: LocalizationProviderProtocol,
         accessibilityProvider: AccessibilityProviderProtocol,
         toastNotificationState: ToastNotificationState) {
        self.dispatch = dispatchAction
        self.localizationProvider = localizationProvider
        self.accessibilityProvider = accessibilityProvider

        update(toastNotificationState: toastNotificationState)
    }

    func update(toastNotificationState: ToastNotificationState) {
        guard let state = toastNotificationState.status else {
            dismiss()
            return
        }

        switch state {
        case .networkReceiveQuality, .networkSendQuality:
            displayNotification(localizationKey: .callDiagnosticsNetworkQualityLow,
                                icon: .wifiWarning,
                                isPersistent: false)
        case .networkReconnectionQuality:
            displayNotification(localizationKey: .callDiagnosticsNetworkReconnect,
                                icon: .wifiWarning,
                                isPersistent: true)
        case .networkUnavailable, .networkRelaysUnreachable:
            displayNotification(localizationKey: .callDiagnosticsNetworkLost,
                                icon: .wifiWarning,
                                isPersistent: false)
        case .speakingWhileMicrophoneIsMuted:
            displayNotification(localizationKey: .callDiagnosticsUserMuted,
                                icon: .micOff,
                                isPersistent: false)
        case .cameraStartFailed, .cameraStartTimedOut:
            displayNotification(localizationKey: .callDiagnosticsCameraNotWorking,
                                icon: .videoOffRegular,
                                isPersistent: false)
        case .someFeaturesLost:
            displayNotification(localizationKey: .callingViewToastFeaturesLost,
                                icon: .warning,
                                isPersistent: false)
        case .someFeaturesGained:
            displayNotification(localizationKey: .callingViewToastFeaturesGained,
                                icon: .warning,
                                isPersistent: false)
        }
    }

    private func displayNotification(localizationKey: LocalizationKey,
                                     icon: CompositeIcon,
                                     isPersistent: Bool) {

        if !isPersistent {
            bottomToastDismissTimer =
                Timer.scheduledTimer(withTimeInterval: BottomToastViewModel.bottomToastBannerDismissInterval,
                                     repeats: false) { [weak self] _ in
                    self?.dismiss()
                    self?.dispatch(.toastNotificationAction(.dismissNotification))
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
