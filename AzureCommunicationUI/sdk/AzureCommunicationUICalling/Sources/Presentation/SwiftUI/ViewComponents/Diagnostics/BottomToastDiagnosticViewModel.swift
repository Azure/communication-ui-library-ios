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
        self.updateText()
    }

    init(localizationProvider: LocalizationProviderProtocol,
         networkDiagnostic: NetworkCallDiagnostic) {
        self.localizationProvider = localizationProvider
        self.networkDiagnostic = networkDiagnostic
        self.updateText()
    }

    private func updateText() {
        if let mediaDiagnostic = mediaDiagnostic {
            updateTextAndIcon(for: mediaDiagnostic)
        } else if let networkDiagnostic = networkDiagnostic {
            updateTextAndIcon(for: networkDiagnostic)
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
        switch networkDiagnostic {
        case .networkSendQuality, .networkReceiveQuality:
            text = localizationProvider.getLocalizedString(.callDiagnosticsNetworkQualityLow)
        case .networkUnavailable, .networkRelaysUnreachable:
            text = localizationProvider.getLocalizedString(.callDiagnosticsNetworkLost)
        case .networkReconnectionQuality:
            text = localizationProvider.getLocalizedString(.callDiagnosticsNetworkReconnect)
        }
        icon = .wifiWarning
    }
}
