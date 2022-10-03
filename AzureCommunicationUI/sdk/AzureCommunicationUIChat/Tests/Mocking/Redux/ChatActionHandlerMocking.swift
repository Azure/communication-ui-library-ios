//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
@testable import AzureCommunicationUIChat

class ChatActionHandlerMocking: ChatActionHandling {
    func enterBackground(state: AppState, dispatch: @escaping ActionDispatch) {
        // stub: to be implemented
    }

    func enterForeground(state: AppState, dispatch: @escaping ActionDispatch) {
        // stub: to be implemented
    }

    func initialize(state: AppState, dispatch: @escaping ActionDispatch, serviceListener: ChatServiceEventHandling) -> Task<Void, Never> {
        Task {
            // stub: to be implemented
        }
    }
}
