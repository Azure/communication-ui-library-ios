//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import XCTest
@testable import AzureCommunicationUICalling

class LoadingOverlayViewModelTests: XCTestCase {
    private var localizationProvider: LocalizationProviderMocking!
    private var storeFactory: StoreFactoryMocking!

    override func setUp() {
        super.setUp()
        localizationProvider = LocalizationProviderMocking()
        storeFactory = StoreFactoryMocking()
    }

    override func tearDown() {
        super.tearDown()
        localizationProvider = nil
        storeFactory = nil
    }

    func test_loadingOverlayViewModel_displays_title_from_AppLocalization() {
        let sut = makeSUT()
        XCTAssertEqual(sut.title, "Joining call…")
    }
}

extension LoadingOverlayViewModelTests {
    func makeSUT(localizationProvider: LocalizationProviderMocking? = nil) -> LoadingOverlayViewModel {
        return LoadingOverlayViewModel(localizationProvider: localizationProvider ?? LocalizationProvider(logger: LoggerMocking()),
                                     accessibilityProvider: AccessibilityProviderMocking(),
                                       networkManager: NetworkManager(),
                                       audioSessionManager: AudioSessionManager(store: storeFactory.store, logger: LoggerMocking()),
                                       store: storeFactory.store,
                                       compositeCallType: .groupCall
        )
    }

    func makeSUTLocalizationMocking() -> LoadingOverlayViewModel {
        return makeSUT(localizationProvider: localizationProvider)
    }
}
