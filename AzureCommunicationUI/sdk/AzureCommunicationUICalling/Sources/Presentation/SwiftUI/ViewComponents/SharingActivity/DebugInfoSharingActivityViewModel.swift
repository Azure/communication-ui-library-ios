//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

class DebugInfoSharingActivityViewModel {
    let accessibilityProvider: AccessibilityProviderProtocol
    let debugInfoManager: DebugInfoManagerProtocol

    init(accessibilityProvider: AccessibilityProviderProtocol,
         debugInfoManager: DebugInfoManagerProtocol) {
        self.accessibilityProvider = accessibilityProvider
        self.debugInfoManager = debugInfoManager
    }

    func getDebugInfo() -> String {
        let debugInfo = debugInfoManager.getDebugInfo()
        let callId = debugInfo.callHistoryRecords.last?.callIds.last ??
            StringConstants.defaultCallIdDebugInfoValue
        return "\(StringConstants.callIdDebugInfoTitle) \"\(callId)\""
    }
}
