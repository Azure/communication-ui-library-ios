//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

@_spi(common) import AzureCommunicationUICommon
import Foundation

@testable import AzureCommunicationUIChat

extension Middleware<AppState, Action> {
    static func mock(
        applyingClosure: @escaping (
            @escaping ChatActionDispatch,
            @escaping () -> State) -> (@escaping ChatActionDispatch) -> ChatActionDispatch
    ) -> Middleware<AppState, Action> {
        return Middleware<AppState, Action>(apply: applyingClosure)
    }
}
