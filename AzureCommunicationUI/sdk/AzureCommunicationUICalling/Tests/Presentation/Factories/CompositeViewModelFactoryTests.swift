//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import XCTest
@testable import AzureCommunicationUICalling

class CompositeViewModelFactoryTests: XCTestCase {

    func test_compositeViewModelFactory_getCallingViewModel_when_setupViewModelNotNil_then_getSetupViewModel_shouldReturnDifferentSetupViewModel() {
        let sut = makeSUT()
        let setupViewModel1 = sut.getSetupViewModel()
        let setupViewModel2 = sut.getSetupViewModel()
        XCTAssertEqual(setupViewModel1.id, setupViewModel2.id)

        _ = sut.getCallingViewModel()
        let setupViewModel3 = sut.getSetupViewModel()
        XCTAssertNotEqual(setupViewModel1.id, setupViewModel3.id)
    }

    func test_compositeViewModelFactory_getSetupViewModel_when_callingViewModelNotNil_then_getCallingViewModel_shouldReturnDifferentCallingViewModel() {
        let sut = makeSUT()
        let callingViewModel1 = sut.getCallingViewModel()
        let callingViewModel2 = sut.getCallingViewModel()
        XCTAssertEqual(callingViewModel1.id, callingViewModel2.id)

        _ = sut.getSetupViewModel()
        let callingViewModel3 = sut.getCallingViewModel()
        XCTAssertNotEqual(callingViewModel1.id, callingViewModel3.id)
    }
}

extension CompositeViewModelFactoryTests {
    func makeSUT() -> CompositeViewModelFactory {
        let mockStoreFactory = StoreFactoryMocking()
        let logger = LoggerMocking()
        return CompositeViewModelFactory(logger: logger,
                                                              store: mockStoreFactory.store,
                                                              networkManager: NetworkManager(),
                                                              localizationProvider: LocalizationProviderMocking(),
                                                              accessibilityProvider: AccessibilityProviderMocking())
    }
}

extension SetupViewModel: Identifiable {}

extension CallingViewModel: Identifiable {}
