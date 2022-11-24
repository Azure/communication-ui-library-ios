//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import XCTest
@testable import AzureCommunicationUICommon

final class ArrayExtensionsTests: XCTestCase {
    func testChunking() {
        let array = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20]

        let chunked4 = array.chunkedAndReversed(into: 4)
        XCTAssertEqual(chunked4, [
            [17, 18, 19, 20],
            [13, 14, 15, 16],
            [9, 10, 11, 12],
            [5, 6, 7, 8],
            [1, 2, 3, 4]
        ])

        let chunked6 = array.chunkedAndReversed(into: 6)
        XCTAssertEqual(chunked6, [
            [19, 20],
            [13, 14, 15, 16, 17, 18],
            [7, 8, 9, 10, 11, 12],
            [1, 2, 3, 4, 5, 6]
        ])

        let chunked4NoV = array.chunkedAndReversed(into: 4, vGridLayout: false)
        XCTAssertEqual(chunked4NoV, [
            [17, 18, 19, 20],
            [13, 14, 15, 16],
            [9, 10, 11, 12],
            [5, 6, 7, 8],
            [1, 2, 3, 4]
        ])

        let chunked6NoV = array.chunkedAndReversed(into: 6, vGridLayout: false)
        XCTAssertEqual(chunked6NoV, [
            [19, 20],
            [13, 14, 15, 16, 17, 18],
            [7, 8, 9, 10, 11, 12],
            [1, 2, 3, 4, 5, 6]
        ])
    }
}
