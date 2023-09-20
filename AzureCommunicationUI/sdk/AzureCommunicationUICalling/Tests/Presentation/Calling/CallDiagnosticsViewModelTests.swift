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
    test_receiving_skip_while_muted_diagnostic_update_should_be_added_to_bottom_toast_and_displayed_in_bad_state_and_not_displayed_in_good_state() {
        let sut = makeSUT()
        XCTAssertNil(sut.currentBottomToastDiagnostic)

        let badState = MediaDiagnosticModel(diagnostic: .speakingWhileMicrophoneIsMuted, value: true)
        sut.update(diagnosticsState: CallDiagnosticsState(mediaDiagnostic: badState))

        XCTAssertEqual(sut.currentBottomToastDiagnostic?.mediaDiagnostic, .speakingWhileMicrophoneIsMuted)

        let goodState = MediaDiagnosticModel(diagnostic: .speakingWhileMicrophoneIsMuted, value: false)
        sut.update(diagnosticsState: CallDiagnosticsState(mediaDiagnostic: goodState))

        XCTAssertNil(sut.currentBottomToastDiagnostic)
    }

    func
    test_receiving_network_quality_update_should_update_bottom_toast_and_display_in_bad_state_and_not_display_in_good_state() {
        let sut = makeSUT()

        XCTAssertNil(sut.currentBottomToastDiagnostic)

        let poorStateReceive = NetworkQualityDiagnosticModel(diagnostic: .networkReceiveQuality, value: .poor)
        let badStateReceive = NetworkQualityDiagnosticModel(diagnostic: .networkReceiveQuality, value: .bad)
        let goodStateReceive = NetworkQualityDiagnosticModel(diagnostic: .networkReceiveQuality, value: .good)

        sut.update(diagnosticsState: CallDiagnosticsState(networkQualityDiagnostic: poorStateReceive))
        XCTAssertEqual(sut.currentBottomToastDiagnostic?.networkDiagnostic, .networkReceiveQuality)

        sut.update(diagnosticsState: CallDiagnosticsState(networkQualityDiagnostic: badStateReceive))
        XCTAssertEqual(sut.currentBottomToastDiagnostic?.networkDiagnostic, .networkReceiveQuality)

        sut.update(diagnosticsState: CallDiagnosticsState(networkQualityDiagnostic: goodStateReceive))
        XCTAssertNil(sut.currentBottomToastDiagnostic)
    }

    func
    test_receiving_network_send_quality_update_should_update_bottom_toast_and_display_in_bad_state_and_not_display_in_good_state() {
        let sut = makeSUT()

        XCTAssertNil(sut.currentBottomToastDiagnostic)

        let poorStateSend = NetworkQualityDiagnosticModel(diagnostic: .networkSendQuality, value: .poor)
        let badStateSend = NetworkQualityDiagnosticModel(diagnostic: .networkSendQuality, value: .bad)
        let goodStateSend = NetworkQualityDiagnosticModel(diagnostic: .networkSendQuality, value: .good)

        sut.update(diagnosticsState: CallDiagnosticsState(networkQualityDiagnostic: poorStateSend))
        XCTAssertEqual(sut.currentBottomToastDiagnostic?.networkDiagnostic, .networkSendQuality)

        sut.update(diagnosticsState: CallDiagnosticsState(networkQualityDiagnostic: badStateSend))
        XCTAssertEqual(sut.currentBottomToastDiagnostic?.networkDiagnostic, .networkSendQuality)

        sut.update(diagnosticsState: CallDiagnosticsState(networkQualityDiagnostic: goodStateSend))
        XCTAssertNil(sut.currentBottomToastDiagnostic)
    }

    func
    test_receiving_new_event_bottom_toast_should_override_the_previous_presenting() {
        let sut = makeSUT()

        XCTAssertNil(sut.currentBottomToastDiagnostic)

        let poorStateSend = NetworkQualityDiagnosticModel(diagnostic: .networkSendQuality, value: .poor)
        let badStateSendReceive = NetworkQualityDiagnosticModel(diagnostic: .networkReceiveQuality, value: .bad)

        sut.update(diagnosticsState: CallDiagnosticsState(networkQualityDiagnostic: poorStateSend))
        XCTAssertEqual(sut.currentBottomToastDiagnostic?.networkDiagnostic, .networkSendQuality)

        sut.update(diagnosticsState: CallDiagnosticsState(networkQualityDiagnostic: badStateSendReceive))
        XCTAssertEqual(sut.currentBottomToastDiagnostic?.networkDiagnostic, .networkReceiveQuality)

    }

    func
    test_bottom_toast_diagnostic_should_be_dismissed_after_interval() {
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
            localizationProvider: localizationProvider ?? LocalizationProvider(logger: LoggerMocking())
        )
    }

    func makeSUTLocalizationMocking() -> CallDiagnosticsViewModel {
        return makeSUT(localizationProvider: localizationProvider)
    }
}
