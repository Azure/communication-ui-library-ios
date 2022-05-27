//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import XCTest
import UIKit
import AzureCommunicationCommon
@testable import AzureCommunicationUICalling

class AvatarManagerTests: XCTestCase {
    var mockStoreFactory = StoreFactoryMocking()

    override func setUp() {
        super.setUp()
    }

    func test_avatarManager_when_setLocalAvatar_then_getLocalAvatar_returnsSameUIImage() {
        guard let mockImage = UIImage.make(withColor: .red) else {
            XCTFail("UIImage does not exist")
            return
        }
        let mockAvatarManager = makeSUT(mockImage)
        let mockImageData = mockImage.cgImage?.bitsPerPixel
        let setAvatar = mockAvatarManager.localSettings?.participantViewData.avatarImage
        let setAvatarImageData = setAvatar?.cgImage?.bitsPerPixel
        XCTAssertEqual(mockImageData, setAvatarImageData)
    }

    func test_avatarManager_setRemoteParticipantViewData_when_personeDataSet_then_participantViewDataDataUpdated() {
        guard let mockImage = UIImage.make(withColor: .red) else {
            XCTFail("UIImage does not exist")
            return
        }
        let expectation = XCTestExpectation(description: "Update participant's view data failed")
        expectation.isInverted = true
        let participant = ParticipantInfoModel(
            displayName: "Participant 1",
            isSpeaking: false,
            isMuted: false,
            isRemoteUser: true,
            userIdentifier: "testUserIdentifier1",
            recentSpeakingStamp: Date(),
            screenShareVideoStreamModel: nil,
            cameraVideoStreamModel: nil)
        let remoteParticipantsState = RemoteParticipantsState(participantInfoList: [participant],
                                                              lastUpdateTimeStamp: Date())
        mockStoreFactory.setState(AppState(remoteParticipantsState: remoteParticipantsState))
        let sut = makeSUT()
        let participantViewData = ParticipantViewData(avatar: mockImage)
        sut.setRemoteParticipantViewData(participantViewData,
                                         for: CommunicationUserIdentifier(participant.userIdentifier)) { _ in
            expectation.fulfill()
        }
        XCTAssertEqual(sut.avatarStorage.value(forKey: participant.userIdentifier)?.avatarImage!, mockImage)
        wait(for: [expectation], timeout: 1)
    }

    func test_avatarManager_setRemoteParticipantViewData_when_avatarDataSet__and_participantNotOnCall_then_participantNotFoundErrorReturned() {
        guard let mockImage = UIImage.make(withColor: .red) else {
            XCTFail("UIImage does not exist")
            return
        }
        let expectation = XCTestExpectation(description: "Update participant's view data failed")
        let sut = makeSUT()
        let participantViewData = ParticipantViewData(avatar: mockImage)
        let id = UUID().uuidString
        sut.set(remoteParticipantViewData: participantViewData,
                for: CommunicationUserIdentifier(id)) { errorEvent in
            XCTAssertEqual(errorEvent.code, CallCompositeErrorCode.remoteParticipantNotFound)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)
    }
}

extension AvatarManagerTests {
    private func makeSUT(_ image: UIImage) -> AvatarViewManager {
        let mockParticipantViewData = ParticipantViewData(avatar: image, renderDisplayName: "")
        let mockLocalSettings = LocalSettings(mockParticipantViewData)
        return AvatarViewManager(store: mockStoreFactory.store,
                                 localSettings: mockLocalSettings)

    }

    private func makeSUT() -> AvatarViewManager {
        return AvatarViewManager(store: mockStoreFactory.store,
                                 localSettings: nil)
    }
}

extension UIImage {
    static func make(withColor color: UIColor) -> UIImage? {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContext(rect.size)
        guard let context = UIGraphicsGetCurrentContext() else {
            return nil
        }
        context.setFillColor(color.cgColor)
        context.fill(rect)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img
    }
}
