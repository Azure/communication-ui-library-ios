//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import XCTest
@testable import AzureCommunicationUICalling

class JoiningCallActivityViewModelTests: XCTestCase {
    private var localizationProvider: LocalizationProviderProtocol!

    override func setUp() {
        super.setUp()
        localizationProvider = LocalizationProviderMocking()
    }

    override func tearDown() {
        super.tearDown()
        localizationProvider = nil
    }

    func test_joiningCallActivityViewModel_when_getTitle_then_shouldLocalizedPlaceholderString() {
        let sut = makeSUT()
        XCTAssertEqual(sut.title, "AzureCommunicationUICalling.SetupView.Button.JoiningCall")
    }
}

extension JoiningCallActivityViewModelTests {
    func makeSUT() -> JoiningCallActivityViewModel {
        return JoiningCallActivityViewModel(localizationProvider: localizationProvider)
    }
}
