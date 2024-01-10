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
    case roomId
    case threadId
    case endpointUrl
    case participantIds
    case roomRole

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
    @Published var roomId: String = EnvConfig.roomId.value()
    @Published var threadId: String = EnvConfig.threadId.value()
    @Published var endpointUrl: String = EnvConfig.endpointUrl.value()
    @Published var participantIds: String = EnvConfig.participantIds.value()
    @Published var deviceToken: Data?

    @Published var selectedAcsTokenType: ACSTokenType = .token
    @Published var selectedMeetingType: MeetingType = .groupCall
    @Published var selectedRoomRoleType: RoomRoleType = .presenter
    @Published var selectedChatType: ChatType = .groupChat
    @Published var locale: Locale = SupportedLocale.en
    @Published var setupViewOrientation: OrientationOptions?
    @Published var callingViewOrientation: OrientationOptions?
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

    let acstokenKey: String = "ACS_TOKEN"
    let displayNameKey: String = "DISPLAY_NAME"
    let groupIdKey: String = "GROUP_ID"
    let teamsUrlKey: String = "TEAMS_URL"
    let oneToNCallKey: String = "ONE_N_CALL_IDS"

    // swiftlint:disable explicit_type_interface
    let userDefault = UserDefaults.standard
    // swiftlint:enable explicit_type_interface

    private func readStringData(key: String) -> String {
        if userDefault.object(forKey: key) == nil {
            return ""
        } else {
            return userDefault.string(forKey: key)!
        }
    }

    private func writeAnyData(key: String, value: Any) {
        userDefault.set(value, forKey: key)
        userDefault.synchronize()
    }

    func saveFromState() {
        if !acsToken.isEmpty {
            // We need to make a service call to get token for user in case application is not running
            // Storing token in shared preferences for demo purpose as this app is not public
            // In production, token should be fetched from server (storing token in pref can be a security issue)
            writeAnyData(key: acstokenKey, value: acsToken)
        }
        if !displayName.isEmpty {
            writeAnyData(key: displayNameKey, value: displayName)
        }
        if !groupCallId.isEmpty {
            writeAnyData(key: groupIdKey, value: groupCallId)
        }
        if !teamsMeetingLink.isEmpty {
            writeAnyData(key: teamsUrlKey, value: teamsMeetingLink)
        }
        if !participantIds.isEmpty {
            writeAnyData(key: oneToNCallKey, value: participantIds)
        }
    }

    func load() {
        if !readStringData(key: acstokenKey).isEmpty && acsToken.isEmpty {
            acsToken = readStringData(key: acstokenKey)
            selectedAcsTokenType = .token
        }
        if !readStringData(key: displayNameKey).isEmpty && displayName.isEmpty {
            displayName = readStringData(key: displayNameKey)
        }
        if !readStringData(key: groupIdKey).isEmpty && groupCallId.isEmpty {
            groupCallId = readStringData(key: groupIdKey)
        }
        if !readStringData(key: teamsUrlKey).isEmpty && teamsMeetingLink.isEmpty {
            teamsMeetingLink = readStringData(key: teamsUrlKey)
        }
        if !readStringData(key: oneToNCallKey).isEmpty && participantIds.isEmpty {
            participantIds = readStringData(key: oneToNCallKey)
        }
    }

    func update(from dic: [String: String]) {
        if let token = dic["acstoken"],
           !token.isEmpty {
            acsToken = token
            selectedAcsTokenType = .token
            // We need to make a service call to get token for user in case application is not running
            // Storing token in shared preferences for demo purpose as this app is not public
            // In production, token should be fetched from server (storing token in pref can be a security issue)
            writeAnyData(key: acstokenKey, value: token)
        }

        if let name = dic["name"],
           !name.isEmpty {
            displayName = name
            writeAnyData(key: displayNameKey, value: name)
        }

        if let groupId = dic["groupid"],
           !groupId.isEmpty {
            groupCallId = groupId
            selectedMeetingType = .groupCall
            writeAnyData(key: groupIdKey, value: groupId)
        }

        if let teamsLink = dic["teamsurl"],
           !teamsLink.isEmpty {
            teamsMeetingLink = teamsLink
            selectedMeetingType = .teamsMeeting
            selectedChatType = .teamsChat
            writeAnyData(key: teamsUrlKey, value: teamsLink)
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

        if let oneToNCId = dic["oneToNCallingId"],
           !participantIds.isEmpty {
            participantIds = oneToNCId
            selectedMeetingType = .oneToNCall
            writeAnyData(key: oneToNCallKey, value: oneToNCId)
        }
    }
}
