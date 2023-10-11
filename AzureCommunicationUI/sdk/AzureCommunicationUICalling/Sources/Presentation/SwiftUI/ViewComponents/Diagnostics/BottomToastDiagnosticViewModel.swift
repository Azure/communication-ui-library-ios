//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Combine
import Foundation

final class BottomToastDiagnosticViewModel: ObservableObject, Identifiable {
    // The time a bottom toast diagnostic should be presented for before
    // automatically beging dismissed.
    static let bottomToastBannerDismissInterval: TimeInterval = 4.0

    @Published private(set) var text: String = ""
    @Published private(set) var icon: CompositeIcon?

    private let localizationProvider: LocalizationProviderProtocol

    private(set) var networkDiagnostic: NetworkCallDiagnostic?
    private(set) var networkQualityDiagnostic: NetworkQualityCallDiagnostic?
    private(set) var mediaDiagnostic: MediaCallDiagnostic?

    static let handledMediaDiagnostics: [MediaCallDiagnostic] = [
        .speakingWhileMicrophoneIsMuted,
        .cameraStartFailed,
        .cameraStartTimedOut
    ]

    init(localizationProvider: LocalizationProviderProtocol,
         mediaDiagnostic: MediaCallDiagnostic) {
        self.localizationProvider = localizationProvider
        self.mediaDiagnostic = mediaDiagnostic
        self.updateTextAndIcon()
    }

    init(localizationProvider: LocalizationProviderProtocol,
         networkDiagnostic: NetworkCallDiagnostic) {
        self.localizationProvider = localizationProvider
        self.networkDiagnostic = networkDiagnostic
        self.updateTextAndIcon()
    }

    init(localizationProvider: LocalizationProviderProtocol,
         networkQualityDiagnostic: NetworkQualityCallDiagnostic) {
        self.localizationProvider = localizationProvider
        self.networkQualityDiagnostic = networkQualityDiagnostic
        self.updateTextAndIcon()
    }

    private func updateTextAndIcon() {
        if let mediaDiagnostic = mediaDiagnostic {
            updateTextAndIcon(for: mediaDiagnostic)
        } else if let networkDiagnostic = networkDiagnostic {
            updateTextAndIcon(for: networkDiagnostic)
        } else if let networkQualityDiagnostic = networkQualityDiagnostic {
            updateTextAndIcon(for: networkQualityDiagnostic)
        }
    }

    private func updateTextAndIcon(for mediaDiagnostics: MediaCallDiagnostic) {
        switch mediaDiagnostic {
        case .speakingWhileMicrophoneIsMuted:
            text = localizationProvider.getLocalizedString(.callDiagnosticsUserMuted)
            icon = CompositeIcon.micOff
        case .cameraStartFailed, .cameraStartTimedOut:
            text = localizationProvider.getLocalizedString(.callDiagnosticsCameraNotWorking)
            icon = CompositeIcon.videoOff
        default:
            text = ""
            icon = nil
        }
    }

    private func updateTextAndIcon(for networkDiagnostic: NetworkCallDiagnostic) {
        text = localizationProvider.getLocalizedString(.callDiagnosticsNetworkLost)
        icon = .wifiWarning
    }

    private func updateTextAndIcon(for networkDiagnostic: NetworkQualityCallDiagnostic) {
        switch networkDiagnostic {
        case .networkSendQuality, .networkReceiveQuality:
            text = localizationProvider.getLocalizedString(.callDiagnosticsNetworkQualityLow)
        case .networkReconnectionQuality:
            text = localizationProvider.getLocalizedString(.callDiagnosticsNetworkReconnect)
        }
        icon = .wifiWarning
    }
}
