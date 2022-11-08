//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import UIKit
import SwiftUI
import FluentUI
import AzureCommunicationCommon

/// The main class representing the entry point for the Chat Composite.
public class ChatComposite {

    /// The class to configure events closures for Chat Composite.
    public class Events {
        /// Closure to execute when error event occurs inside Chat Composite.
        public var onError: ((ChatCompositeError) -> Void)?
        /// Closures to execute when participant has joined a chat inside Chat Composite.
        public var onRemoteParticipantJoined: (([CommunicationIdentifier]) -> Void)?
        /// Closure to execute when participant navigate back to hide Chat Composite UI
        public var onUnreadMessagesCountChanged: ((Int) -> Void)?
        /// Closure to execute when Chat Composite UI is hidden and receive new message
        public var onNewMessageReceived: ((ChatMessageModel) -> Void)?
    }

    /// The events handler for Chat Composite
    public let events: Events
    private var logger: Logger?
    private let themeOptions: ThemeOptions?
    var dependencyContainer: DependencyContainer
    private var chatConfiguration: ChatConfiguration
    private var localOptions: LocalOptions?
    private let localizationOptions: LocalizationOptions?
    private var errorManager: ErrorManagerProtocol?
    private var lifeCycleManager: LifeCycleManagerProtocol?
    private var compositeManager: CompositeManagerProtocol

    /// Create an instance of ChatComposite with options.
    /// - Parameter options: The ChatCompositeOptions used to configure the experience.
    public init(withOptions options: ChatCompositeOptions? = nil,
                remoteOptions: RemoteOptions,
                localOptions: LocalOptions? = nil) {
        self.events = Events()
        self.themeOptions = options?.themeOptions
        self.localizationOptions = options?.localizationOptions
        self.localOptions = localOptions
        self.chatConfiguration = ChatConfiguration(
            threadId: remoteOptions.threadId,
            communicationIdentifier: remoteOptions.communicationIdentifier,
            credential: remoteOptions.credential,
            endpoint: remoteOptions.endpointUrl,
            displayName: remoteOptions.displayName)
        self.dependencyContainer = DependencyContainer()
        self.logger = self.dependencyContainer.resolve() as Logger
        self.dependencyContainer.registerDependencies(chatConfiguration,
                                          localOptions: localOptions,
                                          chatCompositeEventsHandler: events)

        self.errorManager = self.dependencyContainer.resolve() as ErrorManagerProtocol
        self.lifeCycleManager = self.dependencyContainer.resolve() as LifeCycleManagerProtocol
        self.compositeManager = self.dependencyContainer.resolve() as CompositeManagerProtocol
    }

    deinit {
        logger?.debug("Composite deallocated")
    }

    /// Start connection to the chat composite to Azure Communication Service.
    public func connect() {
        compositeManager.start()
    }

    /// Set ParticipantViewData to be displayed for the remote participant. This is data is not sent up to ACS.
    /// - Parameters:
    ///   - remoteParticipantViewData: ParticipantViewData used to set the participant's information for the chat.
    ///   - identifier: The communication identifier for the remote participant.
    ///   - completionHandler: The completion handler that receives `Result` enum value with either
    ///                        a `Void` or an `SetParticipantViewDataError`.
    public func set(remoteParticipantViewData: ParticipantViewData,
                    for identifier: CommunicationIdentifier,
                    completionHandler: ((Result<Void, SetParticipantViewDataError>) -> Void)? = nil) {
        // stub: to be implemented
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
                                                                        chatComposite: self,
                                                                        isRightToLeft: isRightToLeft)
        containerUIHostingController.modalPresentationStyle = .fullScreen

        return containerUIHostingController
    }

    private func present(_ viewController: UIViewController) throws {
        guard self.isCompositePresentable(),
              let topViewController = UIWindow.keyWindow?.topViewController else {
            throw ChatCompositeError(code: ChatCompositeErrorCode.showComposite)
        }

        DispatchQueue.main.async {
            viewController.transitioningDelegate = viewController as? ContainerUIHostingController
            topViewController.present(viewController, animated: true, completion: nil)
        }
    }

    private func isCompositePresentable() -> Bool {
        guard let keyWindow = UIWindow.keyWindow else {
            return false
        }

        let hasChatComposite = keyWindow.hasViewController(ofKind: ContainerUIHostingController.self)
        return !hasChatComposite
    }
}
