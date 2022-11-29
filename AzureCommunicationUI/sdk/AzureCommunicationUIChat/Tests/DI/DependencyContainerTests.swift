//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import XCTest
import AzureCommunicationCommon
@testable import AzureCommunicationUIChat

class DependencyContainerTests: XCTestCase {
    func test_dependencyContainer_init_then_defaultDependenciesAreRegistered() {
        let dependencyContainer = DependencyContainer()

        XCTAssertNotNil(dependencyContainer.logger)
    }

    func test_dependencyContainer_registerExperienceDependencies_thenExperienceDependenciesAreRegistered() {
        let dependencyContainer = DependencyContainer()

        let sampleToken = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjMyNTAzNjgwMDAwfQ.9i7FNNHHJT8cOzo-yrAUJyBSfJ-tPPk2emcHavOEpWc"
        let communicationTokenCredential = try? CommunicationTokenCredential(token: sampleToken)
        let identifier = CommunicationUserIdentifier("id")
        let displayName = ""
        var chatConfiguration = ChatConfiguration(
            identifier: identifier,
            credential: communicationTokenCredential!,
            endpoint: "endpoint",
            displayName: displayName)
        chatConfiguration.chatThreadId = "threadId"

        let callCompositeEventsHandler = ChatAdapter.Events()

        dependencyContainer.registerDependencies(
            chatConfiguration,
            chatCompositeEventsHandler: callCompositeEventsHandler, connectEventHandler: nil)

//        XCTAssertNotNil(dependencyContainer.chatSdkEventsHandler)
//        XCTAssertNotNil(dependencyContainer.chatSdkWrapper)
//        XCTAssertNotNil(dependencyContainer.chatService)
//        XCTAssertNotNil(dependencyContainer.messageRepositoryManager)
//        XCTAssertNotNil(dependencyContainer.store)
        XCTAssertNotNil(dependencyContainer.navigationRouter)
        XCTAssertNotNil(dependencyContainer.accessibilityProvider)
        XCTAssertNotNil(dependencyContainer.localizationProvider)
//        XCTAssertNotNil(dependencyContainer.compositeViewModelFactory)
        XCTAssertNotNil(dependencyContainer.compositeViewFactory)
        XCTAssertNotNil(dependencyContainer.errorManager)
        XCTAssertNotNil(dependencyContainer.lifecycleManager)
        XCTAssertNotNil(dependencyContainer.compositeManager)
    }
}
