//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import XCTest
import AzureCommunicationCommon
#if canImport(AzureCommunicationUICallWithChat)
@testable import AzureCommunicationUICallWithChat
#elseif canImport(AzureCommunicationUICalling)
@testable import AzureCommunicationUICalling
#elseif canImport(AzureCommunicationUIChat)
@testable import AzureCommunicationUIChat
#endif

class DiagnosticConfigTests: XCTestCase {
#if canImport(AzureCommunicationUICallWithChat)
    let expectedCompositeTag: String = "aci130/1.0.0"
    let tagPrefix: String = "aci130"
#elseif canImport(AzureCommunicationUICalling)
    let expectedCompositeTag: String = "aci110/1.0.0"
    let tagPrefix: String = "aci110"
#elseif canImport(AzureCommunicationUIChat)
    let expectedCompositeTag: String = "aci120/1.0.0"
    let tagPrefix: String = "aci120"
#endif

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
        let validationRegEx = "\(tagPrefix)/[0-9][0-9]?.[0-9][0-9]?.[0-9][0-9]?(-(alpha|beta)(.[0-9][0-9]?)?)?"
        let validationPred = NSPredicate(format: "SELF MATCHES %@", validationRegEx)
        XCTAssertTrue(validationPred.evaluate(with: tag))
    }
}

extension DiagnosticConfigTests {
    func makeSUT() -> DiagnosticConfig {
        return DiagnosticConfig()
    }
}
