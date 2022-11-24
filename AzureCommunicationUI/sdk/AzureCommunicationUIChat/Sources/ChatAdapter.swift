//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import UIKit
import SwiftUI
import FluentUI
import AzureCommunicationCommon

/// The main class representing the entry point for the Chat Composite.
public class ChatAdapter {

    /// The class to configure events closures for Chat Composite.
    class Events {
        /// Closure to execute when error event occurs inside Chat Composite.
        var onError: ((ChatCompositeError) -> Void)?
        /// Closures to execute when participant has joined a chat inside Chat Composite.
        var onRemoteParticipantJoined: (([CommunicationIdentifier]) -> Void)?
        /// Closure to execute when Chat Composite UI is hidden and receive new message
        var onUnreadMessagesCountChanged: ((Int) -> Void)?
        /// Closure to execute when Chat Composite UI is hidden and receive new message
        var onNewMessageReceived: ((ChatMessageModel) -> Void)?
    }

    /// The events handler for Chat Composite
    let events: Events
    private var logger: Logger?
    private var themeOptions: ThemeOptions?
    var dependencyContainer: DependencyContainer
    private var chatConfiguration: ChatConfiguration
    private var errorManager: ErrorManagerProtocol?
    private var lifeCycleManager: LifeCycleManagerProtocol?
    private var compositeManager: CompositeManagerProtocol?

    /// Create an instance of ChatComposite with options.
    public init(identifier: CommunicationIdentifier,
                credential: CommunicationTokenCredential,
                endpoint: String,
                displayName: String? = nil) {
        self.chatConfiguration = ChatConfiguration(
            communicationIdentifier: identifier,
            credential: credential,
            endpoint: endpoint,
            displayName: displayName)
        self.events = Events()
        self.dependencyContainer = DependencyContainer()
    }

    deinit {
        logger?.debug("Composite deallocated")
    }

    /// Start connection to the chat composite to Azure Communication Service.
    public func connect(threadId: String,
                        completionHandler: ((Result<Void, ChatCompositeError>) -> Void)?) {
        self.chatConfiguration.chatThreadId = threadId
        self.logger = dependencyContainer.resolve() as Logger
        dependencyContainer.registerDependencies(self.chatConfiguration,
                                                 chatCompositeEventsHandler: events,
                                                 connectEventHandler: completionHandler)
        self.errorManager = dependencyContainer.resolve() as ErrorManagerProtocol
        self.lifeCycleManager = dependencyContainer.resolve() as LifeCycleManagerProtocol
        self.compositeManager = dependencyContainer.resolve() as CompositeManagerProtocol

        compositeManager?.start()
    }

    /// Start connection to the chat composite to Azure Communication Service.
    public func connect(threadId: String) async throws {
        return try await withCheckedThrowingContinuation { continuation in
            connect(threadId: threadId) { result in
                continuation.resume(with: result)
            }
        }
    }

    /// Stop connection to chat composite to Azure Communication Service
    public func disconnect() {
//    public func disconnect(threadId: String? = nil
//                           completionHandler: ((Result<Void, ChatCompositeError>) -> Void)? = nil) {

    }

    private func cleanUpComposite() {
        self.errorManager = nil
        self.lifeCycleManager = nil
    }

    func makeContainerUIHostingController(router: NavigationRouter,
                                          logger: Logger,
                                          viewFactory: CompositeViewFactoryProtocol,
                                          isRightToLeft: Bool,
                                          canDismiss: Bool) -> ContainerUIHostingController {
        let rootView = ContainerView(router: router,
                                     logger: logger,
                                     viewFactory: viewFactory,
                                     isRightToLeft: isRightToLeft)
        let containerUIHostingController = ContainerUIHostingController(rootView: rootView,
                                                                        chatAdapter: self,
                                                                        isRightToLeft: isRightToLeft)
        containerUIHostingController.modalPresentationStyle = .fullScreen

        return containerUIHostingController
    }
}
