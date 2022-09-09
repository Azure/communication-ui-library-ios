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

    func test_onHoldOverlayViewModel_tapActionPeformed_when_actionButton_isTapped() {
        var buttonTapped = false
        let resumeActionMock = {
            buttonTapped = true
        }
        let sut = makeSUT(withAction: resumeActionMock)
        sut.mockResumeAction()
        XCTAssertTrue(buttonTapped)
    }
}

extension OnHoldOverlayViewModelTests {
    func makeSUT() -> OnHoldOverlayViewModel {
        setupMocking()
        return OnHoldOverlayViewModel(localizationProvider: LocalizationProvider(logger: logger),
                                      compositeViewModelFactory: factoryMocking,
                                      logger: logger,
                                      accessibilityProvider: accessibilityProvider,
                                      resumeAction: {})
    }

    func makeSUTLocalizationMocking() -> OnHoldOverlayViewModel {
        setupMocking()
        return OnHoldOverlayViewModel(localizationProvider: localizationProvider,
                                      compositeViewModelFactory: factoryMocking,
                                      logger: logger,
                                      accessibilityProvider: accessibilityProvider,
                                      resumeAction: {})
    }

    func makeSUT(withAction action: @escaping (() -> Void)) -> OnHoldOverlayViewModelMocking {
        setupMocking()
        return OnHoldOverlayViewModelMocking(localizationProvider: LocalizationProvider(logger: logger),
                                                  compositeViewModelFactory: factoryMocking,
                                                  logger: logger,
                                                  accessibilityProvider: accessibilityProvider,
                                                  resumeAction: action)
    }

    func setupMocking() {
        logger = LoggerMocking()
        storeFactory = StoreFactoryMocking()
        localizationProvider = LocalizationProviderMocking()
        factoryMocking = CompositeViewModelFactoryMocking(logger: logger, store: storeFactory.store)
        accessibilityProvider = AccessibilityProviderMocking()
    }
}
