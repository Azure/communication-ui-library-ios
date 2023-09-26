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

    func test_that_presenting_handled_media_diagnostics_shows_title_and_icon() {
        let expectedTextAndIcon: [MediaCallDiagnostic: (String, CompositeIcon)] = [
            .speakingWhileMicrophoneIsMuted: ("AzureCommunicationUICalling.Diagnostics.Text.YouAreMuted",
                                              CompositeIcon.micOff),
            .cameraStartFailed: ("AzureCommunicationUICalling.Diagnostics.Text.CameraNotStarted",
                                 CompositeIcon.videoOff),
            .cameraStartTimedOut: ("AzureCommunicationUICalling.Diagnostics.Text.CameraNotStarted",
                                   CompositeIcon.videoOff)
        ]

        for diagnostic in BottomToastDiagnosticViewModel.handledMediaDiagnostics {
            let sut = makeSUT(mediaDiagnostic: diagnostic, localizationProvider: localizationProvider)

            guard let (text, icon) = expectedTextAndIcon[diagnostic] else {
                return XCTFail("Value not verified")
            }

            XCTAssertEqual(sut.text, text)
            XCTAssertEqual(sut.icon, icon)
        }
    }

    func test_that_presenting_handled_network_diagnostics_shows_title_and_icon() {
        let expectedTextAndIcon: [NetworkCallDiagnostic: String] = [
            .networkReceiveQuality: "AzureCommunicationUICalling.Diagnostics.Text.NetworkQualityLow",
            .networkSendQuality: "AzureCommunicationUICalling.Diagnostics.Text.NetworkQualityLow",
            .networkUnavailable: "AzureCommunicationUICalling.Diagnostics.Text.NetworkLost",
            .networkRelaysUnreachable: "AzureCommunicationUICalling.Diagnostics.Text.NetworkLost",
            .networkReconnectionQuality: "AzureCommunicationUICalling.Diagnostics.Text.NetworkReconnect"
        ]

        for diagnostic in NetworkCallDiagnostic.allCases {
            let sut = makeSUT(networkDiagnostic: diagnostic, localizationProvider: localizationProvider)

            guard let text = expectedTextAndIcon[diagnostic] else {
                return XCTFail("Value not verified")
            }

            XCTAssertEqual(sut.text, text)
            XCTAssertEqual(sut.icon, .wifiWarning)
        }
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
