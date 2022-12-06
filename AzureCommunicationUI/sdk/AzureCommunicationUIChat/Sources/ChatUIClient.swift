//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import AzureCommunicationCommon
import FluentUI
import SwiftUI
import UIKit

/// The main class representing the entry point for the Chat Composite.
public class ChatUIClient {

    /// The class to configure events closures for Chat Composite.
    public class Events {
        /// Closure to execute when error event occurs inside Chat Composite for the Chat threadId.
        public var onError: ((String, ChatCompositeError) -> Void)?
        /// Closures to execute when participant has joined a chat inside Chat Composite.
        var onRemoteParticipantJoined: ((String, [CommunicationIdentifier]) -> Void)?
        /// Closure to execute when Chat Composite UI is hidden and receive new message
        var onUnreadMessagesCountChanged: ((String, Int) -> Void)?
        /// Closure to execute when Chat Composite UI is hidden and receive new message
        var onNewMessageReceived: ((String, ChatMessageModel) -> Void)?
    }

    /// The events handler for Chat Composite
    public let events: Events

    // Dependencies
    var logger: Logger = DefaultLogger(category: "ChatComponent")
    var accessibilityProvider: AccessibilityProviderProtocol = AccessibilityProvider()
    var localizationProvider: LocalizationProviderProtocol
    var chatConfiguration: ChatConfiguration
    private var themeOptions: ThemeOptions?

    /// Create an instance of ChatComposite with options.
    public init(identifier: CommunicationIdentifier,
                credential: CommunicationTokenCredential,
                endpoint: String,
                displayName: String? = nil) {
        localizationProvider = LocalizationProvider(logger: logger)

        self.chatConfiguration = ChatConfiguration(
            identifier: identifier,
            credential: credential,
            endpoint: endpoint,
            displayName: displayName)
        self.events = Events()
    }

    deinit {
        logger.debug("Composite deallocated")
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
