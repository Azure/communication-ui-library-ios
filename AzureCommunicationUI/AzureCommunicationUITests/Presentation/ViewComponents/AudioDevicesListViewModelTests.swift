//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import XCTest
@testable import AzureCommunicationUI

class AudioDevicesListViewModelTests: XCTestCase {
    var storeFactory: StoreFactoryMocking!
    var cancellable: CancelBag!
    var audioDevicesListViewModel: AudioDevicesListViewModel!

    override func setUp() {
        super.setUp()
        storeFactory = StoreFactoryMocking()
        cancellable = CancelBag()

        func dispatch(action: Action) {
            storeFactory.store.dispatch(action: action)
        }
        audioDevicesListViewModel = AudioDevicesListViewModel(dispatchAction: dispatch,
                                                              localUserState: LocalUserState())
    }

    func test_audioDevicesListViewModel_update_when_audioDevicesListFirstInitialized_then_shouldBePublished() {
        let expectation = XCTestExpectation(description: "Should publish audioDevicesList")
        audioDevicesListViewModel.$audioDevicesList
            .dropFirst()
            .sink(receiveValue: { audioDevicesList in
                XCTAssertEqual(audioDevicesList.count, 2)
                expectation.fulfill()
            }).store(in: cancellable)

        XCTAssertTrue(audioDevicesListViewModel.audioDevicesList.isEmpty)
        audioDevicesListViewModel.update(audioDeviceStatus: .headphonesSelected)
        XCTAssertFalse(audioDevicesListViewModel.audioDevicesList.isEmpty)
        wait(for: [expectation], timeout: 1)
    }

    func test_audioDevicesListViewModel_update_when_audioDeviceStatusUpdatedToSpeakerRequested_then_shouldNotBePublished() {
        let expectation = XCTestExpectation(description: "Should not publish audioDevicesList")
        expectation.isInverted = true
        audioDevicesListViewModel.$audioDevicesList
            .dropFirst(2)
            .sink(receiveValue: { _ in
                expectation.fulfill()
                XCTFail("audio device is in the process of switching so audioDeviceStatus should not publish")
            }).store(in: cancellable)

        audioDevicesListViewModel.update(audioDeviceStatus: .receiverSelected)
        let initialSelection = audioDevicesListViewModel.audioDevicesList.first(where: { $0.isSelected })
        XCTAssertEqual(initialSelection?.title, AudioDeviceType.receiver.name)
        XCTAssertEqual(initialSelection?.icon, .speakerRegular)

        audioDevicesListViewModel.update(audioDeviceStatus: .speakerRequested)
        let requestedSelection = audioDevicesListViewModel.audioDevicesList.first(where: { $0.isSelected })
        XCTAssertEqual(requestedSelection?.title, AudioDeviceType.receiver.name)
        XCTAssertEqual(requestedSelection?.icon, .speakerRegular)
        XCTAssertNotEqual(requestedSelection?.title, AudioDeviceType.speaker.name)
        XCTAssertNotEqual(requestedSelection?.icon, .speakerFilled)
        wait(for: [expectation], timeout: 1)
    }

    func test_audioDevicesListViewModel_update_when_audioDeviceStatusSwitchedToBluetooth_then_shouldBePublished() {
        let expectation = XCTestExpectation(description: "Should publish audioDevicesList")
        audioDevicesListViewModel.$audioDevicesList
            .dropFirst()
            .sink(receiveValue: { audioDevicesList in
                let updatedSelection = audioDevicesList.first(where: { $0.isSelected })
                XCTAssertEqual(updatedSelection?.title, AudioDeviceType.bluetooth.name)
                XCTAssertEqual(updatedSelection?.icon, .speakerBluetooth)
                expectation.fulfill()
            }).store(in: cancellable)

        audioDevicesListViewModel.update(audioDeviceStatus: .bluetoothRequested)
        let requestedSelection = audioDevicesListViewModel.audioDevicesList.first(where: { $0.isSelected })
        XCTAssertNotEqual(requestedSelection?.title, AudioDeviceType.bluetooth.name)
        XCTAssertNotEqual(requestedSelection?.icon, .speakerBluetooth)

        audioDevicesListViewModel.update(audioDeviceStatus: .bluetoothSelected)
        let updatedSelection = audioDevicesListViewModel.audioDevicesList.first(where: { $0.isSelected })
        XCTAssertEqual(updatedSelection?.title, AudioDeviceType.bluetooth.name)
        XCTAssertEqual(updatedSelection?.icon, .speakerBluetooth)
        wait(for: [expectation], timeout: 1)
    }
}
