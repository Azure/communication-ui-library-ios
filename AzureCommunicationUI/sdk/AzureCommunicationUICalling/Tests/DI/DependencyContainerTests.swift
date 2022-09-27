//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import XCTest
import AzureCommunicationCommon
@testable import AzureCommunicationUICalling

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
        let callConfiguration = CallConfiguration(locator: .groupCall(groupId: groupId),
                                                  credential: communicationTokenCredential!,
                                                  displayName: displayName)
        let participantViewData = ParticipantViewData(avatar: nil, displayName: nil)
        let localOptions = LocalOptions(participantViewData: participantViewData)
        let callCompositeEventsHandler = CallComposite.Events()

        dependencyContainer.registerDependencies(callConfiguration,
                                                 localOptions: localOptions,
                                                 callCompositeEventsHandler: callCompositeEventsHandler)

        XCTAssertNotNil(dependencyContainer.resolve() as CallingSDKWrapperProtocol)
        XCTAssertNotNil(dependencyContainer.resolve() as VideoViewManager)
        XCTAssertNotNil(dependencyContainer.resolve() as CallingServiceProtocol)
        XCTAssertNotNil(dependencyContainer.resolve() as Store<AppState>)
        XCTAssertNotNil(dependencyContainer.resolve() as NavigationRouter)
        XCTAssertNotNil(dependencyContainer.resolve() as CompositeViewModelFactoryProtocol)
        XCTAssertNotNil(dependencyContainer.resolve() as CompositeViewFactoryProtocol)
        XCTAssertNotNil(dependencyContainer.resolve() as CallingSDKEventsHandling)
        XCTAssertNotNil(dependencyContainer.resolve() as AccessibilityProviderProtocol)
        XCTAssertNotNil(dependencyContainer.resolve() as LocalizationProviderProtocol)
        XCTAssertNotNil(dependencyContainer.resolve() as ErrorManagerProtocol)
        XCTAssertNotNil(dependencyContainer.resolve() as LifeCycleManagerProtocol)
        XCTAssertNotNil(dependencyContainer.resolve() as PermissionsManagerProtocol)
        XCTAssertNotNil(dependencyContainer.resolve() as AudioSessionManagerProtocol)
        XCTAssertNotNil(dependencyContainer.resolve() as AvatarViewManager)
        XCTAssertNotNil(dependencyContainer.resolve() as RemoteParticipantsManagerProtocol)
        XCTAssertNotNil(dependencyContainer.resolve() as NetworkManager)
    }
}
