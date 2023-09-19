//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Combine
import Foundation

final class CallDiagnosticsViewModel: ObservableObject {
    private var bottomToastDimissTimer: Timer!
    private let localizationProvider: LocalizationProviderProtocol

    @Published var bottomToastDiagnostics: [BottomToastDiagnosticViewModel] = []

    init(localizationProvider: LocalizationProviderProtocol) {
        self.localizationProvider = localizationProvider
        self.bottomToastDimissTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            self?.dismissDiagnosticsIfExpired()
        }
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
            updateBottomToastList(isBadState: isBadState,
                                  viewModel: BottomToastDiagnosticViewModel(
                                                localizationProvider: localizationProvider,
                                                diagnosticsViewModel: self,
                                                networkDiagnostic: diagnosticModel.diagnostic),
                                  where: { $0.networkDiagnostic == diagnosticModel.diagnostic })
        default:
            break
        }
    }

    private func update(diagnosticModel: MediaDiagnosticModel) {
        if diagnosticModel.diagnostic == .speakingWhileMicrophoneIsMuted {
            updateBottomToastList(isBadState: diagnosticModel.value,
                                  viewModel: BottomToastDiagnosticViewModel(
                                                localizationProvider: localizationProvider,
                                                diagnosticsViewModel: self,
                                                mediaDiagnostic: diagnosticModel.diagnostic),
                                  where: { $0.mediaDiagnostic == diagnosticModel.diagnostic })
        }
    }

    private func updateBottomToastList(isBadState: Bool,
                                       viewModel: @autoclosure () -> BottomToastDiagnosticViewModel,
                                       where compare: (BottomToastDiagnosticViewModel) -> Bool) {
        if isBadState {
            var toastViewModel = bottomToastDiagnostics.first(where: compare)
            if toastViewModel == nil {
                toastViewModel = viewModel()
                bottomToastDiagnostics.append(toastViewModel!)
            }
            toastViewModel?.show()
        } else if let toastViewModel = bottomToastDiagnostics.first(where: compare) {
            toastViewModel.dismiss()
        }
    }

    private func dismissDiagnosticsIfExpired() {
        for toastViewModel in bottomToastDiagnostics where toastViewModel.isExpired {
            toastViewModel.dismiss()
        }
    }
}
