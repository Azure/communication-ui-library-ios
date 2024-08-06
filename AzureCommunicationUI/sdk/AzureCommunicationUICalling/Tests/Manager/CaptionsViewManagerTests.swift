//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import XCTest
@testable import AzureCommunicationUICalling

class CaptionsViewManagerTests: XCTestCase {
    var captionsManager: CaptionsViewManager!
    var mockCallingSDKWrapper: CallingSDKWrapperMocking!
    var mockStore: StoreFactoryMocking!

    override func setUp() {
        super.setUp()
        mockCallingSDKWrapper = CallingSDKWrapperMocking()
        mockStore = StoreFactoryMocking()
        captionsManager = CaptionsViewManager(store: mockStore.store, callingSDKWrapper: mockCallingSDKWrapper)
    }

    override func tearDown() {
        captionsManager = nil
        mockCallingSDKWrapper = nil
        mockStore = nil
        super.tearDown()
    }

    func testCaptionFinalization() {
        // Given
        let initialCaption = CallCompositeCaptionsData(
            resultType: .partial,
            speakerRawId: "user1",
            speakerName: "John Doe",
            spokenLanguage: "en-us",
            spokenText: "Hello",
            timestamp: Date().addingTimeInterval(-10),
            captionLanguage: "",
            captionText: ""
        )

        let newCaption = CallCompositeCaptionsData(
            resultType: .partial,
            speakerRawId: "Speaker1",
            speakerName: "John Doe",
            spokenLanguage: "en-us",
            spokenText: "Hello",
            timestamp: Date(),
            captionLanguage: "en-us",
            captionText: "Hello"
        )

        // Simulate initial caption
        captionsManager.handleNewData(initialCaption)

        // When
        captionsManager.handleNewData(newCaption)

        // Then
        XCTAssertEqual(captionsManager.captionData.count, 2)
        XCTAssertEqual(captionsManager.captionData.first?.spokenText, "Hello")
    }
    func testHandlingTranslationSettings() {
        // Given
        let caption = CallCompositeCaptionsData(
            resultType: .partial,
            speakerRawId: "Speaker1",
            speakerName: "John Doe",
            spokenLanguage: "en-us",
            spokenText: "Hello",
            timestamp: Date(),
            captionLanguage: "",
            captionText: ""
        )

        // When
        captionsManager.isTranslationEnabled = true
        captionsManager.handleNewData(caption)

        // Then
        XCTAssertTrue(captionsManager.captionData.isEmpty)
    }
}
