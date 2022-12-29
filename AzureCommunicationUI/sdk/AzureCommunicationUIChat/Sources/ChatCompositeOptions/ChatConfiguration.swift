//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import AzureCommunicationCommon
import Foundation

struct ChatConfiguration {
    let endpoint: String
    let identifier: CommunicationIdentifier
    let credential: CommunicationTokenCredential
    let displayName: String?
    let diagnosticConfig: DiagnosticConfig
    let pageSize: Int32 = 100

    init(endpoint: String,
         identifier: CommunicationIdentifier,
         credential: CommunicationTokenCredential,
         displayName: String?) {
        self.identifier = identifier
        self.credential = credential
        self.endpoint = endpoint
        self.displayName = displayName
        self.diagnosticConfig = DiagnosticConfig()
    }
}
