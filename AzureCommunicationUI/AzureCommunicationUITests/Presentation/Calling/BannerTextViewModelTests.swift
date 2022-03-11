//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import XCTest
@testable import AzureCommunicationUI

class BannerTextViewModelTests: XCTestCase {

    var bannerTextViewModel: BannerTextViewModel!

    override func setUp() {
        super.setUp()
        bannerTextViewModel = BannerTextViewModel()
    }

    func test_bannerTextViewModel_update_when_withBannerInfoType_then_shouldBePublish() {
        let expectedTitle = BannerInfoType.recordingAndTranscriptionStarted.title
        let expectedBody = BannerInfoType.recordingAndTranscriptionStarted.body
        let expectedLinkDisplay = BannerInfoType.recordingAndTranscriptionStarted.linkDisplay
        let expectedLink = BannerInfoType.recordingAndTranscriptionStarted.link
        let expectation = XCTestExpectation(description: "Should publish bannerTextViewModel")
        let cancel = bannerTextViewModel.objectWillChange
            .sink(receiveValue: {
                expectation.fulfill()
            })

        bannerTextViewModel.update(bannerInfoType: .recordingAndTranscriptionStarted)

        XCTAssertEqual(bannerTextViewModel.title, expectedTitle)
        XCTAssertEqual(bannerTextViewModel.body, expectedBody)
        XCTAssertEqual(bannerTextViewModel.linkDisplay, expectedLinkDisplay)
        XCTAssertEqual(bannerTextViewModel.link, expectedLink)
        cancel.cancel()
        wait(for: [expectation], timeout: 1)
    }

    func test_bannerTextViewModel_update_when_withNil_then_shouldBePublish() {
        let expectation = XCTestExpectation(description: "Should publish bannerTextViewModel")
        let cancel = bannerTextViewModel.objectWillChange
            .sink(receiveValue: {
                expectation.fulfill()
            })

        bannerTextViewModel.update(bannerInfoType: nil)

        XCTAssertTrue(bannerTextViewModel.title.isEmpty)
        XCTAssertTrue(bannerTextViewModel.body.isEmpty)
        XCTAssertTrue(bannerTextViewModel.linkDisplay.isEmpty)
        XCTAssertTrue(bannerTextViewModel.link.isEmpty)
        cancel.cancel()
        wait(for: [expectation], timeout: 1)
    }
}
