//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Combine
import Foundation

final class CallDiagnosticsViewModel: ObservableObject {
    private var bottomToastDimissTimer: Timer!
    private let localizationProvider: LocalizationProviderProtocol
    private let dispatch: ActionDispatch

    @Published var currentBottomToastDiagnostic: BottomToastDiagnosticViewModel?
    @Published var messageBarStack: [MessageBarDiagnosticViewModel] = []

    init(localizationProvider: LocalizationProviderProtocol,
         dispatchAction: @escaping ActionDispatch) {
        self.localizationProvider = localizationProvider
        self.dispatch = dispatchAction
        initializeMessageBarListModel()
    }

    func initializeMessageBarListModel() {
        messageBarStack =
            MessageBarDiagnosticViewModel.handledMediaDiagnostics
                .map { diagnostic in
                    return MessageBarDiagnosticViewModel(
                        localizationProvider: localizationProvider,
                        callDiagnosticViewModel: self,
                        mediaDiagnostic: diagnostic
                    )
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

    private func update(diagnosticModel: NetworkDiagnosticModel) {
        updateBottomToast(isBadState: diagnosticModel.value,
                          viewModel: BottomToastDiagnosticViewModel(
                                        localizationProvider: localizationProvider,
                                        networkDiagnostic: diagnosticModel.diagnostic),
                          dismissAfterInterval: true,
                          where: { $0.networkDiagnostic == diagnosticModel.diagnostic })
    }

    private func update(diagnosticModel: NetworkQualityDiagnosticModel) {
        // Special case network reconnecting diagnostic to be permanent until reconnect
        // is in good state.
        let dismissAfterInterval = diagnosticModel.diagnostic != .networkReconnectionQuality
        updateBottomToast(isBadState: diagnosticModel.value == .bad || diagnosticModel.value == .poor,
                          viewModel: BottomToastDiagnosticViewModel(
                                        localizationProvider: localizationProvider,
                                        networkQualityDiagnostic: diagnosticModel.diagnostic),
                          dismissAfterInterval: dismissAfterInterval,
                          where: { $0.networkQualityDiagnostic == diagnosticModel.diagnostic })
    }

    private func update(diagnosticModel: MediaDiagnosticModel) {
        if BottomToastDiagnosticViewModel.handledMediaDiagnostics.contains(diagnosticModel.diagnostic) {
            updateBottomToast(isBadState: diagnosticModel.value,
                              viewModel: BottomToastDiagnosticViewModel(
                                            localizationProvider: localizationProvider,
                                            mediaDiagnostic: diagnosticModel.diagnostic),
                              dismissAfterInterval: true,
                              where: { $0.mediaDiagnostic == diagnosticModel.diagnostic })
        } else if MessageBarDiagnosticViewModel.handledMediaDiagnostics.contains(diagnosticModel.diagnostic) {
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

    private func updateBottomToast(isBadState: Bool,
                                   viewModel: @autoclosure () -> BottomToastDiagnosticViewModel,
                                   dismissAfterInterval: Bool,
                                   where compare: (BottomToastDiagnosticViewModel) -> Bool) {
        if isBadState {
            if let bottomToast = currentBottomToastDiagnostic, compare(bottomToast) {
                invalidateTimer()
            } else {
                // If is a different diagnostic, override previous bottom toast if is being presented.
                dispatchBottomToastDismissAction()
                dismissDiagnosticCurrentBottomToastDiagnostic()
                // Make this now current diagnostic.
                currentBottomToastDiagnostic = viewModel()
            }

            // Restart timer for interval dismiss.
            if dismissAfterInterval {
                bottomToastDimissTimer =
                    Timer.scheduledTimer(withTimeInterval:
                                            BottomToastDiagnosticViewModel.bottomToastBannerDismissInterval,
                                         repeats: false) { [weak self] _ in
                        self?.dispatchBottomToastDismissAction()
                        self?.dismissDiagnosticCurrentBottomToastDiagnostic()
                    }
            } else {
                invalidateTimer()
            }
        } else if let bottomToast = currentBottomToastDiagnostic, compare(bottomToast) {
            dispatchBottomToastDismissAction()
            dismissDiagnosticCurrentBottomToastDiagnostic()
        }
    }

    private func dismissDiagnosticCurrentBottomToastDiagnostic() {
        guard currentBottomToastDiagnostic != nil else {
            return
        }

        currentBottomToastDiagnostic = nil
        invalidateTimer()
    }

    private func invalidateTimer() {
        bottomToastDimissTimer?.invalidate()
        bottomToastDimissTimer = nil
    }

    private func dispatchBottomToastDismissAction() {
        if let networkDiagnostic = currentBottomToastDiagnostic?.networkDiagnostic {
            dispatch(.callDiagnosticAction(.dismissNetwork(diagnostic: networkDiagnostic)))
        } else if let networkQualityDiagnostic = currentBottomToastDiagnostic?.networkQualityDiagnostic {
            dispatch(.callDiagnosticAction(.dismissNetworkQuality(diagnostic: networkQualityDiagnostic)))
        } else if let mediaDiagnostic = currentBottomToastDiagnostic?.mediaDiagnostic {
            dispatch(.callDiagnosticAction(.dismissMedia(diagnostic: mediaDiagnostic)))
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
