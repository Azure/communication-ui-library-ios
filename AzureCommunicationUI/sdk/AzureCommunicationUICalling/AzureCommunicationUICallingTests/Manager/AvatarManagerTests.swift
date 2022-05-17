//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import XCTest
import UIKit
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
        let setAvatar = mockAvatarManager.getLocalParticipantViewData()?.avatarImage
        let setAvatarImageData = setAvatar?.cgImage?.bitsPerPixel
        XCTAssertEqual(mockImageData, setAvatarImageData)
    }

    private func makeSUT(_ image: UIImage) -> AvatarViewManagerProtocol {
        let mockParticipantViewData = ParticipantViewData(avatar: image, renderDisplayName: "")
        let mockLocalSettings = LocalSettings(mockParticipantViewData)
        return CompositeAvatarViewManager(store: mockStoreFactory.store,
                                          localSettings: mockLocalSettings)

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
