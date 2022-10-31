//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import AzureCore
import AzureCommunicationChat
import Foundation

class ChatSDKWrapper: NSObject, ChatSDKWrapperProtocol {
    func sendReadReceipt(messageId: String) async throws {
        do {
            return try await withCheckedThrowingContinuation { continuation in
                chatThreadClient?.sendReadReceipt(
                                        forMessage: messageId,
                                        withOptions: SendChatReadReceiptOptions()) { result, error  in
                    switch result {
                    case .success():
                        continuation.resume(returning: Void())
                    case .failure(let error):
                        self.logger.error("Failed to send read receipt: \(error)")
                        continuation.resume(throwing: error)
                    }
                }
            }
        } catch {
            logger.error("Failed to send read receipt: \(error)")
            throw error
        }
    }

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
                        self.pagedCollection = nil
                        continuation.resume(throwing: error)
                    }
                }
            }
        } catch {
            logger.error("Retrieve Thread Topic failed: \(error)")
            throw error
        }
    }

    func getListOfParticipants() async throws -> [ParticipantInfoModel] {
        do {
            return try await withCheckedThrowingContinuation { continuation in
                chatThreadClient?.listParticipants(completionHandler: { result, _ in
                    switch result {
                    case .success(let pagedCollection):
                        guard let items = pagedCollection.pageItems else {
                            continuation.resume(returning: [])
                            return
                        }

                        let participants = items.compactMap({ $0.toParticipantInfoModel() })
                        continuation.resume(returning: participants)
                    case .failure(let error):
                        self.logger.error("Get Initial Messages failed: \(error)")
                        continuation.resume(throwing: error)
                    }
                })
            }
        } catch {
            logger.error("Get List of Participants failed: \(error)")
            throw error
        }
    }

    func getPreviousMessages() async throws -> [ChatMessageInfoModel] {
        do {
            guard let messagePagedCollection = self.pagedCollection else {
                return try await self.getInitialMessages()
            }
            return try await withCheckedThrowingContinuation { continuation in
                messagePagedCollection.nextPage { result in
                    switch result {
                    case .success(let messagesResult):
                        let previousMessages = messagesResult.map({
                            $0.toChatMessageInfoModel()
                        })
                        continuation.resume(returning: previousMessages)
                    case .failure(let error):
                        self.logger.error("Failed to get previous messages")
                        continuation.resume(throwing: error)
                    }
                }
            }
        } catch {
            logger.error("Retrieve Thread Topic failed: \(error)")
            throw error
        }
    }

    func sendMessage(content: String, senderDisplayName: String) async throws -> String {
        do {
            let messageRequest = SendChatMessageRequest(
                content: content,
                senderDisplayName: senderDisplayName
            )
            return try await withCheckedThrowingContinuation { continuation in
                chatThreadClient?.send(message: messageRequest) { result, _ in
                    switch result {
                    case let .success(result):
                        continuation.resume(returning: result.id)
                    case .failure(let error):
                        self.logger.error("Failed to send message: \(error)")
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
        self.chatClient?.startRealTimeNotifications { [self] result in
            switch result {
            case .success:
                print("Real-time notifications started.")
                self.registerEvents()
            case .failure(let error):
                print("Failed to start real-time notifications. \(error)")
            }
        }
    }

    func sendTypingIndicator() async throws {
        do {
            return try await withCheckedThrowingContinuation { continuation in
                self.chatThreadClient?.sendTypingNotification(from: self.chatConfiguration.displayName) { result, _ in
                    switch result {
                    case .success:
                        continuation.resume(returning: Void())
                    case .failure(let error):
                        self.logger.error("Send Typing Indicator failed: \(error)")
                        continuation.resume(throwing: error)
                    }
                }
            }
        } catch {
            self.logger.error("Send Typing Indicator failed: \(error)")
            throw error
        }
    }

    private func registerEvents() {
        guard let client = self.chatClient else {
                     return
        }
        client.register(event: .realTimeNotificationConnected, handler: chatEventsHandler.handle)
        client.register(event: .realTimeNotificationDisconnected, handler: chatEventsHandler.handle)
        client.register(event: .chatMessageReceived, handler: chatEventsHandler.handle)
        client.register(event: .chatMessageEdited, handler: chatEventsHandler.handle)
        client.register(event: .chatMessageDeleted, handler: chatEventsHandler.handle)
        client.register(event: .typingIndicatorReceived, handler: chatEventsHandler.handle)
        client.register(event: .readReceiptReceived, handler: chatEventsHandler.handle)
        client.register(event: .chatThreadDeleted, handler: chatEventsHandler.handle)
        client.register(event: .chatThreadPropertiesUpdated, handler: chatEventsHandler.handle)
        client.register(event: .participantsAdded, handler: chatEventsHandler.handle)
        client.register(event: .participantsRemoved, handler: chatEventsHandler.handle)
    }
}
