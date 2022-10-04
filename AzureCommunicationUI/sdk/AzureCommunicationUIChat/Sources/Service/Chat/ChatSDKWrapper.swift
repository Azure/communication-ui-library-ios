//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import AzureCore
import AzureCommunicationChat
import Foundation

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

    func initializeChat() async throws {
        do {
            try createChatClient()
            try createChatThreadClient()

            // Make request to ChatSDK to verfy token
            // Sideeffect: topic send through Subject to middleware
            let topic = try await retrieveThreadTopic()
            print("topic: \(topic)")

            try registerRealTimeNotifications()
        } catch {
            throw error
        }
    }

    func getInitialMessages() async throws -> [ChatMessageInfoModel] {
        do {
            let listChatMessagesOptions = ListChatMessagesOptions(
                maxPageSize: chatConfiguration.pageSize)
            return try await withCheckedThrowingContinuation { continuation in
                chatThreadClient?.listMessages(withOptions: listChatMessagesOptions) { result, _ in
                    switch result {
                    case .success(let messagesResult):
                        self.pagedCollection = messagesResult
                        let messages = self.pagedCollection?.pageItems?
                            .map({ $0.toChatMessageInfoModel() })
                        continuation.resume(returning: messages?.reversed() ?? [])
                    case .failure(let error):
                        self.logger.error("Get Initial Messages failed: \(error)")
                        continuation.resume(throwing: error)
                    }
                }
            }
        } catch {
            logger.error("Retrieve Thread Topic failed: \(error)")
            throw error
        }
    }

    private func createChatClient() throws {
        do {
            print("Creating Chat Client...")
            self.chatClient = try ChatClient(
                endpoint: self.chatConfiguration.endpoint,
                credential: self.chatConfiguration.credential,
                withOptions: AzureCommunicationChatClientOptions())
        } catch {
            logger.error( "Create Chat Client failed: \(error)")
            throw error
        }
    }

    private func createChatThreadClient() throws {
        do {
            print("Creating Chat Thread Client...")
            self.chatThreadClient = try chatClient?.createClient(
                forThread: self.chatConfiguration.chatThreadId)
        } catch {
            logger.error("Create Chat Thread Client failed: \(error)")
            throw error
        }
    }

    private func retrieveThreadTopic() async throws -> String {
        // Make request to get `topic` to verify valid credential
        do {
            return try await withCheckedThrowingContinuation { continuation in
                chatThreadClient?.getProperties { result, _ in
                    switch result {
                    case .success(let threadProperties):
                        continuation.resume(returning: threadProperties.topic)
                    case .failure(let error):
                        self.logger.error("Retrieve Thread Topic failed: \(error.errorDescription)")
                        continuation.resume(throwing: error)
                    }
                }
            }
        } catch {
            logger.error("Retrieve Thread Topic failed: \(error)")
            throw error
        }
    }

    private func registerRealTimeNotifications() throws {
        print("Register real time notification not implemented")
    }

    private func registerEvents() {
        print("Register events not implemented")
    }
}
