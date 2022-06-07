//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import XCTest
@testable import AzureCommunicationUICalling

class OnHoldOverlayViewModelTests: XCTestCase {
    var logger: LoggerMocking!
    var storeFactory: StoreFactoryMocking!
    var localizationProvider: LocalizationProviderMocking!
    var factoryMocking: CompositeViewModelFactoryMocking!
    var accessibilityProvider: AccessibilityProviderMocking!

    override func setUp() {
        super.setUp()
        logger = LoggerMocking()
        storeFactory = StoreFactoryMocking()
        localizationProvider = LocalizationProviderMocking()
        factoryMocking = CompositeViewModelFactoryMocking(logger: LoggerMocking(), store: storeFactory.store)
        accessibilityProvider = AccessibilityProviderMocking()
    }

    func test_onHoldOverlayViewModel_displays_title_from_AppLocalization() {
        let sut = makeSUT()
        XCTAssertEqual(sut.title, "You're on hold")
    }

    func test_onHoldOverlayViewModel_displays_title_from_LocalizationMocking() {
        let sut = makeSUTLocalizationMocking()
        XCTAssertEqual(sut.title, "AzureCommunicationUICalling.OnHoldView.Text.OnHold")
        XCTAssertTrue(localizationProvider.isGetLocalizedStringCalled)
    }

    func test_onHoldOverlayViewModel_errorInfoMode_hasTitle_and_subtitle_from_LocalizationMocking() {
        let sut = makeSUTLocalizationMocking()
        XCTAssertNotNil(sut.errorInfoViewModel)
        XCTAssertEqual(sut.errorInfoViewModel?.title, localizationProvider.getLocalizedString(.snackBarErrorOnHoldTitle))
        XCTAssertEqual(sut.errorInfoViewModel?.subtitle, localizationProvider.getLocalizedString(.snackBarErrorOnHoldSubtitle))
    }
}

extension OnHoldOverlayViewModelTests {
    func makeSUT() -> OnHoldOverlayViewModel {
        return OnHoldOverlayViewModel(localizationProvider: LocalizationProvider(logger: LoggerMocking()),
                                      compositeViewModelFactory: factoryMocking,
                                      logger: LoggerMocking(),
                                      accessibilityProvider: accessibilityProvider,
                                      resumeAction: {})
    }

    func makeSUTLocalizationMocking() -> OnHoldOverlayViewModel {
        return OnHoldOverlayViewModel(localizationProvider: localizationProvider,
                                      compositeViewModelFactory: factoryMocking,
                                      logger: LoggerMocking(),
                                      accessibilityProvider: accessibilityProvider,
                                      resumeAction: {})
    }
}
