//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import UIKit
import SwiftUI
import FluentUI
import AzureCommunicationCalling

public typealias CompositeErrorHandler = (CallCompositeErrorEvent) -> Void
public typealias RemoteParticipantsJoinedHandler = ([CommunicationIdentifier]) -> Void

/// The main class representing the entry point for the Call Composite.
public class CallComposite {
    private var logger: Logger?
    private let themeOptions: ThemeOptions?
    private let localizationOptions: LocalizationOptions?
    private let callCompositeEventsHandler: CallCompositeEventsHandling
    private var errorManager: ErrorManagerProtocol?
    private var lifeCycleManager: LifeCycleManagerProtocol?
    private var permissionManager: PermissionsManagerProtocol?
    private var audioSessionManager: AudioSessionManagerProtocol?
    private var remoteParticipantsManager: RemoteParticipantsManagerProtocol?
    private var avatarViewManager: AvatarViewManagerProtocol?

    /// Create an instance of CallComposite with options.
    /// - Parameter options: The CallCompositeOptions used to configure the experience.
    public init(withOptions options: CallCompositeOptions? = nil) {
        callCompositeEventsHandler = CallCompositeEventsHandler()
        themeOptions = options?.themeOptions
        localizationOptions = options?.localizationOptions
    }

    /// Assign closures to execute when error event  occurs inside Call Composite.
    /// - Parameter didFailAction: The closure returning the error thrown from Call Composite.
    public func setDidFailHandler(with didFailAction: CompositeErrorHandler?) {
        callCompositeEventsHandler.didFail = didFailAction
    }

    /// Assign closures to execute when participant has joined a call  inside Call Composite.
    /// - Parameter participantsJoinedAction: The closure returning identifiers for joined remote participants.
    public func setRemoteParticipantJoinHandler(with participantsJoinedAction: RemoteParticipantsJoinedHandler?) {
        callCompositeEventsHandler.didRemoteParticipantsJoin = participantsJoinedAction
    }

    deinit {
        logger?.debug("Composite deallocated")
    }

    private func launch(_ callConfiguration: CallConfiguration,
                        localOptions: LocalOptions?) {
        let dependencyContainer = DependencyContainer()
        logger = dependencyContainer.resolve() as Logger
        logger?.debug("launch composite experience")

        dependencyContainer.registerDependencies(callConfiguration,
                                                 localOptions: localOptions,
                                                 callCompositeEventsHandler: callCompositeEventsHandler)
        let localizationProvider = dependencyContainer.resolve() as LocalizationProviderProtocol
        setupColorTheming()
        setupLocalization(with: localizationProvider)
        let toolkitHostingController = makeToolkitHostingController(router: dependencyContainer.resolve(),
                                                                    logger: dependencyContainer.resolve(),
                                                                    viewFactory: dependencyContainer.resolve(),
                                                                    isRightToLeft: localizationProvider.isRightToLeft)
        setupManagers(with: dependencyContainer)
        present(toolkitHostingController)
    }

    /// Start call composite experience with joining a group call.
    /// - Parameter options: The GroupCallOptions used to locate the group call.
    /// - Parameter localOptions: LocalOptions used to set the user participants information for the call.
    ///                            This is data is not sent up to ACS.
    public func launch(with options: GroupCallOptions,
                       localOptions: LocalOptions? = nil) {
        let callConfiguration = CallConfiguration(
            credential: options.credential,
            groupId: options.groupId,
            displayName: options.displayName)

        launch(callConfiguration, localOptions: localOptions)
    }

    /// Start call composite experience with joining a Teams meeting.
    /// - Parameter options: The TeamsMeetingOptions used to locate the Teams meetings.
    /// - Parameter localOptions: LocalOptions used to set the user participants information for the call.
    ///                            This is data is not sent up to ACS.
    public func launch(with options: TeamsMeetingOptions,
                       localOptions: LocalOptions? = nil) {
        let callConfiguration = CallConfiguration(
            credential: options.credential,
            meetingLink: options.meetingLink,
            displayName: options.displayName)

        launch(callConfiguration, localOptions: localOptions)
    }

    /// Set ParticipantViewData for the remote participant.
    /// - Parameters:
    ///   - identifier: The communication identifier for the remote participant.
    ///   - participantViewData: ParticipantViewData used to set the user participants information for the call.
    ///   This is data is not sent up to ACS.
    /// - Returns: The `Result` enum value with either a `Void` or an `Error`.
    @discardableResult
    public func setRemoteParticipantViewData(
        for identifier: CommunicationIdentifier,
        participantViewData: ParticipantViewData) -> Result<Void, CallCompositeErrorEvent> {
        guard let avatarManager = avatarViewManager else {
            return .failure(CallCompositeErrorEvent(code: CallCompositeErrorCode.remoteParticipantNotFound))
        }

        return avatarManager.setRemoteParticipantViewData(for: identifier,
                                                          participantViewData: participantViewData)
    }

    private func setupManagers(with dependencyContainer: DependencyContainer) {
        self.errorManager = dependencyContainer.resolve() as ErrorManagerProtocol
        self.lifeCycleManager = dependencyContainer.resolve() as LifeCycleManagerProtocol
        self.permissionManager = dependencyContainer.resolve() as PermissionsManagerProtocol
        self.audioSessionManager = dependencyContainer.resolve() as AudioSessionManagerProtocol
        self.avatarViewManager = dependencyContainer.resolve() as AvatarViewManager
        self.remoteParticipantsManager = dependencyContainer.resolve() as RemoteParticipantsManager
    }

    private func cleanUpManagers() {
        self.errorManager = nil
        self.lifeCycleManager = nil
        self.permissionManager = nil
        self.audioSessionManager = nil
        self.remoteParticipantsManager = nil
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
        let hasCallComposite = keyWindow.hasViewController(ofKind: ContainerUIHostingController.self)

        return !hasCallComposite
    }
}
