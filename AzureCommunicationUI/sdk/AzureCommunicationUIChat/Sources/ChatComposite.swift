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
        public var onNewUnreadMessages: ((Int) -> Void)?
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
    private var avatarViewManager: AvatarViewManagerProtocol?
    private var remoteParticipantsManager: RemoteParticipantsManagerProtocol?
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
        let chatConfiguration = ChatConfiguration(
            locator: remoteOptions.locator,
            communicationIdentifier: remoteOptions.communicationIdentifier,
            credential: remoteOptions.credential,
            displayName: remoteOptions.displayName)

        launch(chatConfiguration, localOptions: localOptions)
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
        guard let avatarManager = avatarViewManager else {
            completionHandler?(.failure(SetParticipantViewDataError.participantNotInChat))
            return
        }
        avatarManager.set(remoteParticipantViewData: remoteParticipantViewData,
                          for: identifier,
                          completionHandler: completionHandler)
    }

    public func showCompositeUI() throws {
        guard let dependencyContainer = dependencyContainer else {
            throw ChatCompositeError(code: ChatCompositeErrorCode.showComposite)
        }

        let localizationProvider = dependencyContainer.resolve() as LocalizationProviderProtocol

        let toolkitHostingController = makeToolkitHostingController(router: dependencyContainer.resolve(),
                                                                    logger: dependencyContainer.resolve(),
                                                                    viewFactory: dependencyContainer.resolve(),
                                                                    isRightToLeft: localizationProvider.isRightToLeft,
                                                                    canDismiss: true)
        try present(toolkitHostingController)
    }

    public func stop() {
        compositeManager?.stop() { [weak self] in
            self?.cleanUpComposite()
        }
    }

    public func hideCompositeUI() {
        // Public API interface placeholder for API view
    }

    /// Get Chat Composite UIViewController.
    /// - Returns: Chat Composite UIViewController
    public func getCompositeViewController() throws -> UIViewController {
        guard let dependencyContainer = dependencyContainer else {
            throw ChatCompositeError(code: ChatCompositeErrorCode.showComposite)
        }

        let localizationProvider = dependencyContainer.resolve() as LocalizationProviderProtocol
        return makeToolkitHostingController(router: dependencyContainer.resolve(),
                                            logger: dependencyContainer.resolve(),
                                            viewFactory: dependencyContainer.resolve(),
                                            isRightToLeft: localizationProvider.isRightToLeft,
                                            canDismiss: false)
    }

    /// Get Chat Composite SwiftUI view.
    /// - Returns: Chat Composite view
    public func getCompositeView() throws -> some View {
        guard let dependencyContainer = dependencyContainer else {
            throw ChatCompositeError(code: ChatCompositeErrorCode.showComposite)
        }

        let localizationProvider = dependencyContainer.resolve() as LocalizationProviderProtocol
        let router = dependencyContainer.resolve() as NavigationRouter

        router.setDismissComposite { [weak self] in
            self?.events.onNavigateBack?()
        }

        // need to add functionality implemented in ContainerUIHostingController
        return ContainerView(router: router,
                             logger: dependencyContainer.resolve(),
                             viewFactory: dependencyContainer.resolve(),
                             isRightToLeft: localizationProvider.isRightToLeft)
    }

    private func launch(_ chatConfiguration: ChatConfiguration,
                        localOptions: LocalOptions?) {
        let dependencyCon = DependencyContainer()
        logger = dependencyCon.resolve() as Logger
        logger?.debug("launch composite experience")

        dependencyCon.registerDependencies(chatConfiguration,
                                           localOptions: localOptions,
                                           chatCompositeEventsHandler: events)
        let localizationProvider = dependencyCon.resolve() as LocalizationProviderProtocol
        setupColorTheming()
        setupLocalization(with: localizationProvider)
        setupManagers(with: dependencyCon)

        dependencyContainer = dependencyCon
        compositeManager?.start()

//        guard !(localOptions?.isLaunchingWithUI ?? false) else {
//            return
//        }
//
//        do {
//            try showCompositeUI()
//        } catch {
//            logger?.debug("Failed in displaying UI")
//        }

    }

    private func setupManagers(with dependencyContainer: DependencyContainer) {
        self.errorManager = dependencyContainer.resolve() as ErrorManagerProtocol
        self.lifeCycleManager = dependencyContainer.resolve() as LifeCycleManagerProtocol
        self.avatarViewManager = dependencyContainer.resolve() as AvatarViewManager
        self.remoteParticipantsManager = dependencyContainer.resolve() as RemoteParticipantsManager
        self.compositeManager = dependencyContainer.resolve() as CompositeManagerProtocol
    }

    private func cleanUpComposite() {
        self.errorManager = nil
        self.lifeCycleManager = nil
        self.avatarViewManager = nil
        self.remoteParticipantsManager = nil
        self.compositeManager = nil
        self.dependencyContainer = nil
    }

    private func makeToolkitHostingController(router: NavigationRouter,
                                              logger: Logger,
                                              viewFactory: CompositeViewFactoryProtocol,
                                              isRightToLeft: Bool,
                                              canDismiss: Bool) -> ContainerUIHostingController {
        let rootView = ContainerView(router: router,
                                     logger: logger,
                                     viewFactory: viewFactory,
                                     isRightToLeft: isRightToLeft)
        let toolkitHostingController = ContainerUIHostingController(rootView: rootView,
                                                                    chatComposite: self,
                                                                    isRightToLeft: isRightToLeft)
        toolkitHostingController.modalPresentationStyle = .fullScreen

        router.setDismissComposite { [weak toolkitHostingController, weak self] in
            if canDismiss {
                toolkitHostingController?.dismissSelf()
            }
            self?.events.onNavigateBack?()
        }

        return toolkitHostingController
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

    private func setupColorTheming() {
        let colorProvider = ColorThemeProvider(themeOptions: themeOptions)
        StyleProvider.color = colorProvider
        DispatchQueue.main.async {
            if let window = UIWindow.keyWindow {
                Colors.setProvider(provider: colorProvider, for: window)
            }
        }
    }

    private func setupLocalization(with provider: LocalizationProviderProtocol) {
        if let localizationOptions = localizationOptions {
            provider.apply(localeConfig: localizationOptions)
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
