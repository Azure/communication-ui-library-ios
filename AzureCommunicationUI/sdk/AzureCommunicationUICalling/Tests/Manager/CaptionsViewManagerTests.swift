//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import XCTest
@testable import AzureCommunicationUICalling

class CaptionsViewManagerTests: XCTestCase {
    var captionsManager: CaptionsAndRttViewManager!
    var mockCallingSDKWrapper: CallingSDKWrapperMocking!
    var mockStore: StoreFactoryMocking!

    override func setUp() {
        super.setUp()
        mockCallingSDKWrapper = CallingSDKWrapperMocking()
        mockStore = StoreFactoryMocking()
        captionsManager = CaptionsAndRttViewManager(store: mockStore.store, callingSDKWrapper: mockCallingSDKWrapper)
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
            timestamp: Date(),
            captionLanguage: "",
            captionText: "",
            displayText: "Hello"
        )

        let newCaption = CallCompositeCaptionsData(
            resultType: .partial,
            speakerRawId: "Speaker1",
            speakerName: "John Doe",
            spokenLanguage: "en-us",
            spokenText: "Hello",
            timestamp: Date(),
            captionLanguage: "en-us",
            captionText: "Hello",
            displayText: "Hello"
        )

        // Simulate initial caption
        captionsManager.handleNewData(initialCaption.toDisplayData())

        // When
        captionsManager.handleNewData(newCaption.toDisplayData())

        // Then
        XCTAssertEqual(captionsManager.captionsRttData.count, 2)
        XCTAssertEqual(captionsManager.captionsRttData.first?.spokenText, "Hello")
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
            captionText: "",
            displayText: "Hello"
        )

        // When
        captionsManager.isTranslationEnabled = true
        captionsManager.handleNewData(caption.toDisplayData())

        // Then
        XCTAssertTrue(captionsManager.captionsRttData.isEmpty)
    }
}
