//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

class DiagnosticsSharingActivityViewModel {
    let accessibilityProvider: AccessibilityProviderProtocol
    let diagnosticsManager: DiagnosticsManagerProtocol

    init(accessibilityProvider: AccessibilityProviderProtocol,
         diagnosticsManager: DiagnosticsManagerProtocol) {
        self.accessibilityProvider = accessibilityProvider
        self.diagnosticsManager = diagnosticsManager
    }

    func getDiagnosticsInfo() -> String {
        let diagnosticsInfo = diagnosticsManager.getDiagnosticsInfo()
        let callId = diagnosticsInfo.lastKnownCallId ?? StringConstants.defaultCallIdDiagnosticsViewValue
        return "\(StringConstants.callIdDiagnosticsViewTitle) \"\(callId)\""
    }
}
