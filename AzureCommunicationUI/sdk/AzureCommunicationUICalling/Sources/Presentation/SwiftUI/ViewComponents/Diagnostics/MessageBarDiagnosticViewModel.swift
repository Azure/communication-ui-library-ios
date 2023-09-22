//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Combine
import Foundation

final class MessageBarDiagnosticViewModel: ObservableObject, Identifiable {

    @Published private(set) var text: String = ""
    @Published private(set) var icon: CompositeIcon?

    private let localizationProvider: LocalizationProviderProtocol

    private(set) var mediaDiagnostic: MediaCallDiagnostic
    private(set) weak var callDiagnosticViewModel: CallDiagnosticsViewModel?

    var dismissAccessibilitylabel: String {
        localizationProvider.getLocalizedString(.callDiagnosticsDismissAccessibilityLabel)
    }
    var dismissAccessibilityHint: String {
        localizationProvider.getLocalizedString(.callDiagnosticsDismissAccessibilityHint)
    }

    static let handledMediaDiagnostics: [MediaCallDiagnostic] = [
        .noSpeakerDevicesAvailable,
        .noMicrophoneDevicesAvailable,
        .microphoneNotFunctioning,
        .speakerNotFunctioning,
        .speakerMuted
    ]

    init(localizationProvider: LocalizationProviderProtocol,
         callDiagnosticViewModel: CallDiagnosticsViewModel,
         mediaDiagnostic: MediaCallDiagnostic) {
        self.localizationProvider = localizationProvider
        self.callDiagnosticViewModel = callDiagnosticViewModel
        self.mediaDiagnostic = mediaDiagnostic
        self.updateTextAndIcon(for: mediaDiagnostic)
    }

    private func updateTextAndIcon(for mediaDiagnostics: MediaCallDiagnostic) {
        switch mediaDiagnostic {
        case .noSpeakerDevicesAvailable:
            text = localizationProvider.getLocalizedString(.callDiagnosticsUnableToLocateSpeaker)
            icon = nil
        case .noMicrophoneDevicesAvailable:
            text = localizationProvider.getLocalizedString(.callDiagnosticsUnableToLocateMicrophone)
            icon = nil
        case .microphoneNotFunctioning:
            text = localizationProvider.getLocalizedString(.callDiagnosticsMicrophoneNotWorking)
            icon = nil
        case .speakerNotFunctioning:
            text = localizationProvider.getLocalizedString(.callDiagnosticsSpeakerNotWorking)
            icon = nil
        case .speakerMuted:
            text = localizationProvider.getLocalizedString(.callDiagnosticsSpeakerMuted)
            icon = nil
        default:
            text = ""
            icon = nil
        }
    }

    func dismiss() {

    }
}

extension MessageBarDiagnosticViewModel: Equatable {
    static func == (lhs: MessageBarDiagnosticViewModel, rhs: MessageBarDiagnosticViewModel) -> Bool {
        return lhs.mediaDiagnostic == rhs.mediaDiagnostic
    }
}
