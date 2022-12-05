//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

public class ChatThreadAdapter {

    let client: ChatUIClient
    var logger: Logger
    public private(set) var threadId: String
    public private(set) var topic: String

    public init(chatUIClient: ChatUIClient,
                threadId: String) {
        self.client = chatUIClient
        self.logger = chatUIClient.logger
        self.threadId = threadId
        self.topic = "topic placeholder"

        chatUIClient.connect(threadId: threadId) { _ in
            self.logger.info("Chat connect completionHandler called")
        }
    }
}
