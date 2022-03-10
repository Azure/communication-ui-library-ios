//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import XCTest
@testable import AzureCommunicationUI

class LobbyOverlayViewModelTests: XCTestCase {
    private var localizationProvider: LocalizationProvider!

    override func setUp() {
        super.setUp()
        localizationProvider = LocalizationProviderMocking()
    }

    func test_lobbyOverlayViewModel_displaysTitleAccordingToLocalizationProvided() {
        let sut = makeSUT()
        XCTAssertEqual(sut.title, "ABC")
    }

    func test_lobbyOverlayViewModel_displaysSubtitleAccordingToLocalizationProvided() {
        let sut = makeSUT()
        XCTAssertEqual(sut.subtitle, "ABC")
    }
}

extension LobbyOverlayViewModelTests {
    func makeSUT() -> LobbyOverlayViewModel {
        return LobbyOverlayViewModel(localizationProvider: localizationProvider)
    }
}
