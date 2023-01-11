//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

extension Reducer where State == ChatAppState, Actions == Action {
    static func appStateReducer(
        lifeCycleReducer: Reducer<LifeCycleState, Actions> = .liveLifecycleReducer,
        chatReducer: Reducer<ChatState, Actions> = .liveChatReducer,
        participantsReducer: Reducer<ParticipantsState, Actions> = .liveParticipantsReducer,
        navigationReducer: Reducer<NavigationState, Actions> = .liveNavigationReducer,
        repositoryReducer: Reducer<RepositoryState, Actions> = .liveRepositoryReducer,
        errorReducer: Reducer<ErrorState, Actions> = .liveErrorReducer
    ) -> Reducer<State, Actions> {
        .init { state, action in

            var lifeCycleState = state.lifeCycleState
            var chatState = state.chatState
            var participantsState = state.participantsState
            var navigationState = state.navigationState
            var repositoryState = state.repositoryState
            var errorState = state.errorState

            lifeCycleState = lifeCycleReducer.reduce(state.lifeCycleState, action)
            chatState = chatReducer.reduce(state.chatState, action)
            participantsState = participantsReducer.reduce(state.participantsState, action)
            navigationState = navigationReducer.reduce(state.navigationState, action)
            repositoryState = repositoryReducer.reduce(state.repositoryState, action)
            errorState = errorReducer.reduce(state.errorState, action)

            return ChatAppState(
                lifeCycleState: lifeCycleState,
                chatState: chatState,
                participantsState: participantsState,
                navigationState: navigationState,
                repositoryState: repositoryState,
                errorState: errorState
            )
        }
    }
}
