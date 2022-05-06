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
        guard let mockImage = UIImage(named: "Icon/ic_fluent_call_end_24_filled",
                                      in: Bundle(for: CallComposite.self),
                                      compatibleWith: nil) else {
            XCTFail("UIImage does not exist")
            return
        }
        let mockAvatarManager = makeSUT(mockImage)
        let mockImageData = mockImage.cgImage?.bitsPerPixel
        let setAvatar = mockAvatarManager.getLocalPersonaData()?.avatarImage
        let setAvatarImageData = setAvatar?.cgImage?.bitsPerPixel
        XCTAssertEqual(mockImageData, setAvatarImageData)
    }

    private func makeSUT(_ image: UIImage) -> AvatarViewManager {
        let mockPersonaData = CommunicationUIPersonaData(image, renderDisplayName: "")
        let mockDataOptions = CommunicationUILocalDataOptions(mockPersonaData)
        return CompositeAvatarViewManager(store: mockStoreFactory.store,
                                          localDataOptions: mockDataOptions)

    }
}
