//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import AzureCommunicationCalling

enum RttResultType {
    case final
    case partial

    func toRttResultType() -> AzureCommunicationCalling.RealTimeTextResultType {
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

enum CaptionsRttType {
    case captions
    case rtt
}

struct CallCompositeRttData: Identifiable, Equatable {
    /// to make CallCompositeRttData to be identifiable
    var id: Date { localCreatedTime }

    var resultType: RttResultType
    let senderRawId: String
    let senderName: String
    let sequenceId: Int32
    let text: String
    let localCreatedTime: Date
    let localUpdatedTime: Date
    let isLocal: Bool

    static func == (lhs: CallCompositeRttData, rhs: CallCompositeRttData) -> Bool {
        // Define what makes two instances of CallCompositeRttData equal
        return lhs.isLocal == rhs.isLocal &&
        lhs.localCreatedTime == rhs.localCreatedTime &&
        lhs.localUpdatedTime == rhs.localUpdatedTime &&
        lhs.resultType == rhs.resultType &&
        lhs.sequenceId == rhs.sequenceId &&
        lhs.senderRawId == rhs.senderRawId &&
        lhs.senderName == rhs.senderName &&
        lhs.text == rhs.text
    }

    func toDisplayData() -> CallCompositeRttCaptionsDisplayData {
        CallCompositeRttCaptionsDisplayData(
            displayRawId: senderRawId,
            displayName: senderName,
            text: text,
            spokenText: "",
            captionsText: "",
            spokenLanguage: "",
            captionsLanguage: "",
            captionsRttType: .rtt,
            createdTimestamp: localCreatedTime,
            updatedTimestamp: localUpdatedTime,
            isFinal: resultType == .final,
            isRttInfo: false,
            isLocal: isLocal
        )
    }
}

struct CallCompositeRttCaptionsDisplayData: Identifiable, Equatable {
    var id: Date {
        return createdTimestamp
    }

    let displayRawId: String
    let displayName: String
    let text: String
    let spokenText: String
    let captionsText: String?
    let spokenLanguage: String
    let captionsLanguage: String?
    let captionsRttType: CaptionsRttType
    let createdTimestamp: Date
    let updatedTimestamp: Date
    var isFinal: Bool
    let isRttInfo: Bool?
    let isLocal: Bool

    static func == (lhs: CallCompositeRttCaptionsDisplayData, rhs: CallCompositeRttCaptionsDisplayData) -> Bool {
        return lhs.displayName == rhs.displayName &&
        lhs.displayRawId == rhs.displayRawId &&
        lhs.text == rhs.text &&
        lhs.captionsRttType == rhs.captionsRttType &&
        lhs.spokenText == rhs.spokenText &&
        lhs.captionsText == rhs.captionsText &&
        lhs.isFinal == rhs.isFinal &&
        lhs.createdTimestamp == rhs.createdTimestamp &&
        lhs.updatedTimestamp == rhs.updatedTimestamp &&
        lhs.spokenLanguage == rhs.spokenLanguage &&
        lhs.captionsLanguage == rhs.captionsLanguage &&
        lhs.isRttInfo == rhs.isRttInfo &&
        lhs.isLocal == rhs.isLocal
    }
}

extension AzureCommunicationCalling.RealTimeTextResultType {
    func toRttResultType() -> RttResultType {
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

struct CallerInfo: Equatable {
    let rawId: String
    let displayName: String

    static func == (lhs: CallerInfo, rhs: CallerInfo) -> Bool {
        return lhs.displayName == rhs.displayName &&
        lhs.rawId == rhs.rawId
    }
}

extension AzureCommunicationCalling.RealTimeTextInfo {
   func toCallCompositeRttData() -> CallCompositeRttData {
       return CallCompositeRttData(
        resultType: resultType.toRttResultType(),
        senderRawId: sender.identifier.rawId,
        senderName: sender.displayName,
        sequenceId: sequenceId,
        text: text,
        localCreatedTime: receivedTime,
        localUpdatedTime: updatedTime,
        isLocal: isLocal
       )
   }
}
