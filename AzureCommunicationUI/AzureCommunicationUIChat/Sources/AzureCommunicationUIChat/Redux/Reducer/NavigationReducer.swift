//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

@_spi(common) import AzureCommunicationUICommon
import Foundation

extension Reducer<NavigationState, Action> where State == NavigationState,
                        Actions == Action {
    static var liveNavigationReducer: Self = Reducer { state, action in
        var navigationStatus = state.status
        switch action {
        case .chatViewLaunched:
            navigationStatus = .inChat
        case .chatViewHeadless:
            navigationStatus = .headless
        case .compositeExitAction:
            navigationStatus = .exit
        case .errorAction(.statusErrorAndChatReset):
            navigationStatus = .exit
        default:
            return state
        }
        return NavigationState(status: navigationStatus)
    }
}
