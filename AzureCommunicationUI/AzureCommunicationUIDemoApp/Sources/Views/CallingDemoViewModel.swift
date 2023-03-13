//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
#if DEBUG
@testable import AzureCommunicationUICalling
#else
import AzureCommunicationUICalling
#endif

class CallingDemoViewModel: ObservableObject {
    lazy var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return dateFormatter
    }()

    var callHistoryTitle: String {
        return "Total calls: \(callHistory.count)"
    }

    var callHistoryMessage: String {
        var callHistoryMessage = "Last Call: none"
        if let lastHistoryRecord = callHistory.last {
            let formattedDate = dateFormatter.string(from: lastHistoryRecord.callStartedOn)
            callHistoryMessage = "Last Call: \(formattedDate)\n"
            callHistoryMessage += "Call Ids:\n"
            callHistoryMessage += lastHistoryRecord.callIds.joined(separator: "\n")
        }
        return callHistoryMessage
    }

    var callHistory: [CallHistoryRecord] {
        let callComposite = CallComposite()
        let debugInfo = callComposite.debugInfo
        let callHistory = debugInfo.callHistoryRecords
        return callHistory
    }
}
