//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import AzureCommunicationCommon
import Foundation

struct ChatConfiguration {
    var chatThreadId: String
    let endpoint: String
    let identifier: CommunicationIdentifier
    let credential: CommunicationTokenCredential
    let displayName: String?
    let diagnosticConfig: DiagnosticConfig
    let pageSize: Int32 = 100

    init(identifier: CommunicationIdentifier,
         credential: CommunicationTokenCredential,
         endpoint: String,
         displayName: String?) {
        self.chatThreadId = ""
        self.identifier = identifier
        self.credential = credential
        self.endpoint = endpoint
        self.displayName = displayName
        self.diagnosticConfig = DiagnosticConfig()
    }
}
