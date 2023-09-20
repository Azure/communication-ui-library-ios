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
            switch mediaDiagnostic {
            case .speakingWhileMicrophoneIsMuted:
                text = localizationProvider.getLocalizedString(.callDiagnosticsUserMuted)
                icon = CompositeIcon.micOff
            default:
                text = ""
                icon = nil
            }
        } else if let networkDiagnostic = networkDiagnostic {
            switch networkDiagnostic {
            case .networkSendQuality, .networkReceiveQuality:
                text = localizationProvider.getLocalizedString(.callDiagnosticsNetworkQualityLow)
            default:
                text = ""
                icon = nil
            }
        }
    }

    var dismissAccessibilitylabel: String {
        localizationProvider.getLocalizedString(.callDiagnosticsDismissAccessibilityLabel)
    }

    var dismissAccessibilityHint: String {
        localizationProvider.getLocalizedString(.callDiagnosticsDismissAccessibilityHint)
    }
}
