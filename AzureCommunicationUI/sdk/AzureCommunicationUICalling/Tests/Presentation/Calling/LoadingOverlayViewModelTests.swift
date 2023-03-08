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
    private var logger: LoggerMocking!
    private var factoryMocking: CompositeViewModelFactoryMocking!

    override func setUp() {
        super.setUp()
        localizationProvider = LocalizationProviderMocking()
        storeFactory = StoreFactoryMocking()
        logger = LoggerMocking()
        factoryMocking = CompositeViewModelFactoryMocking(logger: logger, store: storeFactory.store)
    }

    override func tearDown() {
        super.tearDown()
        localizationProvider = nil
        storeFactory = nil
        logger = nil
        factoryMocking = nil
    }

    func test_loadingOverlayViewModel_displays_title_from_AppLocalization() {
        let sut = makeSUT()
        XCTAssertEqual(sut.title, "Joining call…")
    }
}

extension LoadingOverlayViewModelTests {
    func makeSUT(localizationProvider: LocalizationProviderMocking? = nil) -> LoadingOverlayViewModel {
        return LoadingOverlayViewModel(compositeViewModelFactory: factoryMocking,
                                       localizationProvider: localizationProvider ?? LocalizationProvider(logger: LoggerMocking()),
                                     accessibilityProvider: AccessibilityProviderMocking(),
                                       store: storeFactory.store
        )
    }

    func makeSUTLocalizationMocking() -> LoadingOverlayViewModel {
        return makeSUT(localizationProvider: localizationProvider)
    }
}
