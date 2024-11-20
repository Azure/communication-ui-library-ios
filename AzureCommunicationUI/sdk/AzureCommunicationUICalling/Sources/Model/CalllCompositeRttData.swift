//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import AzureCommunicationCalling

enum RttResultType {
    case final
    case partial
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
            senderRawId: senderRawId,
            senderName: senderName,
            text: text
        )
    }
}

struct CallCompositeRttCaptionsDisplayData: Equatable {
    let senderRawId: String
    let senderName: String
    let text: String

    static func == (lhs: CallCompositeRttCaptionsDisplayData, rhs: CallCompositeRttCaptionsDisplayData) -> Bool {
        return lhs.senderName == rhs.senderName &&
        lhs.senderRawId == rhs.senderRawId &&
        lhs.text == rhs.text
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
        senderRawId: "",
        senderName: "",
        sequenceId: sequenceId,
        text: text,
        localCreatedTime: localCreatedTime,
        localUpdatedTime: localUpdatedTime,
        isLocal: isLocal
       )
   }
}
