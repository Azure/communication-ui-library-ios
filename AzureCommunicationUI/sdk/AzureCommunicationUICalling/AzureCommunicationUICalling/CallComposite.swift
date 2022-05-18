//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import UIKit
import SwiftUI
import FluentUI
import AzureCommunicationCalling

/// The main class representing the entry point for the Call Composite.
public class CallComposite {
    private var logger: Logger?
    private let themeConfiguration: ThemeConfiguration?
    private let localizationConfiguration: LocalizationConfiguration?
    private let callCompositeEventsHandler = CallCompositeEventsHandler()
    private var errorManager: ErrorManagerProtocol?
    private var lifeCycleManager: LifeCycleManagerProtocol?
    private var permissionManager: PermissionsManagerProtocol?
    private var audioSessionManager: AudioSessionManagerProtocol?

    /// Create an instance of CallComposite with options.
    /// - Parameter options: The CallCompositeOptions used to configure the experience.
    public init(withOptions options: CallCompositeOptions? = nil) {
        themeConfiguration = options?.themeConfiguration
        localizationConfiguration = options?.localizationConfiguration
    }

    /// Assign closure to execute when an error occurs inside Call Composite.
    /// - Parameter action: The closure returning the error thrown from Call Composite.
    public func setTarget(didFail action: ((CommunicationUIErrorEvent) -> Void)?) {
        callCompositeEventsHandler.didFail = action
    }

    deinit {
        logger?.debug("Composite deallocated")
    }

    private func launch(_ callConfiguration: CallConfiguration,
                        localSettings: LocalSettings?) {
        let dependencyContainer = DependencyContainer()
        logger = dependencyContainer.resolve() as Logger
        logger?.debug("launch composite experience")

        dependencyContainer.registerDependencies(callConfiguration, localSettings: localSettings)
        let localizationProvider = dependencyContainer.resolve() as LocalizationProviderProtocol
        setupColorTheming()
        setupLocalization(with: localizationProvider)
        let toolkitHostingController = makeToolkitHostingController(router: dependencyContainer.resolve(),
                                                                    logger: dependencyContainer.resolve(),
                                                                    viewFactory: dependencyContainer.resolve(),
                                                                    isRightToLeft: localizationProvider.isRightToLeft)
        setupManagers(store: dependencyContainer.resolve(),
                      containerHostingController: toolkitHostingController,
                      logger: dependencyContainer.resolve())
        present(toolkitHostingController)
    }

    /// Start call composite experience with joining a group call.
    /// - Parameter options: The GroupCallOptions used to locate the group call.
    /// - Parameter localSettings: LocalSettings used to set the user participants information for the call.
    ///                            This is data is not sent up to ACS.
    public func launch(with options: GroupCallOptions,
                       localSettings: LocalSettings? = nil) {
        let callConfiguration = CallConfiguration(
            credential: options.credential,
            groupId: options.groupId,
            displayName: options.displayName)

        launch(callConfiguration, localSettings: localSettings)
    }

    /// Start call composite experience with joining a Teams meeting..
    /// - Parameter options: The TeamsMeetingOptions used to locate the Teams meetings.
    /// - Parameter localSettings: LocalSettings used to set the user participants information for the call.
    ///                            This is data is not sent up to ACS.
    public func launch(with options: TeamsMeetingOptions,
                       localSettings: LocalSettings? = nil) {
        let callConfiguration = CallConfiguration(
            credential: options.credential,
            meetingLink: options.meetingLink,
            displayName: options.displayName)

        launch(callConfiguration, localSettings: localSettings)
    }

    private func setupManagers(store: Store<AppState>,
                               containerHostingController: ContainerUIHostingController,
                               logger: Logger) {
        let errorManager = CompositeErrorManager(store: store,
                                                 callCompositeEventsHandler: callCompositeEventsHandler)
        self.errorManager = errorManager

        let lifeCycleManager = UIKitAppLifeCycleManager(store: store, logger: logger)
        self.lifeCycleManager = lifeCycleManager

        let permissionManager = PermissionsManager(store: store)
        self.permissionManager = permissionManager

        let audioSessionManager = AudioSessionManager(store: store,
                                                         logger: logger)
        self.audioSessionManager = audioSessionManager
    }

    private func cleanUpManagers() {
        self.errorManager = nil
        self.lifeCycleManager = nil
        self.permissionManager = nil
        self.audioSessionManager = nil
    }

    private func makeToolkitHostingController(router: NavigationRouter,
                                              logger: Logger,
                                              viewFactory: CompositeViewFactoryProtocol,
                                              isRightToLeft: Bool) -> ContainerUIHostingController {
        let rootView = ContainerView(router: router,
                                     logger: logger,
                                     viewFactory: viewFactory,
                                     isRightToLeft: isRightToLeft)
        let toolkitHostingController = ContainerUIHostingController(rootView: rootView,
                                                                    callComposite: self,
                                                                    isRightToLeft: isRightToLeft)
        toolkitHostingController.modalPresentationStyle = .fullScreen

        router.setDismissComposite { [weak toolkitHostingController, weak self] in
            toolkitHostingController?.dismissSelf()
            self?.cleanUpManagers()
        }

        return toolkitHostingController
    }

    private func present(_ viewController: UIViewController) {
        DispatchQueue.main.async {
            guard self.isCompositePresentable(),
                  let topViewController = UIWindow.keyWindow?.topViewController else {
                // go to throw the error in the delegate handler
                return
            }
            topViewController.present(viewController, animated: true, completion: nil)
        }
    }

    private func setupColorTheming() {
        let colorProvider = ColorThemeProvider(themeConfiguration: themeConfiguration)
        StyleProvider.color = colorProvider
        DispatchQueue.main.async {
            if let window = UIWindow.keyWindow {
                Colors.setProvider(provider: colorProvider, for: window)
            }
        }
    }

    private func setupLocalization(with provider: LocalizationProviderProtocol) {
        if let localizationConfiguration = localizationConfiguration {
            provider.apply(localeConfig: localizationConfiguration)
        }
    }

    private func isCompositePresentable() -> Bool {
        guard let keyWindow = UIWindow.keyWindow else {
            return false
        }
        let hasCallComposite = keyWindow.hasViewController(ofKind: ContainerUIHostingController.self)

        return !hasCallComposite
    }
}
