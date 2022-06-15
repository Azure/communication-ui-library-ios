//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import XCTest
import AzureCommunicationCommon
@testable import AzureCommunicationUICalling

class DiagnosticConfigTests: XCTestCase {

    let expectedCompositeTag: String = "aci110/GACallingSDK"
    func test_init_when_init_then_returnExpectedTags() {
        let sut = makeSUT()
        guard let tag = sut.tags.first else {
            XCTFail("Failed with empty array")
            return
        }

        XCTAssertEqual(tag, expectedCompositeTag)

    }
}

extension DiagnosticConfigTests {
    func makeSUT() -> DiagnosticConfig {
        return DiagnosticConfig()
    }
}
