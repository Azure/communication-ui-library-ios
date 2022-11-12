//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import AzureCommunicationCommon
import Foundation

struct ChatConfiguration {
    let chatThreadId: String
    let endpoint: String
    let compositeChatType: CompositeChatType
    let communicationIdentifier: CommunicationIdentifier
    let credential: CommunicationTokenCredential
    let displayName: String?
    let diagnosticConfig: DiagnosticConfig
    let pageSize: Int32 = 15 // 100

    init(locator: JoinLocator,
         communicationIdentifier: CommunicationIdentifier,
         credential: CommunicationTokenCredential,
         displayName: String?) throws {
        switch locator {
        case let .groupChat(threadId: threadId, endpoint: endpoint):
            self.chatThreadId = threadId
            self.endpoint = endpoint
            self.compositeChatType = .groupChat
        case let .teamsMeeting(teamsLink: meetingLink, endpoint: endpoint):
            guard let threadId = ChatConfiguration.getThreadId(from: meetingLink) else {
                throw ChatCompositeInternalError.parseThreadIdFailed
            }
            self.chatThreadId = threadId
            self.endpoint = endpoint
            self.compositeChatType = .teamsChat
        }
        self.communicationIdentifier = communicationIdentifier
        self.credential = credential
        self.displayName = displayName
        self.diagnosticConfig = DiagnosticConfig()
    }

    static func getThreadId(from meetingLink: String) -> String? {
        if let range = meetingLink.range(of: "meetup-join/") {
            let thread = meetingLink[range.upperBound...]
            if let endRange = thread.range(of: "/")?.lowerBound {
                return String(thread.prefix(upTo: endRange))
            }
        }
        return nil
    }
}

enum CompositeChatType {
    case groupChat
    case teamsChat
}
