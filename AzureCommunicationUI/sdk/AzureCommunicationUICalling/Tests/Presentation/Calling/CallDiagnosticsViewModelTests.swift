//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import XCTest
@testable import AzureCommunicationUICalling

class CallDiagnosticsViewModelTests: XCTestCase {
    /// Collect diagnostic actions that we dispatch through view model so we can assert the correct behavior.
    class DiagnosticCollector {
        var actions: [DiagnosticsAction] = []

        var dismissedMedia: [MediaCallDiagnostic] {
            actions.compactMap { action in
                if case let .dismissMedia(diagnostic) = action {
                    return diagnostic
                }
                return nil
            }
        }

        var dismissedNetwork: [NetworkCallDiagnostic] {
            actions.compactMap { action in
                if case let .dismissNetwork(diagnostic) = action {
                    return diagnostic
                }
                return nil
            }
        }

        var dismissedNetworkQuality: [NetworkQualityCallDiagnostic] {
            actions.compactMap { action in
                if case let .dismissNetworkQuality(diagnostic) = action {
                    return diagnostic
                }
                return nil
            }
        }

        func dispatch(_ action: Action) {
            switch action {
            case .callDiagnosticAction(let action):
                actions.append(action)
            case .audioSessionAction,
                 .callingAction,
                 .errorAction,
                 .lifecycleAction,
                 .localUserAction,
                 .permissionAction,
                 .remoteParticipantsAction,
                 .compositeExitAction,
                 .callingViewLaunched,
                 .showSupportForm,
                 .showMoreOptions,
                 .showSupportShare,
                 .showAudioSelection,
                 .showEndCallConfirmation,
                 .showParticipants,
                 .showParticipantActions,
                 .hideDrawer,
                 .visibilityAction,
                 .toastNotificationAction,
                 .setTotalParticipantCount:
                break
            }
        }
    }

    private var localizationProvider: LocalizationProviderMocking!

    override func setUp() {
        super.setUp()
        localizationProvider = LocalizationProviderMocking()
    }

    override func tearDown() {
        super.tearDown()
        localizationProvider = nil
    }

    func test_receiving_media_diagnostic_update_should_be_showing_message_bar() {
        for diagnostic in MessageBarDiagnosticViewModel.handledMediaDiagnostics {
            let collector = DiagnosticCollector()

            let sut = makeSUT(dispatchAction: collector.dispatch)

            for messageBar in sut.messageBarStack {
                XCTAssertFalse(messageBar.isDisplayed)
            }

            let badState = MediaDiagnosticModel(diagnostic: diagnostic, value: true)
            sut.update(diagnosticsState: CallDiagnosticsState(mediaDiagnostic: badState))

            XCTAssertTrue(sut.messageBarStack.first(where: { $0.mediaDiagnostic == diagnostic })?.isDisplayed ?? false)

            let goodState = MediaDiagnosticModel(diagnostic: diagnostic, value: false)
            sut.update(diagnosticsState: CallDiagnosticsState(mediaDiagnostic: goodState))

            XCTAssertFalse(sut.messageBarStack.first(where: { $0.mediaDiagnostic == diagnostic })?.isDisplayed ?? true)

            XCTAssertEqual(collector.dismissedMedia, [diagnostic])
        }
    }
}

extension CallDiagnosticsViewModelTests {
    func makeSUT(dispatchAction: @escaping ActionDispatch, localizationProvider: LocalizationProviderMocking? = nil) -> CallDiagnosticsViewModel {
        let accessibilityProvider: AccessibilityProviderProtocol = AccessibilityProviderMocking()
        return CallDiagnosticsViewModel(
            localizationProvider: localizationProvider ?? LocalizationProvider(logger: LoggerMocking()), accessibilityProvider: accessibilityProvider, dispatchAction: dispatchAction
        )
    }

    func makeSUTLocalizationMocking(dispatchAction: @escaping ActionDispatch) -> CallDiagnosticsViewModel {
        return makeSUT(dispatchAction: dispatchAction, localizationProvider: localizationProvider)
    }
}
