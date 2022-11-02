//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
@testable import AzureCommunicationUICalling

class DiagnosticsManagerMocking: DiagnosticsManagerProtocol {
    var diagnosticsInfo: DiagnosticsInfo?

    func getDiagnosticsInfo() -> DiagnosticsInfo {
        return diagnosticsInfo ?? DiagnosticsInfo()
    }
}
