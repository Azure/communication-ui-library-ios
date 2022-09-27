//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//
import AzureCommunicationUICalling
import AzureCommunicationUIChat
import AzureCommunicationCommon

public class ChatMessage {
    // added temporary, needs to be added and renamed when merged code from Chat spike
}

public class CallWithChatComposite {
    /// The class to configure events closures for CallWithChat Composite.
    public class Events {
        /// Closure to execute when error event occurs inside CallWithChat Composite.
        public var onError: ((CallWithChatCompositeError) -> Void)?
        /// Closures to execute when participant has joined a call or a chat inside CallWithChat Composite.
        public var onRemoteParticipantJoined: (([CommunicationIdentifier]) -> Void)?
        public var onNewMessagesReceived: (([ChatMessage]) -> Void)?
        public var onUnreadMessagesCountUpdated: ((Int) -> Void)?
    }
    public let events: Events

    private let themeOptions: ThemeOptions?
    private let localizationOptions: LocalizationOptions?
    private var callComposite: CallComposite?
    private var chatComposite: ChatComposite?

    public init(withOptions options: CallWithChatCompositeOptions? = nil) {
        events = Events()
        themeOptions = options?.themeOptions
        localizationOptions = options?.localizationOptions
    }

    public func launch(remoteOptions: RemoteOptions,
                       localOptions: LocalOptions? = nil) {
        launchCallComposite(remoteOptions: remoteOptions,
                            localOptions: localOptions)

        launchChatComposite(remoteOptions: remoteOptions,
                            localOptions: localOptions)
    }

    public func set(remoteParticipantViewData: ParticipantViewData,
                    for identifier: CommunicationIdentifier,
                    completionHandler: ((Result<Void, SetParticipantViewDataError>) -> Void)? = nil) {
        callComposite?.set(remoteParticipantViewData: remoteParticipantViewData.getCallCompositeParticipantViewData(),
                           for: identifier,
                           completionHandler: { result in
            switch result {
            case .failure(let error):
                completionHandler?(.failure(error.getCallWithChatCompositeSetParticipantViewDataError()))
            case .success:
                completionHandler?(.success(Void()))
            }
        })
    }

    private func launchCallComposite(remoteOptions: RemoteOptions,
                                     localOptions: LocalOptions? = nil) {
        let callThemeOption = themeOptions?.getCallCompositeThemeOptions()
        let callLocalizationOptions = localizationOptions?.getCallCompositeLocalizationOptions()
        let options = CallCompositeOptions(theme: callThemeOption,
                                           localization: callLocalizationOptions,
                                           controlsOptions: createCustomizationOption())
        callComposite = CallComposite(withOptions: options)
        callComposite?.launch(remoteOptions: remoteOptions.getCallCompositeRemoteOptions(),
                              localOptions: localOptions?.getCallCompositeLocalOptions())
    }

    private func launchChatComposite(remoteOptions: RemoteOptions,
                                     localOptions: LocalOptions? = nil) {
        let chatThemeOption = themeOptions?.getChatCompositeThemeOptions()
        let chatLocalizationOptions = localizationOptions?.getChatCompositeLocalizationOptions()
        let chatCompositeOption = ChatCompositeOptions(theme: chatThemeOption,
                                                       localization: chatLocalizationOptions)
        chatComposite = ChatComposite(withOptions: chatCompositeOption)
        chatComposite?.launch(remoteOptions: remoteOptions.getChatCompositeRemoteOptions(),
                              localOptions: localOptions?.getChatCompositeLocalOptions())
        chatComposite?.events.onNavigateBack = { [weak self] in
            self?.callComposite?.removeOverlay()
        }

    }

    private func createCustomizationOption() -> ControlsOptions {
        let messageBtnState = getMessageButtonViewData()
        return ControlsOptions(customButtonViewData: [messageBtnState])
    }

    private func getMessageButtonViewData() -> CustomButtonViewData {
        let state = CustomButtonViewData(type: .callingViewInfoHeader,
                                         image: UIImage(named: "messageIcon")!,
                                         label: "messageIcon",
                                         badgeNumber: 0) { [weak self] _ in
            guard let self = self else {
                return
            }

//            guard let chatCompositeView = try? self.chatComposite?.getCompositeView() else {
//                print("Couldn't show Chat Composite UI")
//                return
//            }
            guard let chatCompositeViewController = try? self.chatComposite?.getCompositeViewController() else {
                print("Couldn't show Chat Composite UI")
                return
            }

            let pipOptions = PIPViewOptions(
                isDraggable: true,
                pipDraggableAreaMargins: UIEdgeInsets(top: 65, left: 12, bottom: 75, right: 12),
                defaultPosition: .bottomRight)
            let overlayOptions = OverlayOptions(overlayTransition: .move(edge: .trailing),
                                                showPIP: true,
                                                pipViewOptions: pipOptions)
            self.callComposite?.setOverlay(chatCompositeViewController,
                                           overlayOptions: overlayOptions)
            // SwiftUI version
//            self.callComposite?.setOverlay(overlayOptions: overlayOptions, overlay: {
//                chatCompositeView
//            })
        }

        return state
    }
}
