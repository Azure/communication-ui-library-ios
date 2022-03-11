//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import XCTest
import AzureCommunicationCommon
@testable import AzureCommunicationUI

class DependencyContainerTests: XCTestCase {
    func test_dependencyContainer_init_then_defaultDependenciesAreRegistered() {
        let dependencyContainer = DependencyContainer()

        XCTAssertNotNil(dependencyContainer.resolve() as Logger)
    }

    func test_dependencyContainer_registerExperienceDependencies_thenExperienceDependenciesAreRegistered() {
        let dependencyContainer = DependencyContainer()

        let sampleToken = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjMyNTAzNjgwMDAwfQ.9i7FNNHHJT8cOzo-yrAUJyBSfJ-tPPk2emcHavOEpWc"
        let communicationTokenCredential = try? CommunicationTokenCredential(token: sampleToken)
        let displayName = ""
        let groupId = UUID()
        let callConfiguration = CallConfiguration(communicationTokenCredential: communicationTokenCredential!,
                                                  groupId: groupId,
                                                  displayName: displayName)

        dependencyContainer.registerDependencies(callConfiguration)

        XCTAssertNotNil(dependencyContainer.resolve() as CallingSDKWrapper)
        XCTAssertNotNil(dependencyContainer.resolve() as VideoViewManager)
        XCTAssertNotNil(dependencyContainer.resolve() as CallingService)
        XCTAssertNotNil(dependencyContainer.resolve() as Store<AppState>)
        XCTAssertNotNil(dependencyContainer.resolve() as NavigationRouter)
        XCTAssertNotNil(dependencyContainer.resolve() as CompositeViewModelFactory)
        XCTAssertNotNil(dependencyContainer.resolve() as CompositeViewFactory)
    }
}
