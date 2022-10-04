//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import XCTest
import AzureCommunicationCommon
@testable import AzureCommunicationUICalling

class DiagnosticConfigTests: XCTestCase {

    let expectedCompositeTag: String = "aci110/1.1.0-beta.1"
    func test_init_when_init_then_returnExpectedTags() {
        let sut = makeSUT()
        guard let tag = sut.tags.first else {
            XCTFail("Failed with empty array")
            return
        }

        XCTAssertEqual(tag, expectedCompositeTag)
    }

    func test_init_when_init_then_returnRegExValidTags() {
        let sut = makeSUT()
        guard let tag = sut.tags.first else {
            XCTFail("Failed with empty array")
            return
        }
        let validationRegEx = "aci110/[0-9][0-9]?.[0-9][0-9]?.[0-9][0-9]?(-(alpha|beta)(.[0-9][0-9]?)?)?"
        let validationPred = NSPredicate(format: "SELF MATCHES %@", validationRegEx)
        XCTAssertTrue(validationPred.evaluate(with: tag))
    }
}

extension DiagnosticConfigTests {
    func makeSUT() -> DiagnosticConfig {
        return DiagnosticConfig()
    }
}
