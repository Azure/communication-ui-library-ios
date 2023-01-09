//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
@testable import AzureCommunicationUICalling

extension Middleware where State == AppState {
    static func mock<State>(
        applyingClosure: @escaping (
            @escaping ActionDispatch,
            @escaping () -> State) -> (@escaping ActionDispatch) -> ActionDispatch
    ) -> Middleware<State, AzureCommunicationUICalling.Action> {
        return .init(apply: applyingClosure)
    }
}
