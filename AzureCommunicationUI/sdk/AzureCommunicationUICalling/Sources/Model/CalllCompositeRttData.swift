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

extension AzureCommunicationCalling.RealTimeTextInfoChangedEventArgs {
   func toCallCompositeRttData() -> CallCompositeRttData {
       return CallCompositeRttData(
        resultType: entry.resultType.toRttResultType(),
        senderRawId: entry.sender.identifier.rawId,
        senderName: entry.sender.displayName,
        sequenceId: entry.sequenceId,
        text: "",
        localCreatedTime: entry.localCreatedTime,
        localUpdatedTime: entry.localUpdatedTime,
        isLocal: entry.isLocal
       )
   }
}
