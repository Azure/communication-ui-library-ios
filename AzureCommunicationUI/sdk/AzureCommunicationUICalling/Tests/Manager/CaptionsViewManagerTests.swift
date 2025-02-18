//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import XCTest
@testable import AzureCommunicationUICalling

class CaptionsViewManagerTests: XCTestCase {
    var captionsManager: CaptionsRttViewManager!
    var mockCallingSDKWrapper: CallingSDKWrapperMocking!
    var mockStore: StoreFactoryMocking!

    override func setUp() {
        super.setUp()
        mockCallingSDKWrapper = CallingSDKWrapperMocking()
        mockStore = StoreFactoryMocking()
        captionsManager = CaptionsRttViewManager(store: mockStore.store, callingSDKWrapper: mockCallingSDKWrapper)
    }

    override func tearDown() {
        captionsManager = nil
        mockCallingSDKWrapper = nil
        mockStore = nil
        super.tearDown()
    }

    func test_captionsData_when_newSpeakerStartsSpeaking_then_captionCountIncreases() {
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

    func test_captionsData_when_sameSpeakerContinues_then_lastCaptionUpdated() {
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
            speakerRawId: "user1",
            speakerName: "John Doe",
            spokenLanguage: "en-us",
            spokenText: "Helloo",
            timestamp: Date(),
            captionLanguage: "en-us",
            captionText: "Helloo",
            displayText: "Helloo"
        )

        // Simulate initial caption
        captionsManager.handleNewData(initialCaption.toDisplayData())

        // When
        captionsManager.handleNewData(newCaption.toDisplayData())

        // Then
        XCTAssertEqual(captionsManager.captionsRttData.count, 1)
        XCTAssertEqual(captionsManager.captionsRttData.first?.spokenText, "Helloo")
    }

    func test_rttData_when_newMessageReceived_then_rttCountIncreases() {
        // Given
        let initialRtt = CallCompositeRttData(
            resultType: .partial,
            senderRawId: "sender1",
            senderName: "Joe",
            sequenceId: 0,
            text: "Hello",
            localCreatedTime: Date(),
            localUpdatedTime: Date(),
            isLocal: false
        )

        let newRtt = CallCompositeRttData(
            resultType: .partial,
            senderRawId: "sender1",
            senderName: "Joe",
            sequenceId: 0,
            text: "Helloo",
            localCreatedTime: Date(),
            localUpdatedTime: Date(),
            isLocal: false
        )

        // Simulate initial caption
        captionsManager.handleNewData(initialRtt.toDisplayData())

        // When
        captionsManager.handleNewData(newRtt.toDisplayData())

        // Then
        XCTAssertEqual(captionsManager.captionsRttData.count, 1)
        XCTAssertEqual(captionsManager.captionsRttData.last?.text, "Helloo")
    }

    func test_rttData_when_sameSenderUpdatesMessage_then_lastRttUpdated() {
        // Given
        let initialRtt = CallCompositeRttData(
            resultType: .partial,
            senderRawId: "sender1",
            senderName: "Joe",
            sequenceId: 0,
            text: "Hello",
            localCreatedTime: Date(),
            localUpdatedTime: Date(),
            isLocal: false
        )

        let newRtt = CallCompositeRttData(
            resultType: .final,
            senderRawId: "sender1",
            senderName: "Joe",
            sequenceId: 0,
            text: "Helloo",
            localCreatedTime: Date(),
            localUpdatedTime: Date(),
            isLocal: false
        )

        let newRtt1 = CallCompositeRttData(
            resultType: .partial,
            senderRawId: "sender1",
            senderName: "Joe",
            sequenceId: 0,
            text: "Helloo",
            localCreatedTime: Date(),
            localUpdatedTime: Date(),
            isLocal: false
        )

        // Simulate initial caption
        captionsManager.handleNewData(initialRtt.toDisplayData())

        // When
        captionsManager.handleNewData(newRtt.toDisplayData())
        captionsManager.handleNewData(newRtt1.toDisplayData())

        // Then
        XCTAssertEqual(captionsManager.captionsRttData.count, 2)
        XCTAssertEqual(captionsManager.captionsRttData.last?.text, "Helloo")
    }

    func test_translationSettings_when_enabled_then_captionsNotDisplayed() {
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
