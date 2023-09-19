//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Combine
import Foundation

final class BottomToastDiagnosticViewModel: ObservableObject, Identifiable {
    // The time a bottom toast diagnostic should be presented for before
    // automatically beging dismissed.
    static let bottomToastBannerDismissInterval: TimeInterval = 3.0

    @Published private(set) var text: String = ""
    @Published private(set) var isDisplayed: Bool = false
    @Published private(set) var icon: CompositeIcon?

    private let localizationProvider: LocalizationProviderProtocol
    private(set) var networkDiagnostic: NetworkCallDiagnostic?
    private(set) var mediaDiagnostic: MediaCallDiagnostic?
    private weak var diagnosticsViewModel: CallDiagnosticsViewModel?
    private var expirationTime: Date?

    init(localizationProvider: LocalizationProviderProtocol,
         diagnosticsViewModel: CallDiagnosticsViewModel,
         mediaDiagnostic: MediaCallDiagnostic) {
        self.localizationProvider = localizationProvider
        self.mediaDiagnostic = mediaDiagnostic
        self.diagnosticsViewModel = diagnosticsViewModel
        self.updateText()
    }

    init(localizationProvider: LocalizationProviderProtocol,
         diagnosticsViewModel: CallDiagnosticsViewModel,
         networkDiagnostic: NetworkCallDiagnostic) {
        self.localizationProvider = localizationProvider
        self.networkDiagnostic = networkDiagnostic
        self.diagnosticsViewModel = diagnosticsViewModel
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

    func dismiss() {
        isDisplayed = false
        expirationTime = nil
    }

    func show() {
        isDisplayed = true
        expirationTime = Date(timeIntervalSinceNow: Self.bottomToastBannerDismissInterval)
    }

    var isExpired: Bool {
        guard let expirationTime = expirationTime else {
            return false
        }
        return expirationTime <= Date()
    }
}
