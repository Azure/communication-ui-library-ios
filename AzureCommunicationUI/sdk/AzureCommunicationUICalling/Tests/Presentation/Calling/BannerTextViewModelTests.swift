//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

@_spi(common) import AzureCommunicationUICommon
import Foundation
import XCTest

@testable import AzureCommunicationUICalling

class BannerTextViewModelTests: XCTestCase {
    private var localizationProvider: LocalizationProviderMocking!

    override func setUp() {
        super.setUp()
        localizationProvider = LocalizationProviderMocking()
    }

    override func tearDown() {
        super.tearDown()
        localizationProvider = nil
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

    func test_bannerTextViewModel_update_when_newInfoTypeSubmitted_then_accessibilityMoveFocusCalled() {
        let expectation = XCTestExpectation(description: "Should move accessibility focus to the first element")
        let accessibilityProvider = AccessibilityProviderMocking()
        accessibilityProvider.moveFocusToFirstElementBlock = {
            expectation.fulfill()
        }
        let sut = makeSUT(accessibilityProvider: accessibilityProvider)

        sut.update(bannerInfoType: .recordingStarted)

        wait(for: [expectation], timeout: 1)
    }

    func test_bannerTextViewModel_update_when_newInfoTypeSubmitted_then_accessibilityLabelUpdated() {
        let accessibilityProvider = AccessibilityProviderMocking()
        let sut = makeSUT(accessibilityProvider: accessibilityProvider)

        sut.update(bannerInfoType: .recordingStarted)

        XCTAssertEqual(sut.accessibilityLabel, "\(sut.title) \(sut.body) \(sut.linkDisplay)")
    }

    func test_bannerTextViewModel_display_complianceBanner_from_LocalizationMocking() {
        let sut = makeSUTLocalizationMocking()
        let expectedTitleKey = "AzureCommunicationUICalling.CallingView.BannerTitle.RecordingAndTranscribingStarted"
        let expectedBodyKey = "AzureCommunicationUICalling.CallingView.BannerBody.Consent"
        let expectedLinkDisplayKey = "AzureCommunicationUICalling.CallingView.BannerLink.PrivacyPolicy"
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
    func makeSUT(accessibilityProvider: AccessibilityProviderProtocol = AccessibilityProvider()) -> BannerTextViewModel {
        BannerTextViewModel(accessibilityProvider: accessibilityProvider,
                            localizationProvider: LocalizationProvider(logger: LoggerMocking()))
    }

    func makeSUTLocalizationMocking() -> BannerTextViewModel {
        return BannerTextViewModel(accessibilityProvider: AccessibilityProvider(),
                                   localizationProvider: localizationProvider)
    }
}
