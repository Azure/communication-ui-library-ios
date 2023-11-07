//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import AzureCommunicationUICalling
import SwiftUI

enum EnvConfig: String {
    case aadToken
    case appCenterSecret
    case acsToken
    case userId
    case acsTokenUrl
    case expiredAcsToken
    case displayName
    case groupCallId
    case teamsMeetingLink
    case threadId
    case endpointUrl

    func value() -> String {
        guard let infoDict = Bundle.main.infoDictionary,
              let value = infoDict[rawValue] as? String else {
            return ""
        }
        return value
    }
}

class EnvConfigSubject: ObservableObject {
    @Published var aadToken: String = EnvConfig.aadToken.value()
    @Published var appCenterSecret: String = EnvConfig.appCenterSecret.value()
    @Published var acsToken: String = EnvConfig.acsToken.value()
    @Published var expiredAcsToken: String = EnvConfig.expiredAcsToken.value()
    @Published var acsTokenUrl: String = EnvConfig.acsTokenUrl.value()
    @Published var displayName: String = EnvConfig.displayName.value()
    @Published var userId: String = EnvConfig.userId.value()
    @Published var avatarImageName: String = ""
    @Published var renderedDisplayName: String = ""
    @Published var navigationTitle: String = ""
    @Published var navigationSubtitle: String = ""
    @Published var groupCallId: String = EnvConfig.groupCallId.value()
    @Published var teamsMeetingLink: String = EnvConfig.teamsMeetingLink.value()
    @Published var threadId: String = EnvConfig.threadId.value()
    @Published var endpointUrl: String = EnvConfig.endpointUrl.value()

    @Published var selectedAcsTokenType: ACSTokenType = .token
    @Published var selectedMeetingType: MeetingType = .groupCall
    @Published var selectedChatType: ChatType = .groupChat
    @Published var locale: Locale = SupportedLocale.en
    @Published var setupViewOrientation: OrientationOptions = .portrait
    @Published var callingViewOrientation: OrientationOptions = .allButUpsideDown
    @Published var localeIdentifier: String = ""
    @Published var exitCompositeAfterDuration: String = ""
    @Published var isRightToLeft: Bool = false
    @Published var microphoneOn: Bool = false
    @Published var cameraOn: Bool = false
    @Published var skipSetupScreen: Bool = false
    @Published var useCustomColors: Bool = false
    @Published var useCustomRemoteParticipantViewData: Bool = false
    @Published var useMockCallingSDKHandler: Bool = false
    @Published var useRelaunchOnDismissedToggle: Bool = false
    @Published var enableRemoteHold: Bool = true
    @Published var enableCallKit: Bool = true
    @Published var enableRemoteInfo: Bool = true
    @Published var callkitRemoteInfo: String = ""
    @Published var useExpiredToken: Bool = false
    @Published var primaryColor: Color = .blue
    @Published var tint10: Color = .blue
    @Published var tint20: Color = .blue
    @Published var tint30: Color = .blue
    @Published var colorSchemeOverride: UIUserInterfaceStyle = .unspecified

    func update(from dic: [String: String]) {
        if let token = dic["acstoken"],
           !token.isEmpty {
            acsToken = token
            selectedAcsTokenType = .token
        }

        if let name = dic["name"],
           !name.isEmpty {
            displayName = name
        }

        if let groupId = dic["groupid"],
           !groupId.isEmpty {
            groupCallId = groupId
            selectedMeetingType = .groupCall
        }

        if let teamsLink = dic["teamsurl"],
           !teamsLink.isEmpty {
            teamsMeetingLink = teamsLink
            selectedMeetingType = .teamsMeeting
            selectedChatType = .teamsChat
        }

        if let communicationUserId = dic["userid"],
           !communicationUserId.isEmpty {
            userId = communicationUserId
        }

        if let chatThreadId = dic["threadid"],
           !chatThreadId.isEmpty {
            threadId = chatThreadId
            selectedChatType = .groupChat
        }

        if let acsEndpointUrl = dic["endpointurl"],
           !acsEndpointUrl.isEmpty {
            endpointUrl = acsEndpointUrl
        }
    }
}
