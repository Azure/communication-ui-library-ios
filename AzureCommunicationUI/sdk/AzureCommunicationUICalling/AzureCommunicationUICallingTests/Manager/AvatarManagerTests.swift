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
        let result = sut.setRemoteParticipantViewData(for: CommunicationUserIdentifier(participant.userIdentifier),
                                                      participantViewData: participantViewData)
        guard case .success = result else {
            XCTFail("Failed with result validation")
            return
        }
        XCTAssertEqual(sut.avatarStorage.value(forKey: participant.userIdentifier)?.avatarImage!, mockImage)
    }

    func test_avatarManager_setRemoteParticipantViewData_when_avatarDataSet__and_participantNotOnCall_then_participantNotFoundErrorReturned() {
        guard let mockImage = UIImage.make(withColor: .red) else {
            XCTFail("UIImage does not exist")
            return
        }
        let sut = makeSUT()
        let participantViewData = ParticipantViewData(avatar: mockImage)
        let id = UUID().uuidString
        let result = sut.setRemoteParticipantViewData(for: CommunicationUserIdentifier(id),
                                                      participantViewData: participantViewData)
        guard case .failure(let error) = result else {
            XCTFail("Failed with result validation")
            return
        }
        XCTAssertEqual(error.code, CallCompositeErrorCode.remoteParticipantNotFound)
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
