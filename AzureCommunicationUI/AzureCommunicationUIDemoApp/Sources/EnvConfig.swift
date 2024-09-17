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
    case teamsMeetingId
    case teamsMeetingPasscode
    case threadId
    case endpointUrl
    case participantMRIs
    case skipTo
    case roomId

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
    @Published var teamsMeetingId: String = EnvConfig.teamsMeetingId.value()
    @Published var teamsMeetingPasscode: String = EnvConfig.teamsMeetingPasscode.value()
    /* <TIMER_TITLE_FEATURE> */
    @Published var callInformationTitle: String = ""
    @Published var customTitleApplyOnRemoteJoin: Int = 0
    @Published var callInformationSubtitle: String = ""
    @Published var customSubtitleApplyOnRemoteJoin: Int = 0
    /* </TIMER_TITLE_FEATURE> */
    @Published var participantMRIs: String = EnvConfig.participantMRIs.value()
    @Published var threadId: String = EnvConfig.threadId.value()
    @Published var endpointUrl: String = EnvConfig.endpointUrl.value()
    @Published var roomId: String = EnvConfig.roomId.value()
    @Published var selectedAcsTokenType: ACSTokenType = .token
    @Published var selectedMeetingType: MeetingType = .groupCall
    @Published var selectedChatType: ChatType = .groupChat
    @Published var locale: Locale = SupportedLocale.en
    @Published var spokenLanguage = ""
    @Published var setupViewOrientation: OrientationOptions = .portrait
    @Published var callingViewOrientation: OrientationOptions = .allButUpsideDown
    @Published var captionsOn = false
    @Published var addCustomButton = false
    @Published var hideAllButtons = false
    @Published var displayCaptions = true
    @Published var localeIdentifier: String = ""
    @Published var exitCompositeAfterDuration: String = ""
    @Published var isRightToLeft = false
    @Published var disableInternalPushForIncomingCall = false
    @Published var useDeprecatedLaunch = false
    @Published var microphoneOn = false
    @Published var cameraOn = false
    @Published var audioOnly = false
    @Published var skipSetupScreen = false
    @Published var displayLeaveCallConfirmation = true
    @Published var useCustomColors = false
    @Published var useCustomRemoteParticipantViewData = false
    @Published var useMockCallingSDKHandler = false
    @Published var useRelaunchOnDismissedToggle = false
    @Published var enableMultitasking = false
    @Published var enablePipWhenMultitasking = false
    @Published var useExpiredToken = false
    @Published var primaryColor: Color = .blue
    @Published var tint10: Color = .blue
    @Published var tint20: Color = .blue
    @Published var tint30: Color = .blue
    @Published var onPrimaryColor: Color = .white
    @Published var colorSchemeOverride: UIUserInterfaceStyle = .unspecified
    @Published var enableRemoteHold = true
    @Published var enableCallKit = true
    @Published var enableRemoteInfo = true
    @Published var callkitRemoteInfo = ""
    @Published var deviceToken: Data?
    @Published var setupScreenOptionsCameraButtonEnabled = true
    @Published var setupScreenOptionsMicButtonEnabled = true

    let acstokenKey: String = "ACS_TOKEN"
    let displayNameKey: String = "DISPLAY_NAME"
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
    }

    func load() {
        if !readStringData(key: acstokenKey).isEmpty && acsToken.isEmpty {
            acsToken = readStringData(key: acstokenKey)
            selectedAcsTokenType = .token
        }
        if !readStringData(key: displayNameKey).isEmpty && displayName.isEmpty {
            displayName = readStringData(key: displayNameKey)
        }
    }

    func update(from dic: [String: String]) {
        if let token = dic["acstoken"],
           !token.isEmpty {
            acsToken = token
            selectedAcsTokenType = .token
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
        }

        if let id = dic["roomid"],
           !id.isEmpty {
            roomId = id
            selectedMeetingType = .roomCall
        }

        if let teamsLink = dic["teamsurl"],
           !teamsLink.isEmpty {
            teamsMeetingLink = teamsLink
            selectedMeetingType = .teamsMeeting
            selectedChatType = .teamsChat
        }

        if let mris = dic["participantMRIs"],
           !participantMRIs.isEmpty {
            participantMRIs = mris
            selectedMeetingType = .oneToNCall
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
