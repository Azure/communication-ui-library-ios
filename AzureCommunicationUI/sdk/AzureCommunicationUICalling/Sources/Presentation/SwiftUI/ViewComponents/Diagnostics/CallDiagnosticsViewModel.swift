//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Combine
import Foundation

final class CallDiagnosticsViewModel: ObservableObject {
    private var bottomToastDismissTimer: Timer!
    private let localizationProvider: LocalizationProviderProtocol
    private let accessibilityProvider: AccessibilityProviderProtocol
    private let dispatch: ActionDispatch

    @Published var messageBarStack: [MessageBarDiagnosticViewModel] = []

    init(localizationProvider: LocalizationProviderProtocol,
         accessibilityProvider: AccessibilityProviderProtocol,
         dispatchAction: @escaping ActionDispatch) {
        self.localizationProvider = localizationProvider
        self.accessibilityProvider = accessibilityProvider
        self.dispatch = dispatchAction
        initializeMessageBarListModel()
    }

    func initializeMessageBarListModel() {
        messageBarStack =
            MessageBarDiagnosticViewModel.handledMediaDiagnostics
                .map { diagnostic in
                    return MessageBarDiagnosticViewModel(
                        localizationProvider: localizationProvider,
                        accessibilityProvider: accessibilityProvider,
                        callDiagnosticViewModel: self,
                        mediaDiagnostic: diagnostic
                    )
                }
    }

    func update(diagnosticsState: CallDiagnosticsState) {
        if let mediaDiagnostic = diagnosticsState.mediaDiagnostic {
            update(diagnosticModel: mediaDiagnostic)
        }
    }

    private func update(diagnosticModel: MediaDiagnosticModel) {
        if MessageBarDiagnosticViewModel.handledMediaDiagnostics.contains(diagnosticModel.diagnostic) {
            updateMessageBarList(diagnosticModel: diagnosticModel)
        }
    }

    private func updateMessageBarList(diagnosticModel: MediaDiagnosticModel) {
        guard let messageDiagnosticViewModel = messageBarStack
            .first(where: { $0.mediaDiagnostic == diagnosticModel.diagnostic }) else {
            return
        }

        if diagnosticModel.value {
            messageDiagnosticViewModel.show()
        } else if messageDiagnosticViewModel.isDisplayed {
            messageDiagnosticViewModel.dismiss()
            // Clean up the diagnostic state when dismiss.
            dispatch(.callDiagnosticAction(.dismissMedia(diagnostic: diagnosticModel.diagnostic)))
        }
    }

    func dismissMessageBar(diagnostic: MediaCallDiagnostic) {
        guard let messageDiagnosticViewModel = messageBarStack
            .first(where: { $0.mediaDiagnostic == diagnostic }) else {
            return
        }
        messageDiagnosticViewModel.dismiss()
        // Clean up the diagnostic state when dismiss.
        dispatch(.callDiagnosticAction(.dismissMedia(diagnostic: diagnostic)))
    }
}
