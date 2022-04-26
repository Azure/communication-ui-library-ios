//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import AzureCommunicationUI
import SwiftUI

enum EnvConfig: String {
    case appCenterSecret
    case acsToken
    case acsTokenUrl
    case displayName
    case groupCallId
    case teamsMeetingLink

    func value() -> String {
        guard let infoDict = Bundle.main.infoDictionary,
              let value = infoDict[rawValue] as? String else {
            return ""
        }
        return value
    }
}

class EnvConfigSubject: ObservableObject {
    @Published var appCenterSecret: String = EnvConfig.appCenterSecret.value()
    @Published var acsToken: String = EnvConfig.acsToken.value()
    @Published var acsTokenUrl: String = EnvConfig.acsTokenUrl.value()
    @Published var displayName: String = EnvConfig.displayName.value()
    @Published var avatarImageName: String = ""
    @Published var renderedDisplayName: String = ""
    @Published var groupCallId: String = EnvConfig.groupCallId.value()
    @Published var teamsMeetingLink: String = EnvConfig.teamsMeetingLink.value()

    @Published var selectedAcsTokenType: ACSTokenType = .token
    @Published var selectedMeetingType: MeetingType = .groupCall
    @Published var languageCode: String = LocalizationConfiguration.LanguageCode.en.rawValue
    @Published var localeIdentifier: String = ""
    @Published var isRightToLeft: Bool = false
    @Published var useCustomColors: Bool = false
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
        }
    }
}
