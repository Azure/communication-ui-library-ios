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

    private func update(diagnosticModel: NetworkDiagnosticModel) {
        updateBottomToast(isBadState: diagnosticModel.value,
                          viewModel: BottomToastDiagnosticViewModel(
                                        localizationProvider: localizationProvider,
                                        networkDiagnostic: diagnosticModel.diagnostic),
                          where: { $0.networkDiagnostic == diagnosticModel.diagnostic })
    }

    private func update(diagnosticModel: NetworkQualityDiagnosticModel) {
        updateBottomToast(isBadState: diagnosticModel.value == .bad || diagnosticModel.value == .poor,
                          viewModel: BottomToastDiagnosticViewModel(
                                        localizationProvider: localizationProvider,
                                        networkDiagnostic: diagnosticModel.diagnostic),
                          where: { $0.networkDiagnostic == diagnosticModel.diagnostic })
    }

    private func update(diagnosticModel: MediaDiagnosticModel) {
        if BottomToastDiagnosticViewModel.handledMediaDiagnostics.contains(diagnosticModel.diagnostic) {
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
            // Override previous bottom toast if is being presented.
            dismissDiagnosticCurrentBottomToastDiagnostic()

            currentBottomToastDiagnostic = viewModel()
            bottomToastDimissTimer =
                Timer.scheduledTimer(withTimeInterval:
                                        BottomToastDiagnosticViewModel.bottomToastBannerDismissInterval,
                                     repeats: false) { [weak self] _ in
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
