//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import SwiftUI
import AzureCommunicationUICalling
import AzureCommunicationUIChat
import AzureCommunicationCommon

class CallWithChatDemoViewModel: ObservableObject {
    var chatAdapter: ChatAdapter?
    var callComposite: CallComposite?
    @Published var loadingChat: Bool = false
    @Published var isStartExperienceLoading: Bool = false
    @Published var envConfigSubject: EnvConfigSubject
    @Published var errorMessage: String = ""
    @Published var isErrorDisplayed: Bool = false

    init(envConfigSubject: EnvConfigSubject) {
        self.envConfigSubject = envConfigSubject
    }

    @MainActor
    func startCallComposite() async {
        let link = getMeetingLink()

        var localizationConfig: LocalizationOptions?
        let layoutDirection: LayoutDirection = envConfigSubject.isRightToLeft ? .rightToLeft : .leftToRight
        if !envConfigSubject.localeIdentifier.isEmpty {
            let locale = Locale(identifier: envConfigSubject.localeIdentifier)
            localizationConfig = LocalizationOptions(locale: locale,
                                                     layoutDirection: layoutDirection)
        } else if !envConfigSubject.locale.identifier.isEmpty {
            localizationConfig = LocalizationOptions(
                locale: envConfigSubject.locale,
                layoutDirection: layoutDirection)
        }

        let callCompositeOptions = CallCompositeOptions(
            theme: envConfigSubject.useCustomColors
            ? CustomColorTheming(envConfigSubject: envConfigSubject)
            : Theming(envConfigSubject: envConfigSubject),
            localization: localizationConfig,
            customizationOptions: createCustomizationOption())

        let callComposite = CallComposite(withOptions: callCompositeOptions)
        self.callComposite = callComposite

        let onRemoteParticipantJoinedHandler: ([CommunicationIdentifier]) -> Void = { [weak self] ids in
            guard let composite = self?.callComposite else {
                return
            }
            self?.onRemoteParticipantJoined(to: composite,
                                            identifiers: ids)
        }
        let onErrorHandler: (CallCompositeError) -> Void = { [weak self] error in
            guard let composite = self?.callComposite else {
                return
            }
            self?.onError(error,
                          callComposite: composite)
        }
        callComposite.events.onRemoteParticipantJoined = onRemoteParticipantJoinedHandler
        callComposite.events.onError = onErrorHandler
        callComposite.events.onCallStatusChanged = { [weak self] status in
            guard let self else {
                return
            }
            switch status {
            case .connected:
                if !self.loadingChat && self.chatAdapter == nil {
                    self.loadingChat = true
                    Task { @MainActor in
                        await self.startChatComposite()
                    }
                }
            case .disconnected:
                guard let chatAdapter = self.chatAdapter else {
                    self.callComposite = nil
                    return
                }
                Task { @MainActor in
                    do {
                        try await chatAdapter.disconnect()
                        self.chatAdapter = nil
                    } catch {
                        print("Chat disconnect error \(error)")
                    }
                    self.callComposite = nil
                }

            default:
                print(status)
            }
        }

        let renderDisplayName = envConfigSubject.renderedDisplayName.isEmpty ?
        nil:envConfigSubject.renderedDisplayName
        let participantViewData = ParticipantViewData(avatar: UIImage(named: envConfigSubject.avatarImageName),
                                                      displayName: renderDisplayName)
        let setupScreenViewData = SetupScreenViewData(title: envConfigSubject.navigationTitle,
                                                      subtitle: envConfigSubject.navigationSubtitle)
        let localOptions = LocalOptions(participantViewData: participantViewData,
                                        setupScreenViewData: setupScreenViewData)
        if let credential = try? await getTokenCredential() {
            switch envConfigSubject.selectedMeetingType {
            case .groupCall:
                let uuid = UUID(uuidString: link) ?? UUID()
                if envConfigSubject.displayName.isEmpty {
                    callComposite.launch(remoteOptions: RemoteOptions(for: .groupCall(groupId: uuid),
                                                                      credential: credential),
                                         localOptions: localOptions)
                } else {
                    callComposite.launch(remoteOptions: RemoteOptions(for: .groupCall(groupId: uuid),
                                                                      credential: credential,
                                                                      displayName: envConfigSubject.displayName),
                                         localOptions: localOptions)
                }
            case .teamsMeeting:
                if envConfigSubject.displayName.isEmpty {
                    callComposite.launch(remoteOptions: RemoteOptions(for: .teamsMeeting(teamsLink: link),
                                                                      credential: credential),
                                         localOptions: localOptions)
                } else {
                    callComposite.launch(remoteOptions: RemoteOptions(for: .teamsMeeting(teamsLink: link),
                                                                      credential: credential,
                                                                      displayName: envConfigSubject.displayName),
                                         localOptions: localOptions)
                }
            }
        } else {
            showCallError(for: DemoError.invalidToken.getErrorCode())
            return
        }
    }

    @MainActor
    func startChatComposite() async {
        loadingChat = true
        let communicationIdentifier = CommunicationUserIdentifier(envConfigSubject.userId)
        guard let communicationTokenCredential = try? await self.getTokenCredential(),
              let teamsMeetingLink = envConfigSubject.teamsMeetingLink.removingPercentEncoding else {
                  return
              }
        var threadId = ""
        switch envConfigSubject.selectedMeetingType {
        case .groupCall:
            threadId = envConfigSubject.threadId
        case .teamsMeeting:
            if let threadMatcher = try? NSRegularExpression(
                pattern: "(.*meetup-join\\/)(?<threadId>19.*)(\\/.*)"
            ) {
                let matches = threadMatcher.matches(
                    in: teamsMeetingLink,
                    range: NSRange(
                        teamsMeetingLink.startIndex..<teamsMeetingLink.endIndex,
                        in: teamsMeetingLink
                    )
                )
                if let matchedRange = matches.first?.range(withName: "threadId"),
                   let substringRange = Range(matchedRange, in: teamsMeetingLink) {
                    threadId = String(teamsMeetingLink[substringRange])
                }
            } else {
                fatalError("Regular expression is invalid!")
            }
        }
        self.chatAdapter = ChatAdapter(
            endpoint: envConfigSubject.endpointUrl,
            identifier: communicationIdentifier,
            credential: communicationTokenCredential,
            threadId: threadId,
            displayName: envConfigSubject.displayName)
        guard let chatAdapter = self.chatAdapter else {
            return
        }
        chatAdapter.events.onError = { [weak self] error in
            self?.showChatError(error: error)
        }
        do {
            try await chatAdapter.connect()
            print("Chat connected")
        } catch {
            print(error)
        }
        loadingChat = false
    }

    private func getTokenCredential() async throws -> CommunicationTokenCredential {
        switch envConfigSubject.selectedAcsTokenType {
        case .token:
            let acsToken = envConfigSubject.useExpiredToken ?
            envConfigSubject.expiredAcsToken : envConfigSubject.acsToken
            if let communicationTokenCredential = try? CommunicationTokenCredential(token: acsToken) {
                return communicationTokenCredential
            } else {
                throw DemoError.invalidToken
            }
        case .tokenUrl:
            if let url = URL(string: envConfigSubject.acsTokenUrl) {
                let tokenRefresher = AuthenticationHelper.getCommunicationToken(tokenUrl: url,
                                                                                aadToken: envConfigSubject.aadToken)
                let initialToken = await AuthenticationHelper.fetchInitialToken(with: tokenRefresher)
                let communicationTokenRefreshOptions = CommunicationTokenRefreshOptions(initialToken: initialToken,
                                                                                        refreshProactively: true,
                                                                                        tokenRefresher: tokenRefresher)
                if let credential = try? CommunicationTokenCredential(withOptions: communicationTokenRefreshOptions) {
                    return credential
                }
            }
            throw DemoError.invalidToken
        }
    }

    private func getMeetingLink() -> String {
        switch envConfigSubject.selectedMeetingType {
        case .groupCall:
            return envConfigSubject.groupCallId
        case .teamsMeeting:
            return envConfigSubject.teamsMeetingLink
        }
    }

    private func showCallError(for errorCode: String) {
        switch errorCode {
        case CallCompositeErrorCode.tokenExpired:
            errorMessage = "Token is invalid"
        default:
            errorMessage = "Unknown error"
        }
        isErrorDisplayed = true
    }

    private func onError(_ error: CallCompositeError, callComposite: CallComposite) {
        print("::::CallWithChatDemoView::getEventsHandler::onError \(error)")
        print("::::CallWithChatDemoView error.code \(error.code)")
        print("::::CallWithChatDemoView debug info \(callComposite.debugInfo.currentOrLastCallId ?? "Unknown")")
        showCallError(for: error.code)
    }

    private func onRemoteParticipantJoined(to callComposite: CallComposite, identifiers: [CommunicationIdentifier]) {
        print("::::CallWithChatDemoView::getEventsHandler::onRemoteParticipantJoined \(identifiers)")
        guard envConfigSubject.useCustomRemoteParticipantViewData else {
            return
        }

        RemoteParticipantAvatarHelper.onRemoteParticipantJoined(to: callComposite,
                                                                identifiers: identifiers)
    }

    private func showChatError(error: ChatCompositeError) {
        print("::::CallWithChatDemoView::showChatError \(error)")
        print("::::CallWithChatDemoView error.code \(error.code)")
        print("Error - \(error.code): \(error.error?.localizedDescription ?? error.localizedDescription)")
        switch error.code {
        case ChatCompositeErrorCode.joinFailed:
            errorMessage = "Connection Failed"
        case ChatCompositeErrorCode.disconnectFailed:
            errorMessage = "Disconnect Failed"
        case ChatCompositeErrorCode.sendMessageFailed,
            ChatCompositeErrorCode.fetchMessagesFailed,
            ChatCompositeErrorCode.requestParticipantsFetchFailed,
            ChatCompositeErrorCode.sendReadReceiptFailed,
            ChatCompositeErrorCode.sendTypingIndicatorFailed,
            ChatCompositeErrorCode.disconnectFailed:
            // no alert
            return
        default:
            errorMessage = "Unknown error"
        }
        isErrorDisplayed = true
    }

    var isStartExperienceDisabled: Bool {
        let acsToken = envConfigSubject.useExpiredToken ? envConfigSubject.expiredAcsToken :
        envConfigSubject.acsToken
        if (envConfigSubject.selectedAcsTokenType == .token && acsToken.isEmpty)
            || envConfigSubject.selectedAcsTokenType == .tokenUrl && envConfigSubject.acsTokenUrl.isEmpty {
            return true
        }

        let groupIsStartExperienceDisabledCheck = envConfigSubject.selectedMeetingType == .groupCall
        && (envConfigSubject.groupCallId.isEmpty || envConfigSubject.threadId.isEmpty)
        let teamsIsStartExperienceDisabledCheck = (envConfigSubject.selectedMeetingType == .teamsMeeting
                                                   && envConfigSubject.teamsMeetingLink.isEmpty)

        if groupIsStartExperienceDisabledCheck || teamsIsStartExperienceDisabledCheck {
            return true
        }

        return false
    }

    func startExperience() {
        isStartExperienceLoading = true
        Task { @MainActor in
            await self.startCallComposite()
            self.isStartExperienceLoading = false
        }
    }

    func hideError() {
        isErrorDisplayed = false
    }

    private func createCustomizationOption() -> CustomizationOptions {
        let messageBtnState = getMessageButtonViewData()
//        return CustomizationOptions(customButtonViewData: [])
        return CustomizationOptions(customButtonViewData: [messageBtnState])
    }

    private func getMessageButtonViewData() -> CustomButtonViewData {
        let state = CustomButtonViewData(
            type: .callingViewInfoHeader,
            image: UIImage(named: "messageIcon")!,
            label: "messageIcon") { _ in
                guard let callComposite = self.callComposite,
                      let chatCompositeAdaptor = self.chatAdapter else {
                    return
                }

                let chatCompositeView = ChatCompositeView(with: chatCompositeAdaptor)
                    .navigationTitle("Chat")
                    .navigationBarTitleDisplayMode(.inline)
                callComposite.setOverlay(overlay: {
                    NavigationView {
                        VStack(spacing: 0) {
                            Divider()
                            chatCompositeView
                                .navigationTitle("Chat")
                                .navigationBarTitleDisplayMode(.inline)
                                .toolbar {
                                    ToolbarItem(placement: .navigationBarLeading) {
                                        Button {
                                            callComposite.removeOverlay()
                                        } label: {
                                            Text("Back")
                                        }
                                    }
                                }
                        }
                    }
                    .transition(.move(edge: .trailing))
                })
        }

        return state
    }
}
