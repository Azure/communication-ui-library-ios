//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import XCTest
@testable import AzureCommunicationUICalling

class BottomToastDiagnosticViewModelTests: XCTestCase {
    private var localizationProvider: LocalizationProviderMocking!

    override func setUp() {
        super.setUp()
        localizationProvider = LocalizationProviderMocking()
    }

    override func tearDown() {
        super.tearDown()
        localizationProvider = nil
    }

    func test_that_presenting_speaking_while_muted_diagnostic_bottom_toast_shows_title_and_icon() {
        let sut = makeSUT(mediaDiagnostic: .speakingWhileMicrophoneIsMuted, localizationProvider: localizationProvider)
        XCTAssertEqual(sut.text, "AzureCommunicationUICalling.Diagnostics.Text.YouAreMuted")
        XCTAssertEqual(sut.icon, CompositeIcon.micOff)
    }

    func test_that_presenting_network_receive_quality_bottom_toast_shows_title_and_icon() {
        let sut = makeSUT(networkDiagnostic: .networkReceiveQuality, localizationProvider: localizationProvider)
        XCTAssertEqual(sut.text, "AzureCommunicationUICalling.Diagnostics.Text.NetworkQualityLow")
        XCTAssertEqual(sut.icon, nil)
    }

    func test_that_presenting_network_send_quality_bottom_toast_shows_title_and_icon() {
        let sut = makeSUT(networkDiagnostic: .networkSendQuality, localizationProvider: localizationProvider)
        XCTAssertEqual(sut.text, "AzureCommunicationUICalling.Diagnostics.Text.NetworkQualityLow")
        XCTAssertEqual(sut.icon, nil)
    }

    func test_that_unhadled_media_diagnostics_bottom_toast_dont_present_any_text() {
        let otherMediaDiagnostics = MediaCallDiagnostic.allCases.filter({ $0 != .speakingWhileMicrophoneIsMuted })
        for diagnostic in otherMediaDiagnostics {
            let sut = makeSUT(mediaDiagnostic: diagnostic, localizationProvider: localizationProvider)
            XCTAssertEqual(sut.text, "")
            XCTAssertEqual(sut.icon, nil)
        }
    }

    func test_that_unhadled_network_diagnostics_bottom_toast_dont_present_any_text() {
        let otherNetworkDiagnostics = NetworkCallDiagnostic.allCases
            .filter({ $0 != .networkSendQuality &&  $0 != .networkReceiveQuality})
        for diagnostic in otherNetworkDiagnostics {
            let sut = makeSUT(networkDiagnostic: diagnostic, localizationProvider: localizationProvider)
            XCTAssertEqual(sut.text, "")
            XCTAssertEqual(sut.icon, nil)
        }
    }
}

extension BottomToastDiagnosticViewModelTests {
    func makeSUT(mediaDiagnostic: MediaCallDiagnostic,
                 localizationProvider: LocalizationProviderMocking? = nil) -> BottomToastDiagnosticViewModel {
        let localizationProviderValue: LocalizationProviderProtocol = localizationProvider ?? LocalizationProvider(logger: LoggerMocking())
        return BottomToastDiagnosticViewModel(localizationProvider: localizationProviderValue,
                                              mediaDiagnostic: mediaDiagnostic)
    }

    func makeSUT(networkDiagnostic: NetworkCallDiagnostic,
                 localizationProvider: LocalizationProviderMocking? = nil) -> BottomToastDiagnosticViewModel {
        let localizationProviderValue: LocalizationProviderProtocol = localizationProvider ?? LocalizationProvider(logger: LoggerMocking())
        return BottomToastDiagnosticViewModel(localizationProvider: localizationProviderValue,
                                              networkDiagnostic: networkDiagnostic)
    }
}
