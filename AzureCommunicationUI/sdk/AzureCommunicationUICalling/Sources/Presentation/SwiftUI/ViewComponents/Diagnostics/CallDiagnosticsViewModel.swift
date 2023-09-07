//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import Combine

class CallDiagnosticsViewModel: ObservableObject {
    @Published private(set) var isDisplayed: Bool = false
    @Published private(set) var title: String = ""
    @Published private(set) var subtitle: String = ""

    private let localizationProvider: LocalizationProviderProtocol
    private var presentingNetworkDiagnostic: NetworkCallDiagnostic?
    private var presentingMediaDiagnostic: MediaCallDiagnostic?

    init(localizationProvider: LocalizationProviderProtocol) {
        self.localizationProvider = localizationProvider
    }

    var dismissContent: String {
        localizationProvider.getLocalizedString(.snackBarDismiss)
    }
    var dismissAccessibilitylabel: String {
        localizationProvider.getLocalizedString(.snackBarDismissAccessibilityLabel)
    }
    var dismissAccessibilityHint: String {
        localizationProvider.getLocalizedString(.snackBarDismissAccessibilityHint)
    }

    func dismiss() {
        isDisplayed = false
        presentingNetworkDiagnostic = nil
        presentingMediaDiagnostic = nil
    }

    func show() {
        isDisplayed = true
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
        if diagnosticModel.value {
            title = "Network"
            subtitle = "\(diagnosticModel.diagnostic)"
            presentingNetworkDiagnostic = diagnosticModel.diagnostic
            show()
        } else if presentingNetworkDiagnostic == diagnosticModel.diagnostic {
            dismiss()
        }
    }

    private func update(diagnosticModel: NetworkQualityDiagnosticModel) {
        if diagnosticModel.value == .bad || diagnosticModel.value == .poor {
            title = "Network"
            subtitle = "\(diagnosticModel.diagnostic) : \(diagnosticModel.value)"
            presentingNetworkDiagnostic = diagnosticModel.diagnostic
            show()
        } else if presentingNetworkDiagnostic == diagnosticModel.diagnostic {
            dismiss()
        }
    }

    private func update(diagnosticModel: MediaDiagnosticModel) {
        if diagnosticModel.value {
            title = "Media"
            subtitle = "\(diagnosticModel.diagnostic)"
            presentingMediaDiagnostic = diagnosticModel.diagnostic
            show()
        } else if presentingMediaDiagnostic == diagnosticModel.diagnostic {
            dismiss()
        }
    }
}
