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
        let badState = MediaDiagnosticModel(diagnostic: .speakingWhileMicrophoneIsMuted, value: true)
        sut.update(diagnosticsState: CallDiagnosticsState(mediaDiagnostic: badState))

        XCTAssertEqual(sut.bottomToastDiagnostics.count, 1)
        XCTAssertEqual(sut.bottomToastDiagnostics.first?.mediaDiagnostic, .speakingWhileMicrophoneIsMuted)
        XCTAssertEqual(sut.bottomToastDiagnostics.first?.isDisplayed, true)

        let goodState = MediaDiagnosticModel(diagnostic: .speakingWhileMicrophoneIsMuted, value: false)
        sut.update(diagnosticsState: CallDiagnosticsState(mediaDiagnostic: goodState))

        XCTAssertEqual(sut.bottomToastDiagnostics.count, 1)
        XCTAssertEqual(sut.bottomToastDiagnostics.first?.mediaDiagnostic, .speakingWhileMicrophoneIsMuted)
        XCTAssertEqual(sut.bottomToastDiagnostics.first?.isDisplayed, false)
    }

    func
    test_receiving_network_quality_update_should_be_added_to_bottom_toast_and_displayed_in_bad_state_and_not_displayed_in_good_state() {
        let sut = makeSUT()

        let poorStateSend = NetworkQualityDiagnosticModel(diagnostic: .networkSendQuality, value: .poor)
        let poorStateReceive = NetworkQualityDiagnosticModel(diagnostic: .networkReceiveQuality, value: .poor)

        let badStateSend = NetworkQualityDiagnosticModel(diagnostic: .networkSendQuality, value: .bad)
        let badStateReceive = NetworkQualityDiagnosticModel(diagnostic: .networkReceiveQuality, value: .bad)

        let goodStateSend = NetworkQualityDiagnosticModel(diagnostic: .networkSendQuality, value: .good)
        let goodStateReceive = NetworkQualityDiagnosticModel(diagnostic: .networkReceiveQuality, value: .good)

        sut.update(diagnosticsState: CallDiagnosticsState(networkQualityDiagnostic: poorStateSend))
        sut.update(diagnosticsState: CallDiagnosticsState(networkQualityDiagnostic: poorStateReceive))

        XCTAssertEqual(sut.bottomToastDiagnostics.count, 2)
        XCTAssertEqual(sut.bottomToastDiagnostics.compactMap { $0.networkDiagnostic }, [.networkSendQuality, .networkReceiveQuality])
        XCTAssertEqual(sut.bottomToastDiagnostics.compactMap { $0.isDisplayed }, [true, true])

        sut.update(diagnosticsState: CallDiagnosticsState(networkQualityDiagnostic: badStateReceive))

        sut.update(diagnosticsState: CallDiagnosticsState(networkQualityDiagnostic: goodStateSend))
        sut.update(diagnosticsState: CallDiagnosticsState(networkQualityDiagnostic: badStateReceive))

        XCTAssertEqual(sut.bottomToastDiagnostics.count, 2)
        XCTAssertEqual(sut.bottomToastDiagnostics.compactMap { $0.networkDiagnostic }, [.networkSendQuality, .networkReceiveQuality])
        XCTAssertEqual(sut.bottomToastDiagnostics.compactMap { $0.isDisplayed }, [false, true])

        sut.update(diagnosticsState: CallDiagnosticsState(networkQualityDiagnostic: goodStateReceive))

        XCTAssertEqual(sut.bottomToastDiagnostics.compactMap { $0.isDisplayed }, [false, false])
    }

    func
    test_bottom_toast_diagnostic_should_be_dismissed_after_interval() {
        let sut = makeSUT()
        let badState = MediaDiagnosticModel(diagnostic: .speakingWhileMicrophoneIsMuted, value: true)
        sut.update(diagnosticsState: CallDiagnosticsState(mediaDiagnostic: badState))

        XCTAssertEqual(sut.bottomToastDiagnostics.count, 1)
        XCTAssertEqual(sut.bottomToastDiagnostics.first?.mediaDiagnostic, .speakingWhileMicrophoneIsMuted)
        XCTAssertEqual(sut.bottomToastDiagnostics.first?.isDisplayed, true)

        let expectation = expectation(description: "Wait for timed dismiss")
        XCTWaiter().wait(for: [expectation], timeout: BottomToastDiagnosticViewModel.bottomToastBannerDismissInterval + 1.0)

        XCTAssertEqual(sut.bottomToastDiagnostics.count, 1)
        XCTAssertEqual(sut.bottomToastDiagnostics.first?.mediaDiagnostic, .speakingWhileMicrophoneIsMuted)
        XCTAssertEqual(sut.bottomToastDiagnostics.first?.isDisplayed, false)
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
