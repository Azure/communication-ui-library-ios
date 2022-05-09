//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import XCTest
@testable import AzureCommunicationUICalling

class BannerInfoTypeTests: XCTestCase {
    private var localizationProvider: LocalizationProviderProtocol!

    override func setUp() {
        super.setUp()
        localizationProvider = LocalizationProvider(logger: LoggerMocking())
    }

    func test_bannerInfoType_when_recordingAndTranscriptionStarted_then_shouldEqualExpectedString() {
        let bannerInfoType: BannerInfoType = .recordingAndTranscriptionStarted
        let expectedTitle = "Recording and transcription have started."
        let expectedBody = "By joining, you are giving consent for this meeting to be transcribed."
        let expectedLinkDisplay = "Privacy policy"
        let expectedLink = "https://privacy.microsoft.com/privacystatement#mainnoticetoendusersmodule"

        XCTAssertEqual(localizationProvider.getLocalizedString(bannerInfoType.title), expectedTitle)
        XCTAssertEqual(localizationProvider.getLocalizedString(bannerInfoType.body), expectedBody)
        XCTAssertEqual(localizationProvider.getLocalizedString(bannerInfoType.linkDisplay), expectedLinkDisplay)
        XCTAssertEqual(bannerInfoType.link, expectedLink)
    }

    func test_bannerInfoType_when_recordingStarted_then_shouldEqualExpectedString() {
        let bannerInfoType: BannerInfoType = .recordingStarted
        let expectedTitle = "Recording has started."
        let expectedBody = "By joining, you are giving consent for this meeting to be transcribed."
        let expectedLinkDisplay = "Privacy policy"
        let expectedLink = "https://privacy.microsoft.com/privacystatement#mainnoticetoendusersmodule"

        XCTAssertEqual(localizationProvider.getLocalizedString(bannerInfoType.title), expectedTitle)
        XCTAssertEqual(localizationProvider.getLocalizedString(bannerInfoType.body), expectedBody)
        XCTAssertEqual(localizationProvider.getLocalizedString(bannerInfoType.linkDisplay), expectedLinkDisplay)
        XCTAssertEqual(bannerInfoType.link, expectedLink)
    }

    func test_bannerInfoType_when_transcriptionStoppedStillRecording_then_shouldEqualExpectedString() {
        let bannerInfoType: BannerInfoType = .transcriptionStoppedStillRecording
        let expectedTitle = "Transcription has stopped."
        let expectedBody = "You are now only recording this meeting."
        let expectedLinkDisplay = "Privacy policy"
        let expectedLink = "https://privacy.microsoft.com/privacystatement#mainnoticetoendusersmodule"

        XCTAssertEqual(localizationProvider.getLocalizedString(bannerInfoType.title), expectedTitle)
        XCTAssertEqual(localizationProvider.getLocalizedString(bannerInfoType.body), expectedBody)
        XCTAssertEqual(localizationProvider.getLocalizedString(bannerInfoType.linkDisplay), expectedLinkDisplay)
        XCTAssertEqual(bannerInfoType.link, expectedLink)
    }

    func test_bannerInfoType_when_transcriptionStarted_then_shouldEqualExpectedString() {
        let bannerInfoType: BannerInfoType = .transcriptionStarted
        let expectedTitle = "Transcription has started."
        let expectedBody = "By joining, you are giving consent for this meeting to be transcribed."
        let expectedLinkDisplay = "Privacy policy"
        let expectedLink = "https://privacy.microsoft.com/privacystatement#mainnoticetoendusersmodule"

        XCTAssertEqual(localizationProvider.getLocalizedString(bannerInfoType.title), expectedTitle)
        XCTAssertEqual(localizationProvider.getLocalizedString(bannerInfoType.body), expectedBody)
        XCTAssertEqual(localizationProvider.getLocalizedString(bannerInfoType.linkDisplay), expectedLinkDisplay)
        XCTAssertEqual(bannerInfoType.link, expectedLink)
    }

    func test_bannerInfoType_when_transcriptionStoppedAndSaved_then_shouldEqualExpectedString() {
        let bannerInfoType: BannerInfoType = .transcriptionStoppedAndSaved
        let expectedTitle = "Transcription is being saved."
        let expectedBody = "Transcription has stopped."
        let expectedLinkDisplay = "Learn more"
        let expectedLink = "https://support.microsoft.com/office/record-a-meeting-in-teams-34dfbe7f-b07d-4a27-b4c6-de62f1348c24"

        XCTAssertEqual(localizationProvider.getLocalizedString(bannerInfoType.title), expectedTitle)
        XCTAssertEqual(localizationProvider.getLocalizedString(bannerInfoType.body), expectedBody)
        XCTAssertEqual(localizationProvider.getLocalizedString(bannerInfoType.linkDisplay), expectedLinkDisplay)
        XCTAssertEqual(bannerInfoType.link, expectedLink)
    }

    func test_bannerInfoType_when_recordingStoppedStillTranscribing_then_shouldEqualExpectedString() {
        let bannerInfoType: BannerInfoType = .recordingStoppedStillTranscribing
        let expectedTitle = "Recording has stopped."
        let expectedBody = "You are now only transcribing this meeting."
        let expectedLinkDisplay = "Privacy policy"
        let expectedLink = "https://privacy.microsoft.com/privacystatement#mainnoticetoendusersmodule"

        XCTAssertEqual(localizationProvider.getLocalizedString(bannerInfoType.title), expectedTitle)
        XCTAssertEqual(localizationProvider.getLocalizedString(bannerInfoType.body), expectedBody)
        XCTAssertEqual(localizationProvider.getLocalizedString(bannerInfoType.linkDisplay), expectedLinkDisplay)
        XCTAssertEqual(bannerInfoType.link, expectedLink)
    }

    func test_bannerInfoType_when_recordingStopped_then_shouldEqualExpectedString() {
        let bannerInfoType: BannerInfoType = .recordingStopped
        let expectedTitle = "Recording is being saved."
        let expectedBody = "Recording has stopped."
        let expectedLinkDisplay = "Learn more"
        let expectedLink = "https://support.microsoft.com/office/record-a-meeting-in-teams-34dfbe7f-b07d-4a27-b4c6-de62f1348c24"

        XCTAssertEqual(localizationProvider.getLocalizedString(bannerInfoType.title), expectedTitle)
        XCTAssertEqual(localizationProvider.getLocalizedString(bannerInfoType.body), expectedBody)
        XCTAssertEqual(localizationProvider.getLocalizedString(bannerInfoType.linkDisplay), expectedLinkDisplay)
        XCTAssertEqual(bannerInfoType.link, expectedLink)
    }

    func test_bannerInfoType_when_recordingAndTranscriptionStopped_then_shouldEqualExpectedString() {
        let bannerInfoType: BannerInfoType = .recordingAndTranscriptionStopped
        let expectedTitle = "Recording and transcription are being saved."
        let expectedBody = "Recording and transcription have stopped."
        let expectedLinkDisplay = "Learn more"
        let expectedLink = "https://support.microsoft.com/office/record-a-meeting-in-teams-34dfbe7f-b07d-4a27-b4c6-de62f1348c24"

        XCTAssertEqual(localizationProvider.getLocalizedString(bannerInfoType.title), expectedTitle)
        XCTAssertEqual(localizationProvider.getLocalizedString(bannerInfoType.body), expectedBody)
        XCTAssertEqual(localizationProvider.getLocalizedString(bannerInfoType.linkDisplay), expectedLinkDisplay)
        XCTAssertEqual(bannerInfoType.link, expectedLink)
    }
}
