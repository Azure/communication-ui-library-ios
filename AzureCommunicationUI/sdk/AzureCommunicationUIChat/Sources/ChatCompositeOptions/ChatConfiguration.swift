//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import AzureCommunicationCommon
import Foundation

struct ChatConfiguration {
    var chatThreadId: String
    let endpoint: String
    let communicationIdentifier: CommunicationIdentifier
    let credential: CommunicationTokenCredential
    let displayName: String?
    let diagnosticConfig: DiagnosticConfig
    let pageSize: Int32 = 10

    init(communicationIdentifier: CommunicationIdentifier,
         credential: CommunicationTokenCredential,
         endpoint: String,
         displayName: String?) {
        self.chatThreadId = ""
        self.communicationIdentifier = communicationIdentifier
        self.credential = credential
        self.endpoint = endpoint
        self.displayName = displayName
        self.diagnosticConfig = DiagnosticConfig()
    }
}
