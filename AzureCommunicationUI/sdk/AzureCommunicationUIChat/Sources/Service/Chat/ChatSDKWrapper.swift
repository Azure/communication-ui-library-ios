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

    init(logger: Logger, chatEventsHandler: ChatSDKEventsHandling, chatConfiguration: ChatConfiguration) {
        self.logger = logger
        self.chatEventsHandler = chatEventsHandler
        self.chatConfiguration = chatConfiguration
        super.init()
    }

    deinit {
        logger.debug("CallingSDKWrapper deallocated")
    }

    func chatStart() -> AnyPublisher<[ChatMessageInfoModel], Error> {
        Future { [self] promise in
            do {
                createChatClient()
                createChatThreadClient()
                startChat()
                let listChatMessagesOptions = ListChatMessagesOptions(
                    maxPageSize: self.chatConfiguration.pageSize)
                self.chatThreadClient?.listMessages(withOptions: listChatMessagesOptions) { result, _ in
                    switch result {
                    case let .success(messagesResult):
                        self.pagedCollection = messagesResult
                        let messages = self.pagedCollection?.pageItems?
                            .filter({ $0.type == .text })
                            .map({ $0.toChatMessageInfoModel() })
                        return promise(.success(messages?.reversed() ?? []))
                    case .failure(let error):
                        print("Failed to get initial messages")
                        return promise(.failure(error))
                    }
                }
            } catch {
                return promise(.failure(error))
            }
        }.eraseToAnyPublisher()
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
        self.chatClient?.register(event: .chatMessageReceived, handler: chatEventsHandler.handle)
        self.chatClient?.register(event: .typingIndicatorReceived, handler: chatEventsHandler.handle)
        self.chatClient?.register(event: .readReceiptReceived, handler: chatEventsHandler.handle)
        self.chatClient?.register(event: .chatMessageEdited, handler: chatEventsHandler.handle)
        self.chatClient?.register(event: .chatMessageDeleted, handler: chatEventsHandler.handle)
        self.chatClient?.register(event: .chatThreadDeleted, handler: chatEventsHandler.handle)
        self.chatClient?.register(event: .participantsAdded, handler: chatEventsHandler.handle)
        self.chatClient?.register(event: .participantsRemoved, handler: chatEventsHandler.handle)
    }

    func sendTypingIndicator() -> AnyPublisher<Void, Error> {
        Future<Void, Error> { promise in
            self.chatThreadClient?.sendTypingNotification(from: self.chatConfiguration.displayName) { result, _ in
                switch result {
                case .success:
                    return promise(.success(Void()))
                case .failure(let error):
                    print("Failed to send typing indicator \(error)")
                    return promise(.failure(error))
                }
            }
        }.eraseToAnyPublisher()
    }

    func sendMessageRead(messageId: String) -> AnyPublisher<Void, Error> {
        Future<Void, Error> { promise in
            self.chatThreadClient?.sendReadReceipt(forMessage: messageId) { result, _ in
                switch result {
                case .success:
                    return promise(.success(Void()))
                case .failure(let error):
                    print("Failed to send read receipt \(error)")
                    return promise(.failure(error))
                }
            }
        }.eraseToAnyPublisher()
    }

    func sendMessage(message: ChatMessageInfoModel) -> AnyPublisher<String, Error> {
        Future<String, Error> { promise in
            let messageRequest = SendChatMessageRequest(
                content: message.content ?? "No content",
                senderDisplayName: message.senderDisplayName
            )
            self.chatThreadClient?.send(message: messageRequest) { result, _ in
                switch result {
                case let .success(result):
                    return promise(.success(result.id))
                case .failure(let error):
                    print("Failed to send message \(error)")
                    return promise(.failure(error))
                }
            }
        }.eraseToAnyPublisher()
    }

    func editMessage(message: ChatMessageInfoModel) -> AnyPublisher<Void, Error> {
        Future<Void, Error> { promise in
            let messageRequest = UpdateChatMessageRequest(
                content: message.content ?? "No content"
            )
            self.chatThreadClient?.update(message: message.id, parameters: messageRequest) { result, _ in
                switch result {
                case .success:
                    return promise(.success(Void()))
                case .failure(let error):
                    print("Failed to edit message \(error)")
                    return promise(.failure(error))
                }
            }
        }.eraseToAnyPublisher()
    }

    func deleteMessage(messageId: String) -> AnyPublisher<Void, Error> {
        Future<Void, Error> { promise in
            self.chatThreadClient?.delete(message: messageId) { result, _ in
                switch result {
                case .success:
                    return promise(.success(Void()))
                case .failure(let error):
                    print("Failed to delete message \(error)")
                    return promise(.failure(error))
                }
            }
        }.eraseToAnyPublisher()
    }

    func fetchPreviousMessages() -> AnyPublisher<[ChatMessageInfoModel], Error> {
        Future<[ChatMessageInfoModel], Error> { promise in
            self.pagedCollection?.nextPage(completionHandler: { result in
                switch result {
                case let .success(messagesResult):
                    let previousMessages = messagesResult.map({
                        $0.toChatMessageInfoModel()
                    })
                    return promise(.success(previousMessages.reversed()))
                case .failure(let error):
                    print("Failed to get previous messages")
                    return promise(.failure(error))
                }
            })
        }.eraseToAnyPublisher()
    }

    func listParticipants() -> AnyPublisher<[ParticipantInfoModel], Error> {
        Future<[ParticipantInfoModel], Error> { promise in
            let participantsPageSize: Int32 = 200
            let listParticipantsOptions = ListChatParticipantsOptions(
                maxPageSize: participantsPageSize)
            self.chatThreadClient?.listParticipants(withOptions: listParticipantsOptions) { result, _ in
                switch result {
                case let .success(pagedCollectionResult):
                    guard let firstPageParticipants = pagedCollectionResult.pageItems else {
                        return promise(.success([]))
                    }
                    var participants = firstPageParticipants
                    // todo: mask admin user
                        .map({ $0.toParticipantInfoModel() })

                    while !pagedCollectionResult.isExhausted {
                        pagedCollectionResult.nextPage { result in
                            switch result {
                            case let .success(participantsResult):
                                let participantsPagedResult = participantsResult.map({
                                    $0.toParticipantInfoModel()
                                })
                                participants.append(contentsOf: participantsPagedResult)
                            case .failure(let error):
                                print("Failed to list participants: \(error)")
                                // return partial fetched list or error?
                                return promise(.failure(error))
                            }
                        }
                    }
                    return promise(.success(participants))
                case .failure(let error):
                    print("Failed to list participants")
                    return promise(.failure(error))
                }
            }
        }.eraseToAnyPublisher()
    }

    func removeParticipant(participant: ParticipantInfoModel) -> AnyPublisher<Void, Error> {
        Future<Void, Error> { promise in
            self.chatThreadClient?.remove(participant: participant.identifier) { result, _ in
                switch result {
                case .success:
                    return promise(.success(Void()))
                case .failure(let error):
                    print("Failed to remove participant \(error)")
                    return promise(.failure(error))
                }
            }
        }.eraseToAnyPublisher()
    }

    func removeLocalParticipant() -> AnyPublisher<Void, Error> {

        Future<Void, Error> { promise in
            self.chatThreadClient?.remove(participant: self.chatConfiguration.communicationIdentifier) { result, _ in
                switch result {
                case .success:
                    return promise(.success(Void()))
                case .failure(let error):
                    print("Failed to remove local participant \(error)")
                    return promise(.failure(error))
                }
            }
        }.eraseToAnyPublisher()
    }
}
