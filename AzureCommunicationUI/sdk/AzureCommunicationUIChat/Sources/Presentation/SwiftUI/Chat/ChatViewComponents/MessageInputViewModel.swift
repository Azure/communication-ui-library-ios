//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

class MessageInputViewModel: ObservableObject {
    private let logger: Logger
    private let dispatch: ActionDispatch

    init(logger: Logger,
         dispatch: @escaping ActionDispatch) {
        self.logger = logger
        self.dispatch = dispatch
    }

    @Published var message: String = ""
    @Published var hasFocus: Bool = true

    func sendMessage() {
        hasFocus = true
        guard !message.isEmpty else {
            return
        }
        dispatch(.repositoryAction(.sendMessageTriggered(
            internalId: UUID().uuidString,
            content: message)))
        message = ""
    }
}
