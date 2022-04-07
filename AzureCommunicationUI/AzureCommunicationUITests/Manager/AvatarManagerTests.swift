//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import XCTest
import UIKit
@testable import AzureCommunicationUI

class AvatarManagerTests: XCTestCase {
    var mockStoreFactory = StoreFactoryMocking()
    var avatarManager: AvatarManager!

    override func setUp() {
        super.setUp()
        avatarManager = AvatarManager(store: mockStoreFactory.store)
    }

    func test_avatarManager_when_setLocalAvatar_then_getLocalAvatar_returnsSameUIImage() {
        guard let mockImage = UIImage(named: "Icon/ic_fluent_call_end_24_filled",
                                      in: Bundle(for: CallComposite.self),
                                      compatibleWith: nil) else {
            XCTFail("UIImage does not exist")
            return
        }
        let mockImageData = mockImage.cgImage?.bitsPerPixel

        avatarManager.setLocalAvatar(mockImage)
        let setAvatar = avatarManager.getLocalAvatar()
        let setAvatarImageData = setAvatar?.cgImage?.bitsPerPixel
        XCTAssertEqual(mockImageData, setAvatarImageData)
    }
}
