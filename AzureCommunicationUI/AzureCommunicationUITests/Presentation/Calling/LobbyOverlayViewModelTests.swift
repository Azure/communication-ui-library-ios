//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import XCTest
@testable import AzureCommunicationUI

class LobbyOverlayViewModelTests: XCTestCase {
    private var localizationProvider: LocalizationProviderMocking!

    override func setUp() {
        super.setUp()
        localizationProvider = LocalizationProviderMocking()
    }

    func test_lobbyOverlayViewModel_displays_title_from_AppLocalization() {
        let sut = makeSUT()
        XCTAssertEqual(sut.title, "Waiting for host")
    }

    func test_lobbyOverlayViewModel_displays_subtitle_from_AppLocalization() {
        let sut = makeSUT()
        XCTAssertEqual(sut.subtitle, "Someone in the meeting will let you in soon")
    }

    func test_lobbyOverlayViewModel_displays_subtitle_from_LocalizationMocking() {
        let sut = makeSUTLocalizationMocking()
        XCTAssertEqual(sut.subtitle, "AzureCommunicationUICalling.LobbyView.Text.WaitingDetails")
        XCTAssertTrue(localizationProvider.isGetLocalizedStringCalled)
    }
}

extension LobbyOverlayViewModelTests {
    func makeSUT() -> LobbyOverlayViewModel {
        return LobbyOverlayViewModel(localizationProvider:
                                        AppLocalizationProvider(logger: LoggerMocking()))
    }

    func makeSUTLocalizationMocking() -> LobbyOverlayViewModel {
        return LobbyOverlayViewModel(localizationProvider: localizationProvider)
    }
}
