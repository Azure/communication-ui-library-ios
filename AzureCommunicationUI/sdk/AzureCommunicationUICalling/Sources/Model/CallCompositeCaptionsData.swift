//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import AzureCommunicationCalling

enum CallCompositeCaptionsType: Int {
    case none
    case communication
    case teams
}
enum CaptionsResultType {
    case final
    case partial
}

enum CallCompositeCaptionsErrors: Int {
    case none
    case captionsNotActive
    case getCaptionsFailedCallStateNotConnected
    case captionsFailedToStart
    case captionsFailedToStop
    case captionsFailedToSetSpokenLanguage
    case failedToSetCaptionLanguage
    case captionsPolicyDisabled
    case captionsDisabledByConfigurations
    case setCaptionLanguageDisabled
    case setCaptionLanguageTeamsPremiumLicenseNeeded
}

struct CallCompositeCaptionsData {
    let resultType: CaptionsResultType
    let speakerRawId: String
    let speakerName: String
    let spokenLanguage: String
    let spokenText: String
    let timestamp: Date
    let captionLanguage: String?
    let captionText: String?
}

extension AzureCommunicationCalling.TeamsCaptionsReceivedEventArgs {
    func toCallCompositeCaptionsData() -> CallCompositeCaptionsData {
        return CallCompositeCaptionsData(
            resultType: resultType.toCaptionsResultType(),
            speakerRawId: speaker.identifier.rawId,
            speakerName: speaker.displayName,
            spokenLanguage: spokenLanguage,
            spokenText: spokenText,
            timestamp: timestamp,
            captionLanguage: captionLanguage,
            captionText: captionText
        )
    }
}

 extension AzureCommunicationCalling.CommunicationCaptionsReceivedEventArgs {
    func toCallCompositeCaptionsData() -> CallCompositeCaptionsData {
        return CallCompositeCaptionsData(
            resultType: resultType.toCaptionsResultType(),
            speakerRawId: speaker.identifier.rawId,
            speakerName: speaker.displayName,
            spokenLanguage: spokenLanguage,
            spokenText: spokenText,
            timestamp: timestamp,
            captionLanguage: nil,
            captionText: nil
        )
    }
 }

extension AzureCommunicationCalling.CaptionsResultType {
    func toCaptionsResultType() -> CaptionsResultType {
        switch self {
        case .final:
            return .final
        case .partial:
            return .partial
        default:
            return .final
        }
    }
}

extension AzureCommunicationCalling.CaptionsType {
    func toCaptionsType() -> CallCompositeCaptionsType {
        switch self {
        case .teamsCaptions:
            return .teams
        case .communicationCaptions:
            return .communication
        default:
            return .none
        }
    }
}

extension AzureCommunicationCalling.CallingCommunicationErrors {
    func toCallCompositeCaptionsErrors() -> CallCompositeCaptionsErrors {
        switch self {
        case .captionsNotActive:
            return .captionsNotActive
        case .getCaptionsFailedCallStateNotConnected:
            return .getCaptionsFailedCallStateNotConnected
        case .captionsFailedToStart:
            return .captionsFailedToStart
//        case .captionsFailedToStop:
//            return .captionsFailedToStop
        case .captionsFailedToSetSpokenLanguage:
            return .captionsFailedToSetSpokenLanguage
        case .failedToSetCaptionLanguage:
            return .failedToSetCaptionLanguage
        case .captionsPolicyDisabled:
            return .captionsPolicyDisabled
        case .captionsDisabledByConfigurations:
            return .captionsDisabledByConfigurations
//        case .captionsSetSpokenLanguageDisabled:
//            return .captionsSetSpokenLanguageDisabled
        case .setCaptionLanguageDisabled:
            return .setCaptionLanguageDisabled
        case .setCaptionLanguageTeamsPremiumLicenseNeeded:
            return .setCaptionLanguageTeamsPremiumLicenseNeeded
        default:
            return .none
        }
    }
}
