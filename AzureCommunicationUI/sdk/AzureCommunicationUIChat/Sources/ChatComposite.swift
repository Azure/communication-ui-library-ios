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
    private let localizationOptions: LocalizationOptions?

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
    }

    public func showCompositeUI() throws {
        throw ChatCompositeError(code: ChatCompositeErrorCode.showComposite)
    }

    public func stop() {
    }

    /// Get Chat Composite UIViewController.
    /// - Returns: Chat Composite UIViewController
    public func getCompositeViewController() throws -> UIViewController {
        throw ChatCompositeError(code: ChatCompositeErrorCode.showComposite)
    }

    /// Get Chat Composite SwiftUI view.
    /// - Returns: Chat Composite view
    public func getCompositeView() throws -> some View {
        throw ChatCompositeError(code: ChatCompositeErrorCode.showComposite)
        return Group {}
    }
}
