//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import AzureCommunicationChat
import AzureCore
import Foundation

extension ChatThreadClient {
    func listParticipants(withOptions options: ListChatParticipantsOptions? = nil) async throws
    -> PagedCollection<ChatParticipant> {
        try await withCheckedThrowingContinuation { continuation in
            listParticipants(withOptions: options) { result, _ in
                switch result {
                case .failure(let azureError):
                    continuation.resume(throwing: azureError)
                case .success(let participantsResult):
                    continuation.resume(returning: participantsResult)
                }
            }
        }
    }
}

extension PagedCollection {
    func nextPage() async throws -> [SingleElement] {
        try await withCheckedThrowingContinuation { continuation in
            nextPage { result in
                switch result {
                case .failure(let error):
                    continuation.resume(throwing: error)
                case .success(let pageItems):
                    continuation.resume(returning: pageItems)
                }
            }
        }
    }
}
