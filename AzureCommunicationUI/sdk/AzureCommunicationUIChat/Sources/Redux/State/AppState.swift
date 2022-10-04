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
    let repositoryState: RepositoryState
    let errorState: ErrorState

    init(lifeCycleState: LifeCycleState = .init(),
         chatState: ChatState = .init(),
         participantsState: ParticipantsState = .init(),
         navigationState: NavigationState = .init(),
         repositoryState: RepositoryState = .init(),
         errorState: ErrorState = .init()) {
        self.lifeCycleState = lifeCycleState
        self.chatState = chatState
        self.participantsState = participantsState
        self.navigationState = navigationState
        self.repositoryState = repositoryState
        self.errorState = errorState
    }
}
