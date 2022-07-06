//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import XCTest
@testable import AzureCommunicationUICalling

class ParticipantCellViewModelTests: XCTestCase {
    var cancellable: CancelBag!

    override func setUp() {
        super.setUp()
        cancellable = CancelBag()
    }

    override func tearDown() {
        super.tearDown()
        cancellable = nil
    }

    func test_participantCellViewModel_init_then_getCorrectRendererViewModel() {
        let expectedParticipantIdentifier = "expectedParticipantIdentifier"
        let expectedVideoStreamId = "expectedVideoStreamId"
        let expectedDisplayName = "expectedDisplayName"
        let expectedIsSpeaking = false
        let expectedIsMuted = true
        let sut = makeSUT(participantIdentifier: expectedParticipantIdentifier,
                          videoStreamId: expectedVideoStreamId,
                          displayName: expectedDisplayName,
                          isSpeaking: expectedIsSpeaking,
                          isMuted: expectedIsMuted)

        XCTAssertEqual(sut.displayName, expectedDisplayName)
        XCTAssertEqual(sut.videoViewModel?.videoStreamId, expectedVideoStreamId)
        XCTAssertEqual(sut.isSpeaking, expectedIsSpeaking)
        XCTAssertEqual(sut.isMuted, expectedIsMuted)

        XCTAssertEqual(sut.participantIdentifier, expectedParticipantIdentifier)
    }

    func test_participantCellViewModel_update_then_updateRendererViewModel() {
        let expectedParticipantIdentifier = "expectedParticipantIdentifier"
        let expectedVideoStreamId = "expectedVideoStreamId"
        let expectedDisplayName = "expectedDisplayName"
        let expectedIsSpeaking = false
        let sut = makeSUT()
        let infoModel = ParticipantInfoModelBuilder.get(participantIdentifier: expectedParticipantIdentifier,
                                                        videoStreamId: expectedVideoStreamId,
                                                        displayName: expectedDisplayName,
                                                        isSpeaking: expectedIsSpeaking)
        sut.update(participantModel: infoModel)

        XCTAssertEqual(sut.displayName, expectedDisplayName)
        XCTAssertEqual(sut.videoViewModel?.videoStreamId, expectedVideoStreamId)
        XCTAssertEqual(sut.isSpeaking, expectedIsSpeaking)
        XCTAssertEqual(sut.participantIdentifier, expectedParticipantIdentifier)

    }

    // Marks: update videoStreamId
    func test_participantCellViewModel_update_when_videoStreamIdSame_then_shouldNotBePublished() {
        let expectation = XCTestExpectation(description: "Video Stream Should Not Be Published")
        expectation.isInverted = true
        let videoStreamId = "expectedVideoStreamId"
        let sut = makeSUT(videoStreamId: videoStreamId)

        sut.$videoViewModel
            .dropFirst()
            .sink { _ in
                XCTFail("Failed with videoStreamId publish")
                expectation.fulfill()
            }.store(in: cancellable)

        let infoModel = ParticipantInfoModelBuilder.get(videoStreamId: videoStreamId)
        sut.update(participantModel: infoModel)

        wait(for: [expectation], timeout: 1)
    }

    func test_participantCellViewModel_update_when_videoStreamIdDifferent_then_shouldBePublished() {
        let videoStreamId = "expectedVideoStreamId"

        let diffVideoStreamId = "diffVideoStreamId"
        let sut = makeSUT(videoStreamId: videoStreamId)
        let expectation = XCTestExpectation(description: "subscription exception")

        sut.$videoViewModel
            .dropFirst()
            .sink { model in
                XCTAssertEqual(diffVideoStreamId, model?.videoStreamId)
                expectation.fulfill()
            }.store(in: cancellable)

        let infoModel = ParticipantInfoModelBuilder.get(videoStreamId: diffVideoStreamId)
        sut.update(participantModel: infoModel)

        wait(for: [expectation], timeout: 1)
    }

    // Marks: update displayName
    func test_participantCellViewModel_update_when_displayNameSame_then_shouldNotBePublished() {
        let expectation = XCTestExpectation(description: "Same Display Name Should Not Be Published")
        expectation.isInverted = true
        let sameDisplayName = "sameDisplayName"
        let sut = makeSUT(displayName: sameDisplayName)

        sut.$displayName
            .dropFirst()
            .sink { _ in
                XCTFail("Failed with videoStreamId publish")
                expectation.fulfill()
            }.store(in: cancellable)

        let infoModel = ParticipantInfoModelBuilder.get(displayName: sameDisplayName)
        sut.update(participantModel: infoModel)

        wait(for: [expectation], timeout: 1)
    }

    func test_participantCellViewModel_update_when_displayNameNotSame_then_shouldBePublished() {
        let diffDisplayName = "diffDisplayName"
        let sut = makeSUT(displayName: "displayName")
        let expectation = XCTestExpectation(description: "subscription expection")

        sut.$displayName
            .dropFirst()
            .sink { value in
                XCTAssertEqual(diffDisplayName, value)
                expectation.fulfill()
            }.store(in: cancellable)

        let infoModel = ParticipantInfoModelBuilder.get(displayName: diffDisplayName)
        sut.update(participantModel: infoModel)

        wait(for: [expectation], timeout: 1)
    }

    // Marks: update isSpeaking
    func test_participantCellViewModel_update_when_isSpeakingSame_then_shouldNotBePublished() {
        let expectation = XCTestExpectation(description: "Speaking Is Same Then Should Not Be Published")
        expectation.isInverted = true
        let isSpeaking = false
        let sut = makeSUT(isSpeaking: isSpeaking)

        sut.$isSpeaking
            .dropFirst()
            .sink { _ in
                XCTFail("Failed with videoStreamId publish")
                expectation.fulfill()
            }.store(in: cancellable)

        let infoModel = ParticipantInfoModelBuilder.get(isSpeaking: isSpeaking)
        sut.update(participantModel: infoModel)

        wait(for: [expectation], timeout: 1)
    }

    func test_participantCellViewModel_update_when_isSpeakingNotSame_then_shouldBePublished() {
        let isSpeaking = false
        let sut = makeSUT(isSpeaking: true)
        let expectation = XCTestExpectation(description: "subscription expection")

        sut.$isSpeaking
            .dropFirst()
            .sink { value in
                XCTAssertEqual(isSpeaking, value)
                expectation.fulfill()
            }.store(in: cancellable)

        let infoModel = ParticipantInfoModelBuilder.get(isSpeaking: isSpeaking)
        sut.update(participantModel: infoModel)

        wait(for: [expectation], timeout: 1)
    }

    // Marks: update isMuted
    func test_participantCellViewModel_update_when_isMutedSame_then_shouldNotBePublished() {
        let expectation = XCTestExpectation(description: "Muting Is Same Then Should Not Be Published")
        expectation.isInverted = true
        let isMuted = false
        let sut = makeSUT(isMuted: isMuted)

        sut.$isMuted
            .dropFirst()
            .sink { _ in
                XCTFail("Failed with videoStreamId publish")
                expectation.fulfill()
            }.store(in: cancellable)

        let infoModel = ParticipantInfoModelBuilder.get(isMuted: isMuted)
        sut.update(participantModel: infoModel)

        wait(for: [expectation], timeout: 1)
    }

    func test_participantCellViewModel_update_when_isMutedNotSame_then_shouldBePublished() {
        let isMuted = false
        let sut = makeSUT(isMuted: true)
        let expectation = XCTestExpectation(description: "subscription expection")

        sut.$isMuted
            .dropFirst()
            .sink { value in
                XCTAssertEqual(isMuted, value)
                expectation.fulfill()
            }.store(in: cancellable)

        let infoModel = ParticipantInfoModelBuilder.get(isMuted: isMuted)
        sut.update(participantModel: infoModel)

        wait(for: [expectation], timeout: 1)
    }

    // MARK: Screen share video stream id
    func test_participantCellViewModel_update_when_hasScreenShareVideoStream_then_updateScreenShareVideoStream() {
        let sut = makeSUT()
        let expectation = XCTestExpectation(description: "subscription exception")
        let expectedVideoStream = "screenShare"
        sut.$videoViewModel
            .dropFirst()
            .sink { model in
                XCTAssertEqual(expectedVideoStream, model?.videoStreamId)
                expectation.fulfill()
            }.store(in: cancellable)

        let infoModel = ParticipantInfoModelBuilder.get(videoStreamId: nil,
                                                        screenShareStreamId: expectedVideoStream)
        sut.update(participantModel: infoModel)

        wait(for: [expectation], timeout: 1)
    }

    func test_participantCellViewModel_update_when_hasBothCameraAndScreenShareVideoStream_then_updateScreenShareVideoStream() {
        let sut = makeSUT()
        let expectation = XCTestExpectation(description: "subscription exception")
        let expectedVideoStream = "screenShare"
        sut.$videoViewModel
            .dropFirst()
            .sink { model in
                XCTAssertEqual(expectedVideoStream, model?.videoStreamId)
                expectation.fulfill()
            }.store(in: cancellable)

        let infoModel = ParticipantInfoModelBuilder.get(videoStreamId: "cameraVideoStreamId",
                                                        screenShareStreamId: expectedVideoStream)
        sut.update(participantModel: infoModel)

        wait(for: [expectation], timeout: 1)
    }

    func test_participantCellViewModel_update_when_hasNoScreenShareVideoStream_then_updateCameraVideoStream() {
        let sut = makeSUT()
        let expectation = XCTestExpectation(description: "subscription exception")
        let expectedVideoStream = "cameraVideoStreamId"
        sut.$videoViewModel
            .dropFirst()
            .sink { model in
                XCTAssertEqual(expectedVideoStream, model?.videoStreamId)
                expectation.fulfill()
            }.store(in: cancellable)

        let infoModel = ParticipantInfoModelBuilder.get(videoStreamId: expectedVideoStream,
                                                        screenShareStreamId: nil)
        sut.update(participantModel: infoModel)

        wait(for: [expectation], timeout: 1)
    }

}

extension ParticipantCellViewModelTests {
    func makeSUT(participantIdentifier: String = "participantIdentifier",
                 videoStreamId: String? = "videoStreamId",
                 screenShareStreamId: String? = nil,
                 displayName: String = "displayName",
                 isSpeaking: Bool = false,
                 isMuted: Bool = true) -> ParticipantGridCellViewModel {
        let infoModel = ParticipantInfoModelBuilder.get(participantIdentifier: participantIdentifier,
                                                        videoStreamId: videoStreamId,
                                                        screenShareStreamId: screenShareStreamId,
                                                        displayName: displayName,
                                                        isSpeaking: isSpeaking,
                                                        isMuted: isMuted)
        return ParticipantGridCellViewModel(localizationProvider: LocalizationProviderMocking(),
                                            accessibilityProvider: AccessibilityProvider(),
                                            participantModel: infoModel)
    }

}
