//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import XCTest
@testable import AzureCommunicationUI

class JoiningCallActivityViewModelTests: XCTestCase {
    private var localizationProvider: LocalizationProvider!

    override func setUp() {
        super.setUp()
        localizationProvider = LocalizationProviderMocking()
    }

    func test_joiningCallActivityViewModel_when_getTitle_then_shouldLocalizedPlaceholderString() {
        let sut = makeSUT()
        XCTAssertEqual(sut.title, "AzureCommunicationUI.SetupView.Button.JoiningCall")
    }
}

extension JoiningCallActivityViewModelTests {
    func makeSUT() -> JoiningCallActivityViewModel {
        return JoiningCallActivityViewModel(localizationProvider: localizationProvider)
    }
}
