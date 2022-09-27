//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

struct AppState {
    let lifeCycleState: LifeCycleState
    let chatState: ChatState
    let participantsState: ParticipantsState
    let navigationState: NavigationState
    let errorState: ErrorState

    init(lifeCycleState: LifeCycleState = .init(),
         chatState: ChatState = .init(),
         navigationState: NavigationState = .init(),
         participantsState: ParticipantsState = .init(),
         errorState: ErrorState = .init()) {
        self.lifeCycleState = lifeCycleState
        self.chatState = chatState
        self.navigationState = navigationState
        self.participantsState = participantsState
        self.errorState = errorState
    }
}
