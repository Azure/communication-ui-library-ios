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
        guard let mockImage = UIImage(named: "Icon/ic_fluent_call_end_24_filled",
                                      in: Bundle(for: CallComposite.self),
                                      compatibleWith: nil) else {
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
        guard let mockImage = UIImage(named: "Icon/ic_fluent_call_end_24_filled",
                                      in: Bundle(for: CallComposite.self),
                                      compatibleWith: nil) else {
            XCTFail("UIImage does not exist")
            return
        }
        let sut = makeSUT()
        let participantViewData = ParticipantViewData(avatar: mockImage)
        let id = UUID().uuidString
        let result = sut.setRemoteParticipantViewData(for: CommunicationUserIdentifier(id),
                                                      participantViewData: participantViewData)
        guard case .success = result else {
            XCTFail("Failed with result validation")
            return
        }
        XCTAssertEqual(sut.avatarStorage.value(forKey: id)?.avatarImage!, mockImage)
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
