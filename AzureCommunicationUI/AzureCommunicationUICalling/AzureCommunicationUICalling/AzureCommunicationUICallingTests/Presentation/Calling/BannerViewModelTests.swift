//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import XCTest
@testable import AzureCommunicationUICalling

class BannerViewModelTests: XCTestCase {

    let cancellable = CancelBag()

    func test_bannerViewModel_isBannerDisplayedPublished_when_displayBannerWithRecordingOnAndTranscriptionOn_then_shouldBecomeTrueAndPublish() {
        let bannerViewModel = makeSut()
        let expectation = XCTestExpectation(description: "Should publish isBannerDisplayed")
        bannerViewModel.$isBannerDisplayed
            .dropFirst()
            .sink(receiveValue: { isBannerDisplayed in
                XCTAssertTrue(isBannerDisplayed)
                expectation.fulfill()
            }).store(in: cancellable)

        let callingState = CallingState(status: .connected, isRecordingActive: true, isTranscriptionActive: true)
        bannerViewModel.update(callingState: callingState)
        wait(for: [expectation], timeout: 1)
    }

    func test_bannerViewModel_update_when_withRecordingActiveTrueAndTranscriptionActiveTrue_shouldUpdateRecordingAndTranscriptionStartedgBanner() {
        let parameters: [(BannerViewModel.FeatureStatus, BannerViewModel.FeatureStatus)] = [
            (.on, .on),
            (.on, .off),
            (.on, .stopped),
            (.off, .on),
            (.off, .off),
            (.off, .stopped),
            (.stopped, .on),
            (.stopped, .off),
            (.stopped, .stopped)
        ]
        for (initialRecordingState, initialTranscriptionState) in parameters {
            let isRecordingActiveToUpdate = true
            let isTranscriptionActiveToUpdate = true
            let expectedType = BannerInfoType.recordingAndTranscriptionStarted

            let callStatesArr = createCallStates(recordingState: initialRecordingState,
                                                 transcriptionState: initialTranscriptionState)
            let mockingBannerViewModel = BannerTextViewModelMocking()
            let bannerViewModel = makeSut(callingStateArray: callStatesArr,
                                          mockingBannerViewModel: mockingBannerViewModel)

            let expectationClosure: ((BannerInfoType?) -> Void) = { bannerInfoType in
                XCTAssertEqual(bannerInfoType, expectedType)
            }
            mockingBannerViewModel.updateBannerInfoType = expectationClosure
            let callingStateToUpdate = makeCallingState(isRecordingActiveToUpdate, isTranscriptionActiveToUpdate)
            bannerViewModel.update(callingState: callingStateToUpdate)
        }
    }

    func test_bannerViewModel_update_when_withRecordingActiveTrueAndTranscriptionActiveFalse_shouldUpdateRecordingStartedBanner() {
        let parameters: [(BannerViewModel.FeatureStatus, BannerViewModel.FeatureStatus)] = [
            (.on, .off),
            (.off, .off),
            (.stopped, .off),
            (.stopped, .stopped)
        ]
        for (initialRecordingState, initialTranscriptionState) in parameters {
            let isRecordingActiveToUpdate = true
            let isTranscriptionActiveToUpdate = false
            let expectedType = BannerInfoType.recordingStarted

            let callStatesArr = createCallStates(recordingState: initialRecordingState,
                                                 transcriptionState: initialTranscriptionState)
            let mockingBannerViewModel = BannerTextViewModelMocking()
            let bannerViewModel = makeSut(callingStateArray: callStatesArr,
                                          mockingBannerViewModel: mockingBannerViewModel)

            let expectationClosure: ((BannerInfoType?) -> Void) = { bannerInfoType in
                XCTAssertEqual(bannerInfoType, expectedType)
            }
            mockingBannerViewModel.updateBannerInfoType = expectationClosure
            let callingStateToUpdate = makeCallingState(isRecordingActiveToUpdate, isTranscriptionActiveToUpdate)
            bannerViewModel.update(callingState: callingStateToUpdate)
        }
    }

    func test_bannerViewModel_update_when_withRecordingActiveTrueAndTranscriptionActiveFalse_shouldUpdateTranscriptionStoppedStillRecordingBanner() {
        let parameters: [(BannerViewModel.FeatureStatus, BannerViewModel.FeatureStatus)] = [
            (.on, .on),
            (.on, .stopped),
            (.off, .on),
            (.off, .stopped),
            (.stopped, .on)
        ]
        for (initialRecordingState, initialTranscriptionState) in parameters {
            let isRecordingActiveToUpdate = true
            let isTranscriptionActiveToUpdate = false
            let expectedType = BannerInfoType.transcriptionStoppedStillRecording

            let callStatesArr = createCallStates(recordingState: initialRecordingState,
                                                 transcriptionState: initialTranscriptionState)
            let mockingBannerViewModel = BannerTextViewModelMocking()
            let bannerViewModel = makeSut(callingStateArray: callStatesArr,
                                          mockingBannerViewModel: mockingBannerViewModel)

            let expectationClosure: ((BannerInfoType?) -> Void) = { bannerInfoType in
                XCTAssertEqual(bannerInfoType, expectedType)
            }
            mockingBannerViewModel.updateBannerInfoType = expectationClosure
            let callingStateToUpdate = makeCallingState(isRecordingActiveToUpdate, isTranscriptionActiveToUpdate)
            bannerViewModel.update(callingState: callingStateToUpdate)
        }
    }

    func test_bannerViewModel_update_when_withRecordingActiveFalseAndTranscriptionActiveTrue_shouldUpdateTranscriptionStartedBanner() {
        let parameters: [(BannerViewModel.FeatureStatus, BannerViewModel.FeatureStatus)] = [
            (.off, .on),
            (.off, .off),
            (.off, .stopped),
            (.stopped, .stopped)
        ]
        for (initialRecordingState, initialTranscriptionState) in parameters {
            let isRecordingActiveToUpdate = false
            let isTranscriptionActiveToUpdate = true
            let expectedType = BannerInfoType.transcriptionStarted

            let callStatesArr = createCallStates(recordingState: initialRecordingState,
                                                 transcriptionState: initialTranscriptionState)
            let mockingBannerViewModel = BannerTextViewModelMocking()
            let bannerViewModel = makeSut(callingStateArray: callStatesArr,
                                          mockingBannerViewModel: mockingBannerViewModel)

            let expectationClosure: ((BannerInfoType?) -> Void) = { bannerInfoType in
                XCTAssertEqual(bannerInfoType, expectedType)
            }
            mockingBannerViewModel.updateBannerInfoType = expectationClosure
            let callingStateToUpdate = makeCallingState(isRecordingActiveToUpdate, isTranscriptionActiveToUpdate)
            bannerViewModel.update(callingState: callingStateToUpdate)
        }
    }

    func test_bannerViewModel_update_when_withRecordingActiveFalseAndTranscriptionActiveFalse_shouldNotUpdateBanner() {
        let parameters: [(BannerViewModel.FeatureStatus, BannerViewModel.FeatureStatus)] = [
            (.off, .off),
            (.stopped, .stopped)
        ]
        for (initialRecordingState, initialTranscriptionState) in parameters {
            let isRecordingActiveToUpdate = false
            let isTranscriptionActiveToUpdate = false
            let expectedType: BannerInfoType? = nil

            let callStatesArr = createCallStates(recordingState: initialRecordingState,
                                                 transcriptionState: initialTranscriptionState)
            let mockingBannerViewModel = BannerTextViewModelMocking()
            let bannerViewModel = makeSut(callingStateArray: callStatesArr,
                                          mockingBannerViewModel: mockingBannerViewModel)

            let expectationClosure: ((BannerInfoType?) -> Void) = { bannerInfoType in
                XCTAssertEqual(bannerInfoType, expectedType)
            }
            mockingBannerViewModel.updateBannerInfoType = expectationClosure
            let callingStateToUpdate = makeCallingState(isRecordingActiveToUpdate, isTranscriptionActiveToUpdate)
            bannerViewModel.update(callingState: callingStateToUpdate)
        }
    }

    func test_bannerViewModel_update_when_withRecordingActiveFalseAndTranscriptionActiveFalse_shouldUpdateTranscriptionStoppedAndSavedBanner() {
        let parameters: [(BannerViewModel.FeatureStatus, BannerViewModel.FeatureStatus)] = [
            (.off, .on),
            (.off, .stopped)
        ]
        for (initialRecordingState, initialTranscriptionState) in parameters {
            let isRecordingActiveToUpdate = false
            let isTranscriptionActiveToUpdate = false
            let expectedType = BannerInfoType.transcriptionStoppedAndSaved

            let callStatesArr = createCallStates(recordingState: initialRecordingState,
                                                 transcriptionState: initialTranscriptionState)
            let mockingBannerViewModel = BannerTextViewModelMocking()
            let bannerViewModel = makeSut(callingStateArray: callStatesArr,
                                          mockingBannerViewModel: mockingBannerViewModel)

            let expectationClosure: ((BannerInfoType?) -> Void) = { bannerInfoType in
                XCTAssertEqual(bannerInfoType, expectedType)
            }
            mockingBannerViewModel.updateBannerInfoType = expectationClosure
            let callingStateToUpdate = makeCallingState(isRecordingActiveToUpdate, isTranscriptionActiveToUpdate)
            bannerViewModel.update(callingState: callingStateToUpdate)
        }
    }

    func test_bannerViewModel_update_when_withRecordingActiveFalseAndTranscriptionActiveTrue_shouldUpdateRecordingStoppedStillTranscribingBanner() {
        let parameters: [(BannerViewModel.FeatureStatus, BannerViewModel.FeatureStatus)] = [
            (.on, .on),
            (.on, .off),
            (.on, .stopped),
            (.stopped, .on),
            (.stopped, .off)
        ]
        for (initialRecordingState, initialTranscriptionState) in parameters {
            let isRecordingActiveToUpdate = false
            let isTranscriptionActiveToUpdate = true
            let expectedType = BannerInfoType.recordingStoppedStillTranscribing

            let callStatesArr = createCallStates(recordingState: initialRecordingState,
                                                 transcriptionState: initialTranscriptionState)
            let mockingBannerViewModel = BannerTextViewModelMocking()
            let bannerViewModel = makeSut(callingStateArray: callStatesArr,
                                          mockingBannerViewModel: mockingBannerViewModel)

            let expectationClosure: ((BannerInfoType?) -> Void) = { bannerInfoType in
                XCTAssertEqual(bannerInfoType, expectedType)
            }
            mockingBannerViewModel.updateBannerInfoType = expectationClosure
            let callingStateToUpdate = makeCallingState(isRecordingActiveToUpdate, isTranscriptionActiveToUpdate)
            bannerViewModel.update(callingState: callingStateToUpdate)
        }
    }

    func test_bannerViewModel_update_when_withRecordingActiveFalseAndTranscriptionActiveFalse_shouldUpdateRecordingStoppedBanner() {
        let parameters: [(BannerViewModel.FeatureStatus, BannerViewModel.FeatureStatus)] = [
            (.on, .off),
            (.stopped, .off)
        ]
        for (initialRecordingState, initialTranscriptionState) in parameters {
            let isRecordingActiveToUpdate = false
            let isTranscriptionActiveToUpdate = false
            let expectedType = BannerInfoType.recordingStopped

            let callStatesArr = createCallStates(recordingState: initialRecordingState,
                                                 transcriptionState: initialTranscriptionState)
            let mockingBannerViewModel = BannerTextViewModelMocking()
            let bannerViewModel = makeSut(callingStateArray: callStatesArr,
                                          mockingBannerViewModel: mockingBannerViewModel)

            let expectationClosure: ((BannerInfoType?) -> Void) = { bannerInfoType in
                XCTAssertEqual(bannerInfoType, expectedType)
            }
            mockingBannerViewModel.updateBannerInfoType = expectationClosure
            let callingStateToUpdate = makeCallingState(isRecordingActiveToUpdate, isTranscriptionActiveToUpdate)
            bannerViewModel.update(callingState: callingStateToUpdate)
        }
    }

    func test_bannerViewModel_update_when_withRecordingActiveFalseAndTranscriptionActiveFalse_shouldUpdateRecordingAndTranscriptionStoppedBanner() {
        let parameters: [(BannerViewModel.FeatureStatus, BannerViewModel.FeatureStatus)] = [
            (.on, .on),
            (.on, .stopped),
            (.stopped, .on),
            (.stopped, .stopped)
        ]
        for (initialRecordingState, initialTranscriptionState) in parameters {
            let isRecordingActiveToUpdate = false
            let isTranscriptionActiveToUpdate = false
            let expectedType = BannerInfoType.recordingAndTranscriptionStopped

            let callStatesArr = createCallStates(recordingState: initialRecordingState,
                                                 transcriptionState: initialTranscriptionState)
            let mockingBannerViewModel = BannerTextViewModelMocking()
            let bannerViewModel = makeSut(callingStateArray: callStatesArr,
                                          mockingBannerViewModel: mockingBannerViewModel)

            let expectationClosure: ((BannerInfoType?) -> Void) = { bannerInfoType in
                XCTAssertEqual(bannerInfoType, expectedType)
            }
            mockingBannerViewModel.updateBannerInfoType = expectationClosure
            let callingStateToUpdate = makeCallingState(isRecordingActiveToUpdate, isTranscriptionActiveToUpdate)
            bannerViewModel.update(callingState: callingStateToUpdate)
        }
    }
}

extension BannerViewModelTests {

    func makeSut() -> BannerViewModel {
        let storeFactory = StoreFactoryMocking()
        let factoryMocking = CompositeViewModelFactoryMocking(logger: LoggerMocking(), store: storeFactory.store)
        return BannerViewModel(compositeViewModelFactory: factoryMocking)
    }

    func makeSut(callingStateArray: [CallingState],
                 mockingBannerViewModel: BannerTextViewModelMocking) -> BannerViewModel {
        let storeFactory = StoreFactoryMocking()
        let factoryMocking = CompositeViewModelFactoryMocking(logger: LoggerMocking(),
                                                              store: storeFactory.store)
        factoryMocking.bannerTextViewModel = mockingBannerViewModel
        let sut = BannerViewModel(compositeViewModelFactory: factoryMocking)
        for callState in callingStateArray {
            sut.update(callingState: callState)
        }
        return sut
    }

    func createCallStates(recordingState: BannerViewModel.FeatureStatus,
                          transcriptionState: BannerViewModel.FeatureStatus) -> [CallingState] {
        switch (recordingState, transcriptionState) {
        case (.on, .on):
            return [makeCallingState(true, true)]
        case (.on, .off):
            return [makeCallingState(true, false)]
        case (.on, .stopped):
            return [makeCallingState(true, true), makeCallingState(true, false)]
        case (.off, .on):
            return [makeCallingState(false, true)]
        case (.off, .off):
            return []
        case (.off, .stopped):
            return [makeCallingState(false, true), makeCallingState(false, false)]
        case (.stopped, .on):
            return [makeCallingState(true, true), makeCallingState(false, true)]
        case (.stopped, .off):
            return [makeCallingState(true, false), makeCallingState(false, false)]
        case (.stopped, .stopped):
            return [makeCallingState(true, true), makeCallingState(false, false)]
        }
    }

    func makeCallingState(_ recording: Bool, _ transcription: Bool) -> CallingState {
        return CallingState(status: .connected,
                            isRecordingActive: recording,
                            isTranscriptionActive: transcription)
    }
}
