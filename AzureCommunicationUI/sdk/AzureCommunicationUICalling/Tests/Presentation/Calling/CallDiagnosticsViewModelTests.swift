//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import XCTest
@testable import AzureCommunicationUICalling

class CallDiagnosticsViewModelTests: XCTestCase {
    private var localizationProvider: LocalizationProviderMocking!

    override func setUp() {
        super.setUp()
        localizationProvider = LocalizationProviderMocking()
    }

    override func tearDown() {
        super.tearDown()
        localizationProvider = nil
    }

    func
    test_receiving_media_diagnostic_update_should_be_added_to_bottom_toast_and_displayed_in_bad_state_and_not_displayed_in_good_state() {
        for diagnostic in BottomToastDiagnosticViewModel.handledMediaDiagnostics {
            let sut = makeSUT()
            XCTAssertNil(sut.currentBottomToastDiagnostic)

            let badState = MediaDiagnosticModel(diagnostic: diagnostic, value: true)
            sut.update(diagnosticsState: CallDiagnosticsState(mediaDiagnostic: badState))

            XCTAssertEqual(sut.currentBottomToastDiagnostic?.mediaDiagnostic, diagnostic)

            let goodState = MediaDiagnosticModel(diagnostic: diagnostic, value: false)
            sut.update(diagnosticsState: CallDiagnosticsState(mediaDiagnostic: goodState))

            XCTAssertNil(sut.currentBottomToastDiagnostic)
        }
    }

    func
    test_receiving_media_diagnostic_update_should_be_showing_message_bar() {
        for diagnostic in MessageBarDiagnosticViewModel.handledMediaDiagnostics {
            let sut = makeSUT()

            // Not handled by bottom toast view.
            XCTAssertNil(sut.currentBottomToastDiagnostic)

            for messageBar in sut.messageBarStack {
                XCTAssertFalse(messageBar.isDisplayed)
            }

            let badState = MediaDiagnosticModel(diagnostic: diagnostic, value: true)
            sut.update(diagnosticsState: CallDiagnosticsState(mediaDiagnostic: badState))

            XCTAssertNil(sut.currentBottomToastDiagnostic)
            XCTAssertTrue(sut.messageBarStack.first(where: { $0.mediaDiagnostic == diagnostic })?.isDisplayed ?? false)

            let goodState = MediaDiagnosticModel(diagnostic: diagnostic, value: false)
            sut.update(diagnosticsState: CallDiagnosticsState(mediaDiagnostic: goodState))

            XCTAssertNil(sut.currentBottomToastDiagnostic)
            XCTAssertFalse(sut.messageBarStack.first(where: { $0.mediaDiagnostic == diagnostic })?.isDisplayed ?? true)
        }
    }

    func test_receiving_media_unhandled_diagnostic_update_should_not_be_displayed() {
        let otherMediaDiagnostics = MediaCallDiagnostic.allCases.filter({ !BottomToastDiagnosticViewModel.handledMediaDiagnostics.contains($0) })
        for diagnostic in otherMediaDiagnostics {
            let sut = makeSUT()
            XCTAssertNil(sut.currentBottomToastDiagnostic)

            let badState = MediaDiagnosticModel(diagnostic: diagnostic, value: true)
            sut.update(diagnosticsState: CallDiagnosticsState(mediaDiagnostic: badState))

            XCTAssertNil(sut.currentBottomToastDiagnostic)

            let goodState = MediaDiagnosticModel(diagnostic: diagnostic, value: false)
            sut.update(diagnosticsState: CallDiagnosticsState(mediaDiagnostic: goodState))

            XCTAssertNil(sut.currentBottomToastDiagnostic)
        }
    }

    func
    test_receiving_network_quality_update_should_update_bottom_toast_and_display_in_bad_state_and_not_display_in_good_state() {
        let networkQualityList: [NetworkCallDiagnostic] = [
            .networkSendQuality,
            .networkReceiveQuality,
            .networkReconnectionQuality
        ]

        for diagnostic in networkQualityList {
            let sut = makeSUT()

            XCTAssertNil(sut.currentBottomToastDiagnostic)

            let poorState = NetworkQualityDiagnosticModel(diagnostic: diagnostic, value: .poor)
            let badState = NetworkQualityDiagnosticModel(diagnostic: diagnostic, value: .bad)
            let goodState = NetworkQualityDiagnosticModel(diagnostic: diagnostic, value: .good)

            sut.update(diagnosticsState: CallDiagnosticsState(networkQualityDiagnostic: poorState))
            XCTAssertEqual(sut.currentBottomToastDiagnostic?.networkDiagnostic, diagnostic)

            sut.update(diagnosticsState: CallDiagnosticsState(networkQualityDiagnostic: badState))
            XCTAssertEqual(sut.currentBottomToastDiagnostic?.networkDiagnostic, diagnostic)

            sut.update(diagnosticsState: CallDiagnosticsState(networkQualityDiagnostic: goodState))
            XCTAssertNil(sut.currentBottomToastDiagnostic)
        }
    }

    func test_receiving_new_event_bottom_toast_should_override_the_previous_presenting() {
        let sut = makeSUT()

        XCTAssertNil(sut.currentBottomToastDiagnostic)

        let poorStateSend = NetworkQualityDiagnosticModel(diagnostic: .networkSendQuality, value: .poor)
        let badStateSendReceive = NetworkQualityDiagnosticModel(diagnostic: .networkReceiveQuality, value: .bad)

        sut.update(diagnosticsState: CallDiagnosticsState(networkQualityDiagnostic: poorStateSend))
        XCTAssertEqual(sut.currentBottomToastDiagnostic?.networkDiagnostic, .networkSendQuality)

        sut.update(diagnosticsState: CallDiagnosticsState(networkQualityDiagnostic: badStateSendReceive))
        XCTAssertEqual(sut.currentBottomToastDiagnostic?.networkDiagnostic, .networkReceiveQuality)

    }

    func test_bottom_toast_diagnostic_should_be_dismissed_after_interval() {
        let sut = makeSUT()
        let badState = MediaDiagnosticModel(diagnostic: .speakingWhileMicrophoneIsMuted, value: true)
        sut.update(diagnosticsState: CallDiagnosticsState(mediaDiagnostic: badState))

        XCTAssertEqual(sut.currentBottomToastDiagnostic?.mediaDiagnostic, .speakingWhileMicrophoneIsMuted)

        let expectation = expectation(description: "Wait for timed dismiss")
        XCTWaiter().wait(for: [expectation], timeout: BottomToastDiagnosticViewModel.bottomToastBannerDismissInterval + 1.0)

        XCTAssertNil(sut.currentBottomToastDiagnostic)
    }
}

extension CallDiagnosticsViewModelTests {
    func makeSUT(localizationProvider: LocalizationProviderMocking? = nil) -> CallDiagnosticsViewModel {
        return CallDiagnosticsViewModel(
            localizationProvider: localizationProvider ?? LocalizationProvider(logger: LoggerMocking()),
            isDisplayCallDiagnosticsOn: true
        )
    }

    func makeSUTLocalizationMocking() -> CallDiagnosticsViewModel {
        return makeSUT(localizationProvider: localizationProvider)
    }
}
