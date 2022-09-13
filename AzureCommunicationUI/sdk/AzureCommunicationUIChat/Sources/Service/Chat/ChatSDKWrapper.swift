//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import Combine
import AzureCore
import AzureCommunicationChat

class ChatSDKWrapper: NSObject, ChatSDKWrapperProtocol {
    let chatEventsHandler: ChatSDKEventsHandling

    private let logger: Logger
    private let chatConfiguration: ChatConfiguration
    private var chatClient: ChatClient?
    private var chatThreadClient: ChatThreadClient?
    private var pagedCollection: PagedCollection<ChatMessage>?

    init(logger: Logger,
         chatEventsHandler: ChatSDKEventsHandling,
         chatConfiguration: ChatConfiguration) {
        self.logger = logger
        self.chatEventsHandler = chatEventsHandler
        self.chatConfiguration = chatConfiguration
        super.init()
    }

    deinit {
        logger.debug("CallingSDKWrapper deallocated")
    }

    func chatStart() async throws -> [ChatMessageInfoModel] {
        do {
            createChatClient()
            createChatThreadClient()
            startChat()
            return []
        } catch {
            throw error
        }
    }

    func createChatClient() {
        do {
            print("Creating Chat Client...")
            self.chatClient = try ChatClient(
                endpoint: self.chatConfiguration.endpoint,
                credential: self.chatConfiguration.credential,
                withOptions: AzureCommunicationChatClientOptions())
        } catch {
            print("Create Chat Client failed: \(error.localizedDescription)")
        }
    }

    func createChatThreadClient() {
        print("Creating Chat Thread Client...")
        do {
            self.chatThreadClient = try chatClient?.createClient(
                                    forThread: self.chatConfiguration.chatThreadId)
        } catch {
            print("Create Chat Thread Client failed: \(error.localizedDescription)")
        }
    }

    func startChat() {
        self.chatClient?.startRealTimeNotifications { [self] result in
            switch result {
            case .success:
                print("Real-time notifications started.")
                self.registerEvents()
            case .failure:
                print("Failed to start real-time notifications.")
            }
        }
    }

    func registerEvents() {
        print("Register events not implemented")
    }
}
