//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
@testable import AzureCommunicationUICalling

class DebugInfoManagerMocking: DebugInfoManagerProtocol {
    var debugInfo: DebugInfo?

    func getDebugInfo() -> DebugInfo {
        return debugInfo ?? DebugInfo(callHistoryRecords: [])
    }
}
