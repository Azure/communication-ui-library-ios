//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import XCTest
@testable import AzureCommunicationUICalling

class MessageBarDiagnosticViewModelTests: XCTestCase {
    private var localizationProvider: LocalizationProviderMocking!

    override func setUp() {
        super.setUp()
        localizationProvider = LocalizationProviderMocking()
    }

    override func tearDown() {
        super.tearDown()
        localizationProvider = nil
    }

    func test_that_presenting_handled_diagnostics_shows_title_and_icon() {
        let expectedTextAndIcon: [MediaCallDiagnostic: (String, CompositeIcon)] = [
            .noSpeakerDevicesAvailable: ("AzureCommunicationUICalling.Diagnostics.Text.UnableToLocateSpeaker",
                                         CompositeIcon.speakerMute),
            .noMicrophoneDevicesAvailable: ("AzureCommunicationUICalling.Diagnostics.Text.UnableToLocateMicrophone",
                                            CompositeIcon.micProhibited),
            .microphoneNotFunctioning: ("AzureCommunicationUICalling.Diagnostics.Text.MicrophoneNotWorking",
                                        CompositeIcon.micProhibited),
            .speakerNotFunctioning: ("AzureCommunicationUICalling.Diagnostics.Text.SpeakerNotWorking",
                                     CompositeIcon.speakerMute),
            .speakerMuted: ("AzureCommunicationUICalling.Diagnostics.Text.SpeakerMuted",
                            CompositeIcon.speakerMute)
        ]

        for diagnostic in MessageBarDiagnosticViewModel.handledMediaDiagnostics {
            let sut = makeSUT(mediaDiagnostic: diagnostic, localizationProvider: localizationProvider)

            guard let (text, icon) = expectedTextAndIcon[diagnostic] else {
                return XCTFail("Value not verified")
            }

            XCTAssertEqual(sut.text, text)
            XCTAssertEqual(sut.icon, icon)
        }
    }

    func test_that_unhadled_media_diagnostics_message_bar_dont_present_any_text() {
        let otherMediaDiagnostics = MediaCallDiagnostic.allCases
            .filter({ !MessageBarDiagnosticViewModel.handledMediaDiagnostics.contains($0) })
        for diagnostic in otherMediaDiagnostics {
            let sut = makeSUT(mediaDiagnostic: diagnostic, localizationProvider: localizationProvider)
            XCTAssertEqual(sut.text, "")
            XCTAssertEqual(sut.icon, nil)
        }
    }
}

extension MessageBarDiagnosticViewModelTests {
    func makeSUT(mediaDiagnostic: MediaCallDiagnostic,
                 localizationProvider: LocalizationProviderMocking? = nil) -> MessageBarDiagnosticViewModel {
        let localizationProviderValue: LocalizationProviderProtocol = localizationProvider ?? LocalizationProvider(logger: LoggerMocking())
        let callDiagnosticsViewModel = CallDiagnosticsViewModel(localizationProvider: localizationProviderValue)
        return MessageBarDiagnosticViewModel(localizationProvider: localizationProviderValue,
                                             callDiagnosticViewModel: callDiagnosticsViewModel,
                                             mediaDiagnostic: mediaDiagnostic)
    }
}
