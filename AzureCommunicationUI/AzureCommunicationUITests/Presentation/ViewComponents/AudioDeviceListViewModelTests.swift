//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//
import Foundation
import XCTest
@testable import AzureCommunicationUI

class AudioDeviceListViewModelTests: XCTestCase {
    var storeFactory: StoreFactoryMocking!
    var cancellable: CancelBag!
    var audioDeviceListViewModel: AudioDeviceListViewModel!

    override func setUp() {
        storeFactory = StoreFactoryMocking()
        cancellable = CancelBag()

        func dispatch(action: Action) {
            storeFactory.store.dispatch(action: action)
        }
        audioDeviceListViewModel = AudioDeviceListViewModel(dispatchAction: dispatch,
                                                            localUserState: LocalUserState())
    }

    func test_audioDeviceListViewModel_update_when_audioDeviceListFirstInitialized_then_shouldPopulateAudioDeviceList() {
        XCTAssertEqual(audioDeviceListViewModel.audioDeviceStatus, .receiverSelected)
        XCTAssertTrue(audioDeviceListViewModel.audioDeviceList.isEmpty)
        audioDeviceListViewModel.update(audioDeviceStatus: .receiverSelected)
        XCTAssertEqual(audioDeviceListViewModel.audioDeviceStatus, .receiverSelected)
        XCTAssertFalse(audioDeviceListViewModel.audioDeviceList.isEmpty)
    }

    func test_audioDeviceListViewModel_update_when_audioDeviceStatusUpdatedToReceiverSelected_then_shouldBePublished() {
        let expectation = XCTestExpectation(description: "Should publish audioDeviceStatus")
        audioDeviceListViewModel.$audioDeviceStatus
            .dropFirst()
            .sink(receiveValue: { audioDeviceStatus in
                XCTAssertEqual(audioDeviceStatus, .receiverSelected)
                expectation.fulfill()
            }).store(in: cancellable)

        XCTAssertEqual(audioDeviceListViewModel.audioDeviceStatus, .receiverSelected)
        audioDeviceListViewModel.update(audioDeviceStatus: .receiverSelected)
        XCTAssertEqual(audioDeviceListViewModel.audioDeviceStatus, .receiverSelected)
        wait(for: [expectation], timeout: 1)
    }

    func test_audioDeviceListViewModel_update_when_audioDeviceStatusUpdatedToSpeakerRequested_then_shouldNotBePublished() {
        let expectation = XCTestExpectation(description: "Should not publish audioDeviceStatus")
        expectation.isInverted = true
        audioDeviceListViewModel.$audioDeviceStatus
            .dropFirst(2)
            .sink(receiveValue: { _ in
                expectation.fulfill()
                XCTFail("audio device is in the process of switching so audioDeviceStatus should not publish")
            }).store(in: cancellable)

        audioDeviceListViewModel.update(audioDeviceStatus: .receiverSelected)
        XCTAssertEqual(audioDeviceListViewModel.audioDeviceStatus, .receiverSelected)
        audioDeviceListViewModel.update(audioDeviceStatus: .speakerRequested)
        XCTAssertNotEqual(audioDeviceListViewModel.audioDeviceStatus, .speakerRequested)
        wait(for: [expectation], timeout: 1)
    }

    func test_audioDeviceListViewModel_update_when_audioDeviceStatusSwitchedFromReceiverToSpeaker_then_shouldUpdateAudioDeviceList() {
        audioDeviceListViewModel.update(audioDeviceStatus: .receiverSelected)
        XCTAssertEqual(audioDeviceListViewModel.audioDeviceStatus, .receiverSelected)
        let initialSelection = audioDeviceListViewModel.audioDeviceList.first(where: { $0.isSelected })
        XCTAssertEqual(initialSelection?.title, AudioDeviceType.receiver.name)

        audioDeviceListViewModel.update(audioDeviceStatus: .speakerRequested)
        XCTAssertNotEqual(audioDeviceListViewModel.audioDeviceStatus, .speakerRequested)

        audioDeviceListViewModel.update(audioDeviceStatus: .speakerSelected)
        XCTAssertEqual(audioDeviceListViewModel.audioDeviceStatus, .speakerSelected)
        let updatedSelection = audioDeviceListViewModel.audioDeviceList.first(where: { $0.isSelected })
        XCTAssertEqual(updatedSelection?.title, AudioDeviceType.speaker.name)
    }
}
