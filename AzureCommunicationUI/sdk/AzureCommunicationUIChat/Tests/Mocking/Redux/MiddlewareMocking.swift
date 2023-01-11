//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
@testable import AzureCommunicationUIChat

extension Middleware where State == ChatAppState, Action == AzureCommunicationUIChat.Action {
    static func mock<State>(
        applyingClosure: @escaping (
            @escaping ActionDispatch,
            @escaping () -> State) -> (@escaping ActionDispatch) -> ActionDispatch
    ) -> Middleware<State, Action> {
        .init(apply: applyingClosure)
    }
}
