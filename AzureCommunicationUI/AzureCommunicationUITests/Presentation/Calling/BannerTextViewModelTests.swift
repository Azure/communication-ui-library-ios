//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import XCTest
@testable import AzureCommunicationUI

class BannerTextViewModelTests: XCTestCase {

    private var localizationProvider: LocalizationProviderMocking!

    override func setUp() {
        super.setUp()
        localizationProvider = LocalizationProviderMocking()
    }

    func test_bannerTextViewModel_update_when_withBannerInfoType_then_shouldBePublish() {
        let sut = makeSUT()
        let expectedTitle = "Recording and transcription have started."
        let expectedBody = "By joining, you are giving consent for this meeting to be transcribed."
        let expectedLinkDisplay = "Privacy policy"
        let expectedLink = "https://privacy.microsoft.com/privacystatement#mainnoticetoendusersmodule"
        let expectation = XCTestExpectation(description: "Should publish bannerTextViewModel")
        let cancel = sut.objectWillChange
            .sink(receiveValue: {
                expectation.fulfill()
            })

        sut.update(bannerInfoType: .recordingAndTranscriptionStarted)

        XCTAssertEqual(sut.title, expectedTitle)
        XCTAssertEqual(sut.body, expectedBody)
        XCTAssertEqual(sut.linkDisplay, expectedLinkDisplay)
        XCTAssertEqual(sut.link, expectedLink)
        cancel.cancel()
        wait(for: [expectation], timeout: 1)
    }

    func test_bannerTextViewModel_update_when_withNil_then_shouldBePublish() {
        let sut = makeSUT()
        let expectation = XCTestExpectation(description: "Should publish bannerTextViewModel")
        let cancel = sut.objectWillChange
            .sink(receiveValue: {
                expectation.fulfill()
            })

        sut.update(bannerInfoType: nil)

        XCTAssertTrue(sut.title.isEmpty)
        XCTAssertTrue(sut.body.isEmpty)
        XCTAssertTrue(sut.linkDisplay.isEmpty)
        XCTAssertTrue(sut.link.isEmpty)
        cancel.cancel()
        wait(for: [expectation], timeout: 1)
    }

    func test_bannerTextViewModel_display_complianceBanner_from_LocalizationMocking() {
        let sut = makeSUTLocalizationMocking()
        let expectedTitleKey = "AzureCommunicationUI.CallingView.BannerTitle.RecordingAndTranscribingStarted"
        let expectedBodyKey = "AzureCommunicationUI.CallingView.BannerBody.Consent"
        let expectedLinkDisplayKey = "AzureCommunicationUI.CallingView.BannerLink.PrivacyPolicy"
        let expectedLinkString = "https://privacy.microsoft.com/privacystatement#mainnoticetoendusersmodule"
        let expectation = XCTestExpectation(description: "Should publish bannerTextViewModel")
        let cancel = sut.objectWillChange
            .sink(receiveValue: {
                expectation.fulfill()
            })

        sut.update(bannerInfoType: .recordingAndTranscriptionStarted)

        XCTAssertEqual(sut.title, expectedTitleKey)
        XCTAssertEqual(sut.body, expectedBodyKey)
        XCTAssertEqual(sut.linkDisplay, expectedLinkDisplayKey)
        XCTAssertEqual(sut.link, expectedLinkString)
        XCTAssertTrue(localizationProvider.isGetLocalizedStringCalled)
        cancel.cancel()
        wait(for: [expectation], timeout: 1)
    }
}

extension BannerTextViewModelTests {
    func makeSUT() -> BannerTextViewModel {
        return BannerTextViewModel(localizationProvider: AppLocalizationProvider(logger: LoggerMocking()))
    }

    func makeSUTLocalizationMocking() -> BannerTextViewModel {
        return BannerTextViewModel(localizationProvider: localizationProvider)
    }
}
