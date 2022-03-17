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
    var localizationProvider: LocalizationProviderMocking!

    override func setUp() {
        super.setUp()
        storeFactory = StoreFactoryMocking()
        cancellable = CancelBag()
        localizationProvider = LocalizationProviderMocking()
    }

    func test_audioDevicesListViewModel_update_when_audioDevicesListFirstInitialized_then_shouldBePublished() {
        let sut = makeSUT()
        let expectation = XCTestExpectation(description: "Should publish audioDevicesList")
        sut.$audioDevicesList
            .dropFirst()
            .sink(receiveValue: { audioDevicesList in
                XCTAssertEqual(audioDevicesList.count, 2)
                expectation.fulfill()
            }).store(in: cancellable)

        XCTAssertTrue(sut.audioDevicesList.isEmpty)
        sut.update(audioDeviceStatus: .headphonesSelected)
        XCTAssertFalse(sut.audioDevicesList.isEmpty)
        wait(for: [expectation], timeout: 1)
    }

    func test_audioDevicesListViewModel_update_when_audioDeviceStatusUpdatedToSpeakerRequested_then_shouldNotBePublished() {
        let sut = makeSUT()
        let expectation = XCTestExpectation(description: "Should not publish audioDevicesList")
        expectation.isInverted = true
        sut.$audioDevicesList
            .dropFirst(2)
            .sink(receiveValue: { _ in
                expectation.fulfill()
                XCTFail("audio device is in the process of switching so audioDeviceStatus should not publish")
            }).store(in: cancellable)

        sut.update(audioDeviceStatus: .receiverSelected)
        let initialSelection = sut.audioDevicesList.first(where: { $0.isSelected })
        XCTAssertEqual(initialSelection?.title, self.localizationProvider
                        .getLocalizedString(AudioDeviceType.receiver.name))
        XCTAssertEqual(initialSelection?.icon, .speakerRegular)

        sut.update(audioDeviceStatus: .speakerRequested)
        let requestedSelection = sut.audioDevicesList.first(where: { $0.isSelected })
        XCTAssertEqual(requestedSelection?.title, self.localizationProvider
                        .getLocalizedString(AudioDeviceType.receiver.name))
        XCTAssertEqual(requestedSelection?.icon, .speakerRegular)
        XCTAssertNotEqual(requestedSelection?.title, self.localizationProvider
                            .getLocalizedString(AudioDeviceType.speaker.name))
        XCTAssertNotEqual(requestedSelection?.icon, .speakerFilled)
        wait(for: [expectation], timeout: 1)
    }

    func test_audioDevicesListViewModel_update_when_audioDeviceStatusSwitchedToBluetooth_then_shouldBePublished() {
        let sut = makeSUT()
        let expectation = XCTestExpectation(description: "Should publish audioDevicesList")
        sut.$audioDevicesList
            .dropFirst()
            .sink(receiveValue: { audioDevicesList in
                let updatedSelection = audioDevicesList.first(where: { $0.isSelected })
                XCTAssertEqual(updatedSelection?.title, self.localizationProvider
                                .getLocalizedString(AudioDeviceType.bluetooth.name))
                XCTAssertEqual(updatedSelection?.icon, .speakerBluetooth)
                expectation.fulfill()
            }).store(in: cancellable)

        sut.update(audioDeviceStatus: .bluetoothRequested)
        let requestedSelection = sut.audioDevicesList.first(where: { $0.isSelected })
        XCTAssertNotEqual(requestedSelection?.title, self.localizationProvider
                            .getLocalizedString(AudioDeviceType.bluetooth.name))
        XCTAssertNotEqual(requestedSelection?.icon, .speakerBluetooth)

        sut.update(audioDeviceStatus: .bluetoothSelected)
        let updatedSelection = sut.audioDevicesList.first(where: { $0.isSelected })
        XCTAssertEqual(updatedSelection?.title, self.localizationProvider
                        .getLocalizedString(AudioDeviceType.bluetooth.name))
        XCTAssertEqual(updatedSelection?.icon, .speakerBluetooth)
        wait(for: [expectation], timeout: 1)
    }
}

extension AudioDevicesListViewModelTests {
    func makeSUT() -> AudioDevicesListViewModel {
        func dispatch(action: Action) {
            storeFactory.store.dispatch(action: action)
        }
        return AudioDevicesListViewModel(dispatchAction: dispatch,
                                         localUserState: LocalUserState(),
                                         localizationProvider: localizationProvider)
    }
}
