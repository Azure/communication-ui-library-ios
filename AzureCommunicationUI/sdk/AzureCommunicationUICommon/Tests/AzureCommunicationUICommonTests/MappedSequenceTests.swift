//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import XCTest
@testable import AzureCommunicationUICommon

final class MappedSequenceTests: XCTestCase {
    func testMappedSequence() {
        let mappedSequence = MappedSequence<String, Int>()
        mappedSequence.append(forKey: "1", value: 1)
        mappedSequence.append(forKey: "2", value: 2)
        mappedSequence.append(forKey: "3", value: 3)
        mappedSequence.append(forKey: "4", value: 4)
        mappedSequence.append(forKey: "6", value: 6)
        mappedSequence.append(forKey: "5", value: 5)

        XCTAssertEqual(mappedSequence.toArray(), [1,2,3,4,6,5])

        mappedSequence.removeValue(forKey: "6")
        XCTAssertEqual(mappedSequence.toArray(), [1,2,3,4,5])

        mappedSequence.removeLast()
        XCTAssertEqual(mappedSequence.toArray(), [1,2,3,4])

        XCTAssertEqual(mappedSequence.value(forKey: "1"), 1)

        mappedSequence.prepend(forKey: "0", value: 0)
        XCTAssertEqual(mappedSequence.toArray(), [0,1,2,3,4])
    }
}
