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
        let setAvatar = mockAvatarManager.localOptions?.participantViewData.avatarImage
        let setAvatarImageData = setAvatar?.cgImage?.bitsPerPixel
        XCTAssertEqual(mockImageData, setAvatarImageData)
    }

    func test_avatarManager_setRemoteParticipantViewData_when_personeDataSet_then_participantViewDataDataUpdated() {
        guard let mockImage = UIImage.make(withColor: .red) else {
            XCTFail("UIImage does not exist")
            return
        }
        let expectation = XCTestExpectation(description: "Update participant's view data completion called")
        let participant = ParticipantInfoModel(
            displayName: "Participant 1",
            isSpeaking: false,
            isMuted: false,
            isRemoteUser: true,
            userIdentifier: "testUserIdentifier1",
            status: .idle,
            recentSpeakingStamp: Date(),
            screenShareVideoStreamModel: nil,
            cameraVideoStreamModel: nil)
        let remoteParticipantsState = RemoteParticipantsState(participantInfoList: [participant],
                                                              lastUpdateTimeStamp: Date())
        mockStoreFactory.setState(AppState(remoteParticipantsState: remoteParticipantsState))
        let sut = makeSUT()
        let participantViewData = ParticipantViewData(avatar: mockImage)
        sut.set(remoteParticipantViewData: participantViewData,
                for: CommunicationUserIdentifier(participant.userIdentifier)) { result in
            guard case .success = result else {
                XCTFail("Failed with result validation")
                return
            }
            XCTAssertEqual(sut.avatarStorage.value(forKey: participant.userIdentifier)?.avatarImage!, mockImage)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)
    }

    func test_avatarManager_setRemoteParticipantViewData_when_avatarDataSet__and_participantNotOnCall_then_participantNotFoundErrorReturned() {
        guard let mockImage = UIImage.make(withColor: .red) else {
            XCTFail("UIImage does not exist")
            return
        }
        let expectation = XCTestExpectation(description: "Update participant's view data completion called")
        let sut = makeSUT()
        let participantViewData = ParticipantViewData(avatar: mockImage)
        let id = UUID().uuidString
        sut.set(remoteParticipantViewData: participantViewData,
                for: CommunicationUserIdentifier(id)) { result in
            guard case .failure(let error) = result else {
                XCTFail("Failed with result validation")
                return
            }
            XCTAssertEqual(error, SetParticipantViewDataError.participantNotInCall)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)
    }
}

extension AvatarManagerTests {
    private func makeSUT(_ image: UIImage) -> AvatarViewManager {
        let mockParticipantViewData = ParticipantViewData(avatar: image, displayName: "")
        let mockLocalOptions = LocalOptions(participantViewData: mockParticipantViewData)
        return AvatarViewManager(store: mockStoreFactory.store,
                                 localOptions: mockLocalOptions)

    }

    private func makeSUT() -> AvatarViewManager {
        return AvatarViewManager(store: mockStoreFactory.store,
                                 localOptions: nil)
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
