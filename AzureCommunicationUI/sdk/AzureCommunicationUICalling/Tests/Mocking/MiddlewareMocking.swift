//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

@_spi(common) import AzureCommunicationUICommon
import Foundation

@testable import AzureCommunicationUICalling

extension Middleware<AppState, Action> {
    static func mock(
        applyingClosure: @escaping (
            @escaping CallActionDispatch,
            @escaping () -> State) -> (@escaping CallActionDispatch) -> CallActionDispatch
    ) -> Middleware<AppState, Action> {
        return Middleware<AppState, Action>(apply: applyingClosure)
    }
}
