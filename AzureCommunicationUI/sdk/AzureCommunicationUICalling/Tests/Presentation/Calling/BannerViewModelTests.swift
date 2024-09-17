//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import XCTest
import AzureCommunicationCommon
@testable import AzureCommunicationUICalling

class BannerViewModelTests: XCTestCase {
    var cancellable: CancelBag!
    var storeFactory: StoreFactoryMocking!
    var factoryMocking: CompositeViewModelFactoryMocking!

    override func setUp() {
        super.setUp()
        cancellable = CancelBag()
        storeFactory = StoreFactoryMocking()
        factoryMocking = CompositeViewModelFactoryMocking(logger: LoggerMocking(),
                                                          store: storeFactory.store,
                                                          avatarManager: AvatarViewManagerMocking(
                                                            store: storeFactory.store,
                                                            localParticipantId: createCommunicationIdentifier(fromRawId: ""),
                                                            localParticipantViewData: nil),
                                                          updatableOptionsManager: UpdatableOptionsManager(store: storeFactory.store, setupScreenOptions: nil, callScreenOptions: nil))
    }

    override func tearDown() {
        super.tearDown()
        cancellable = nil
        storeFactory = nil
        factoryMocking = nil
    }

    func test_bannerViewModel_isBannerDisplayedPublished_when_displayBannerWithRecordingOnAndTranscriptionOn_then_shouldBecomeTrueAndPublish() {
        let bannerViewModel = makeSUT()
        let expectation = XCTestExpectation(description: "Should publish isBannerDisplayed")
        bannerViewModel.$isBannerDisplayed
            .dropFirst()
            .sink(receiveValue: { isBannerDisplayed in
                XCTAssertTrue(isBannerDisplayed)
                expectation.fulfill()
            }).store(in: cancellable)

        let callingState = makeCallingState(.on, .on)
        bannerViewModel.update(callingState: callingState, visibilityState: VisibilityState.init(currentStatus: .visible))
        wait(for: [expectation], timeout: 1)
    }

    func test_bannerViewModel_isBannerDisplayedPublished_when_visibilityInPip_then_shouldBecomeFalseAndPublish() {
        let bannerViewModel = makeSUT()
        let expectation = XCTestExpectation(description: "Should publish isBannerDisplayed")
        bannerViewModel.$isBannerDisplayed
            .dropFirst()
            .sink(receiveValue: { isBannerDisplayed in
                if !isBannerDisplayed {
                    expectation.fulfill()
                }
            }).store(in: cancellable)

        let callingState = makeCallingState(.on, .on)
        bannerViewModel.update(callingState: callingState, visibilityState: VisibilityState.init(currentStatus: .visible))

        bannerViewModel.update(callingState: callingState, visibilityState: VisibilityState.init(currentStatus: .pipModeEntered))

        wait(for: [expectation], timeout: 1)
    }

    func test_bannerViewModel_update_shouldUpdateRecordingAndTranscriptionStartedgBanner() {
        let parameters: [((RecordingStatus, RecordingStatus), BannerInfoType?)] = [
            ((.on, .on), BannerInfoType.recordingAndTranscriptionStarted),
            ((.on, .off), BannerInfoType.recordingStarted),
            ((.on, .stopped), BannerInfoType.transcriptionStoppedStillRecording),
            ((.off, .on), BannerInfoType.transcriptionStarted),
            ((.off, .off), nil),
            ((.off, .stopped), BannerInfoType.transcriptionStoppedAndSaved),
            ((.stopped, .on), BannerInfoType.recordingStoppedStillTranscribing),
            ((.stopped, .off), BannerInfoType.recordingStopped),
            ((.stopped, .stopped), BannerInfoType.recordingAndTranscriptionStopped)
        ]
        for (stateTuple, expectedType) in parameters {
            let recordingState = stateTuple.0
            let transcriptionState = stateTuple.1
            let mockingBannerViewModel = BannerTextViewModelMocking()
            factoryMocking.bannerTextViewModel = mockingBannerViewModel
            let callingState = makeCallingState()
            let bannerViewModel = makeSut(callingState: callingState, visibilitySataus: .visible)

            let expectationClosure: ((BannerInfoType?) -> Void) = { bannerInfoType in
                XCTAssertEqual(bannerInfoType, expectedType)
            }
            mockingBannerViewModel.updateBannerInfoType = expectationClosure
            let callingStateToUpdate = makeCallingState(recordingState, transcriptionState)

            bannerViewModel.update(callingState: callingStateToUpdate, visibilityState: VisibilityState.init(currentStatus: .visible))
        }
    }
}

extension BannerViewModelTests {

    func makeSUT() -> BannerViewModel {
        return BannerViewModel(compositeViewModelFactory: factoryMocking) { _ in
        }
    }

    func makeSut(callingState: CallingState, visibilitySataus: VisibilityStatus = .visible) -> BannerViewModel {
        let sut = makeSUT()
        sut.update(callingState: callingState, visibilityState: VisibilityState.init(currentStatus: visibilitySataus))
        return sut
    }

    func makeCallingState(_ recordingStatus: RecordingStatus, _ transcriptionStatus: RecordingStatus) -> CallingState {
        return CallingState(status: .connected,
                            isRecordingActive: true,
                            isTranscriptionActive: true,
                            recordingStatus: recordingStatus,
                            transcriptionStatus: transcriptionStatus)
    }

    func makeCallingState() -> CallingState {
        return CallingState(status: .connected)
    }
}
