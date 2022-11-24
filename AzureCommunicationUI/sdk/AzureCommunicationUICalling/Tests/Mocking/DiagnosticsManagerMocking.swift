//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
@testable import AzureCommunicationUICalling

class DiagnosticsManagerMocking: DiagnosticsManagerProtocol {
    var diagnosticsInfo: CallDiagnostics?

    func getDiagnosticsInfo() -> CallDiagnostics {
        return diagnosticsInfo ?? CallDiagnostics()
    }
}
