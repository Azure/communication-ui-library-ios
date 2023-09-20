//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Combine
import Foundation

final class CallDiagnosticsViewModel: ObservableObject {
    private var bottomToastDimissTimer: Timer!
    private let localizationProvider: LocalizationProviderProtocol

    @Published var currentBottomToastDiagnostic: BottomToastDiagnosticViewModel?

    init(localizationProvider: LocalizationProviderProtocol) {
        self.localizationProvider = localizationProvider
    }

    func update(diagnosticsState: CallDiagnosticsState) {
        if let networkDiagnostic = diagnosticsState.networkDiagnostic {
            update(diagnosticModel: networkDiagnostic)
        } else if let networkQualityDiagnostic = diagnosticsState.networkQualityDiagnostic {
            update(diagnosticModel: networkQualityDiagnostic)
        } else if let mediaDiagnostic = diagnosticsState.mediaDiagnostic {
            update(diagnosticModel: mediaDiagnostic)
        }
    }

    private func update(diagnosticModel: NetworkDiagnosticModel) {}

    private func update(diagnosticModel: NetworkQualityDiagnosticModel) {
        let isBadState = diagnosticModel.value == .bad || diagnosticModel.value == .poor

        switch diagnosticModel.diagnostic {
        case .networkReceiveQuality, .networkSendQuality:
            updateBottomToast(isBadState: isBadState,
                              viewModel: BottomToastDiagnosticViewModel(
                                            localizationProvider: localizationProvider,
                                            networkDiagnostic: diagnosticModel.diagnostic),
                              where: { $0.networkDiagnostic == diagnosticModel.diagnostic })
        default:
            break
        }
    }

    private func update(diagnosticModel: MediaDiagnosticModel) {
        if diagnosticModel.diagnostic == .speakingWhileMicrophoneIsMuted {
            updateBottomToast(isBadState: diagnosticModel.value,
                              viewModel: BottomToastDiagnosticViewModel(
                                            localizationProvider: localizationProvider,
                                            mediaDiagnostic: diagnosticModel.diagnostic),
                              where: { $0.mediaDiagnostic == diagnosticModel.diagnostic })
        }
    }

    private func updateBottomToast(isBadState: Bool,
                                   viewModel: @autoclosure () -> BottomToastDiagnosticViewModel,
                                   where compare: (BottomToastDiagnosticViewModel) -> Bool) {
        if isBadState {
            // Override previous bottom toast if being presented.
            dismissDiagnosticCurrentBottomToastDiagnostic()

            currentBottomToastDiagnostic = viewModel()
            bottomToastDimissTimer =
                Timer.scheduledTimer(withTimeInterval:
                                        BottomToastDiagnosticViewModel.bottomToastBannerDismissInterval,
                                     repeats: true) { [weak self] _ in
                    self?.dismissDiagnosticCurrentBottomToastDiagnostic()
                }
        } else if let bottomToast = currentBottomToastDiagnostic, compare(bottomToast) {
            dismissDiagnosticCurrentBottomToastDiagnostic()
        }
    }

    private func dismissDiagnosticCurrentBottomToastDiagnostic() {
        guard currentBottomToastDiagnostic != nil else {
            return
        }

        currentBottomToastDiagnostic = nil
        bottomToastDimissTimer.invalidate()
        bottomToastDimissTimer = nil
    }
}
