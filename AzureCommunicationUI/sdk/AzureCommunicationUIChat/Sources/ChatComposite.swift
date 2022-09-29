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
        public var onNavigateBack: (() -> Void)?
        /// Closure to execute when Chat Composite UI is hidden and receive new message
        public var onUnreadMessagesCountChanged: ((Int) -> Void)?
        /// Closure to execute when Chat Composite UI is hidden and receive new message
        public var onNewMessageReceived: ((ChatMessageModel) -> Void)?
    }

    /// The events handler for Chat Composite
    public let events: Events
    private var logger: Logger?
    private let themeOptions: ThemeOptions?
    private var dependencyContainer: DependencyContainer?
    private let localizationOptions: LocalizationOptions?
    private var errorManager: ErrorManagerProtocol?
    private var lifeCycleManager: LifeCycleManagerProtocol?
    private var compositeManager: CompositeManagerProtocol?

    /// Create an instance of ChatComposite with options.
    /// - Parameter options: The ChatCompositeOptions used to configure the experience.
    public init(withOptions options: ChatCompositeOptions? = nil) {
        events = Events()
        themeOptions = options?.themeOptions
        localizationOptions = options?.localizationOptions
    }

    deinit {
        logger?.debug("Composite deallocated")
    }

    /// Start chat composite experience with joining a chat.
    /// - Parameter remoteOptions: RemoteOptions used to send to ACS to locate the chat.
    /// - Parameter localOptions: LocalOptions used to set the user participants information for the chat.
    ///                           This is data is not sent up to ACS.
    public func launch(remoteOptions: RemoteOptions,
                       localOptions: LocalOptions? = nil) {
        do {
            let chatConfiguration = try ChatConfiguration(
                locator: remoteOptions.locator,
                communicationIdentifier: remoteOptions.communicationIdentifier,
                credential: remoteOptions.credential,
                displayName: remoteOptions.displayName)
            launch(chatConfiguration,
                   localOptions: localOptions)
        } catch let error {
            print("Failed to launch, reason: \(error.localizedDescription)")
        }
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

    public func showCompositeUI() throws {
        guard let dependencyContainer = dependencyContainer else {
            throw ChatCompositeError(code: ChatCompositeErrorCode.showComposite)
        }

        let localizationProvider = dependencyContainer.resolve() as LocalizationProviderProtocol

        let containerUIHostingController = makeContainerUIHostingController(router: dependencyContainer.resolve(),
                                                                    logger: dependencyContainer.resolve(),
                                                                    viewFactory: dependencyContainer.resolve(),
                                                                    isRightToLeft: localizationProvider.isRightToLeft,
                                                                    canDismiss: true)
        try present(containerUIHostingController)
    }

    public func stop() {
        // stub: to be implemented
    }

    /// Get Chat Composite UIViewController.
    /// - Returns: Chat Composite UIViewController
    public func getCompositeViewController() throws -> UIViewController {
        throw ChatCompositeError(code: ChatCompositeErrorCode.showComposite)
        // stub: to be implemented
    }

    /// Get Chat Composite SwiftUI view.
    /// - Returns: Chat Composite view
    public func getCompositeView() throws -> some View {
        throw ChatCompositeError(code: ChatCompositeErrorCode.showComposite)
        // stub: to be implemented
        return Group {}
    }

    private func launch(_ chatConfiguration: ChatConfiguration,
                        localOptions: LocalOptions?) {
        let dependencyCon = DependencyContainer()
        logger = dependencyCon.resolve() as Logger
        logger?.debug("launch composite experience")

        dependencyCon.registerDependencies(chatConfiguration,
                                           localOptions: localOptions,
                                           chatCompositeEventsHandler: events)

        setupManagers(with: dependencyCon)

        dependencyContainer = dependencyCon
        compositeManager?.start()

        // Private preview:
        // - will show UI when launch
        // - will dismiss composite when navigate back
        do {
            try showCompositeUI()
        } catch {
            logger?.debug("Failed in displaying UI")
        }

    }

    private func setupManagers(with dependencyContainer: DependencyContainer) {
        self.errorManager = dependencyContainer.resolve() as ErrorManagerProtocol
        self.lifeCycleManager = dependencyContainer.resolve() as LifeCycleManagerProtocol
        self.compositeManager = dependencyContainer.resolve() as CompositeManagerProtocol
    }

    private func makeContainerUIHostingController(router: NavigationRouter,
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

        router.setDismissComposite { [weak containerUIHostingController, weak self] in
            if canDismiss {
                containerUIHostingController?.dismissSelf()
            }
        }

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
