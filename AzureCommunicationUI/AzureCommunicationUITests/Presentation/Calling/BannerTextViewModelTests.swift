//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import XCTest
@testable import AzureCommunicationUI

class BannerTextViewModelTests: XCTestCase {
    func test_bannerTextViewModel_update_when_withBannerInfoType_then_shouldBePublish() {
        let expectedTitle = BannerInfoType.recordingAndTranscriptionStarted.title
        let expectedBody = BannerInfoType.recordingAndTranscriptionStarted.body
        let expectedLinkDisplay = BannerInfoType.recordingAndTranscriptionStarted.linkDisplay
        let expectedLink = BannerInfoType.recordingAndTranscriptionStarted.link
        let expectation = XCTestExpectation(description: "Should publish bannerTextViewModel")
        let sut = makeSUT()
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
        let expectation = XCTestExpectation(description: "Should publish bannerTextViewModel")
        let sut = makeSUT()
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

        XCTAssertEqual(sut.accessibilityLabel, sut.title + sut.body + sut.linkDisplay)
    }
}

extension BannerTextViewModelTests {
    func makeSUT(accessibilityProvider: AccessibilityProvider = AppAccessibilityProvider()) -> BannerTextViewModel {
        BannerTextViewModel(accessibilityProvider: accessibilityProvider)
    }
}
