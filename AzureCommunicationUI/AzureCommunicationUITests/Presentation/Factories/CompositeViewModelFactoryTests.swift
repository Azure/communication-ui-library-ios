//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import XCTest
@testable import AzureCommunicationUI

class CompositeViewModelFactoryTests: XCTestCase {

    var logger: LoggerMocking!
    var mockStoreFactory = StoreFactoryMocking()
    var compositeViewModelFactory: ACSCompositeViewModelFactory!

    override func setUp() {
        super.setUp()
        logger = LoggerMocking()
        compositeViewModelFactory = ACSCompositeViewModelFactory(logger: logger,
                                                                 store: mockStoreFactory.store,
                                                                 accessibilityProvider: AccessibilityProviderMocking())
    }

    func test_compositeViewModelFactory_getCallingViewModel_when_setupViewModelNotNil_then_getSetupViewModel_shouldReturnDifferentSetupViewModel() {
        let setupViewModel1 = compositeViewModelFactory.getSetupViewModel()
        let setupViewModel2 = compositeViewModelFactory.getSetupViewModel()
        XCTAssertEqual(setupViewModel1.id, setupViewModel2.id)

        _ = compositeViewModelFactory.getCallingViewModel()
        let setupViewModel3 = compositeViewModelFactory.getSetupViewModel()
        XCTAssertNotEqual(setupViewModel1.id, setupViewModel3.id)
    }

    func test_compositeViewModelFactory_getSetupViewModel_when_callingViewModelNotNil_then_getCallingViewModel_shouldReturnDifferentCallingViewModel() {
        let callingViewModel1 = compositeViewModelFactory.getCallingViewModel()
        let callingViewModel2 = compositeViewModelFactory.getCallingViewModel()
        XCTAssertEqual(callingViewModel1.id, callingViewModel2.id)

        _ = compositeViewModelFactory.getSetupViewModel()
        let callingViewModel3 = compositeViewModelFactory.getCallingViewModel()
        XCTAssertNotEqual(callingViewModel1.id, callingViewModel3.id)
    }
}

extension SetupViewModel: Identifiable {}

extension CallingViewModel: Identifiable {}
