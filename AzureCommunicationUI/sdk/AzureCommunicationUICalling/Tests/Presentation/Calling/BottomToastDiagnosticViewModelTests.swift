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

    func test_that_presenting_camera_start_failed_diagnostic_bottom_toast_shows_title_and_icon() {
        let sut = makeSUT(mediaDiagnostic: .cameraStartFailed, localizationProvider: localizationProvider)
        XCTAssertEqual(sut.text, "AzureCommunicationUICalling.Diagnostics.Text.CameraNotStarted")
        XCTAssertEqual(sut.icon, CompositeIcon.videoOff)
    }

    func test_that_presenting_camera_start_timed_out_diagnostic_bottom_toast_shows_title_and_icon() {
        let sut = makeSUT(mediaDiagnostic: .cameraStartTimedOut, localizationProvider: localizationProvider)
        XCTAssertEqual(sut.text, "AzureCommunicationUICalling.Diagnostics.Text.CameraNotStarted")
        XCTAssertEqual(sut.icon, CompositeIcon.videoOff)
    }

    func test_that_presenting_network_receive_quality_bottom_toast_shows_title_and_icon() {
        let sut = makeSUT(networkDiagnostic: .networkReceiveQuality, localizationProvider: localizationProvider)
        XCTAssertEqual(sut.text, "AzureCommunicationUICalling.Diagnostics.Text.NetworkQualityLow")
        XCTAssertEqual(sut.icon, CompositeIcon.wifiWarning)
    }

    func test_that_presenting_network_send_quality_bottom_toast_shows_title_and_icon() {
        let sut = makeSUT(networkDiagnostic: .networkSendQuality, localizationProvider: localizationProvider)
        XCTAssertEqual(sut.text, "AzureCommunicationUICalling.Diagnostics.Text.NetworkQualityLow")
        XCTAssertEqual(sut.icon, CompositeIcon.wifiWarning)
    }

    func test_that_presenting_network_unavailable_bottom_toast_shows_title_and_icon() {
        let sut = makeSUT(networkDiagnostic: .networkUnavailable, localizationProvider: localizationProvider)
        XCTAssertEqual(sut.text, "AzureCommunicationUICalling.Diagnostics.Text.NetworkLost")
        XCTAssertEqual(sut.icon, CompositeIcon.wifiWarning)
    }

    func test_that_presenting_network_relays_unrachable_bottom_toast_shows_title_and_icon() {
        let sut = makeSUT(networkDiagnostic: .networkRelaysUnreachable, localizationProvider: localizationProvider)
        XCTAssertEqual(sut.text, "AzureCommunicationUICalling.Diagnostics.Text.NetworkLost")
        XCTAssertEqual(sut.icon, CompositeIcon.wifiWarning)
    }

    func test_that_presenting_network_reconnection_quality_bottom_toast_shows_title_and_icon() {
        let sut = makeSUT(networkDiagnostic: .networkReconnectionQuality, localizationProvider: localizationProvider)
        XCTAssertEqual(sut.text, "AzureCommunicationUICalling.Diagnostics.Text.NetworkReconnect")
        XCTAssertEqual(sut.icon, CompositeIcon.wifiWarning)
    }

    func test_that_unhadled_media_diagnostics_bottom_toast_dont_present_any_text() {
        let otherMediaDiagnostics = MediaCallDiagnostic.allCases.filter({ !BottomToastDiagnosticViewModel.handledMediaDiagnostics.contains($0) })
        for diagnostic in otherMediaDiagnostics {
            let sut = makeSUT(mediaDiagnostic: diagnostic, localizationProvider: localizationProvider)
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
