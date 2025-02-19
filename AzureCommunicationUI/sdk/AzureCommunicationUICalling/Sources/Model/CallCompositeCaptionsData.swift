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
    case captionsFailedToStart
    case captionsFailedToStop
    case captionsFailedToSetSpokenLanguage
    case captionsFailedToSetCaptionLanguage
}

/// Todo need to remove when Native SDK has the new error feature
enum CallCompositeCaptionsErrorsDescription: String {
    case captionsStartFailedCallNotConnected = "Get captions failed, call should be connected"
    case captionsStartFailedSpokenLanguageNotSupported = "The requested language is not supported"
    case captionsNotActive = " Captions are not active"
}

struct CallCompositeCaptionsData: Identifiable, Equatable {
    /// to make CallCompositeCaptionsData to be identifiable
    var id: Date { timestamp }

    var resultType: CaptionsResultType
    let speakerRawId: String
    let speakerName: String
    let spokenLanguage: String
    let spokenText: String
    let timestamp: Date
    let captionLanguage: String?
    let captionText: String?
    let displayText: String?

    static func == (lhs: CallCompositeCaptionsData, rhs: CallCompositeCaptionsData) -> Bool {
        // Define what makes two instances of CallCompositeCaptionsData equal
        return lhs.speakerRawId == rhs.speakerRawId &&
               lhs.resultType == rhs.resultType &&
               lhs.speakerName == rhs.speakerName &&
               lhs.spokenLanguage == rhs.spokenLanguage &&
               lhs.spokenText == rhs.spokenText &&
               lhs.captionLanguage == rhs.captionLanguage &&
               lhs.captionText == rhs.captionText
    }

    func toDisplayData() -> CaptionsRttRecord {
        CaptionsRttRecord(
            displayRawId: speakerRawId,
            displayName: speakerName,
            text: displayText ?? "",
            spokenText: spokenText,
            captionsText: captionText ?? "",
            spokenLanguage: spokenLanguage,
            captionsLanguage: captionLanguage,
            captionsRttType: .captions,
            createdTimestamp: timestamp,
            updatedTimestamp: timestamp,
            isFinal: resultType == .final,
            isLocal: false
        )
    }
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
            captionText: captionText,
            displayText: ""
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
            captionText: nil,
            displayText: nil
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
