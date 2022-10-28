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

        XCTAssertNotNil(dependencyContainer.resolve() as Logger)
    }

    func test_dependencyContainer_registerExperienceDependencies_thenExperienceDependenciesAreRegistered() {
        let dependencyContainer = DependencyContainer()

        let sampleToken = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjMyNTAzNjgwMDAwfQ.9i7FNNHHJT8cOzo-yrAUJyBSfJ-tPPk2emcHavOEpWc"
        let communicationTokenCredential = try? CommunicationTokenCredential(token: sampleToken)
        let communicationIdentifier = CommunicationUserIdentifier("id")
        let displayName = ""
        let chatConfiguration = try? ChatConfiguration(
            locator: .groupChat(threadId: "threadId", endpoint: "endpoint"),
            communicationIdentifier: communicationIdentifier,
            credential: communicationTokenCredential!,
            displayName: displayName)

        let callCompositeEventsHandler = ChatComposite.Events()

        dependencyContainer.registerDependencies(chatConfiguration!,
                                                 localOptions: nil,
                                                 chatCompositeEventsHandler: callCompositeEventsHandler)

        XCTAssertNotNil(dependencyContainer.resolve() as ChatSDKEventsHandling)
        XCTAssertNotNil(dependencyContainer.resolve() as ChatSDKWrapperProtocol)
        XCTAssertNotNil(dependencyContainer.resolve() as ChatServiceProtocol)
        XCTAssertNotNil(dependencyContainer.resolve() as MessageRepositoryManagerProtocol)
        XCTAssertNotNil(dependencyContainer.resolve() as Store<AppState>)
        XCTAssertNotNil(dependencyContainer.resolve() as NavigationRouter)
        XCTAssertNotNil(dependencyContainer.resolve() as AccessibilityProviderProtocol)
        XCTAssertNotNil(dependencyContainer.resolve() as LocalizationProviderProtocol)
        XCTAssertNotNil(dependencyContainer.resolve() as CompositeViewModelFactoryProtocol)
        XCTAssertNotNil(dependencyContainer.resolve() as CompositeViewFactoryProtocol)
        XCTAssertNotNil(dependencyContainer.resolve() as ErrorManagerProtocol)
        XCTAssertNotNil(dependencyContainer.resolve() as LifeCycleManagerProtocol)
        XCTAssertNotNil(dependencyContainer.resolve() as CompositeManagerProtocol)
        XCTAssertNotNil(dependencyContainer.resolve() as TypingIndicatorManagerProtocol)
    }
}
