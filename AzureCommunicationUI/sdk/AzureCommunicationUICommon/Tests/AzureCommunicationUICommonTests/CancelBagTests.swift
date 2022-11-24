//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import XCTest
@testable import AzureCommunicationUICommon

final class CancelBagTests: XCTestCase {
    func testCancelBag() throws {
        let cancelBag = CancelBag()
        
        XCTAssertNotNil(cancelBag)
    }
}
