//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

@_spi(common) import AzureCommunicationUICommon

extension Reducer {
    static func appStateReducer(
        lifeCycleReducer: Reducer<LifeCycleState, Action> = .liveLifecycleReducer,
        chatReducer: Reducer<ChatState, Action> = .liveChatReducer,
        participantsReducer: Reducer<ParticipantsState, Action> = .liveParticipantsReducer,
        navigationReducer: Reducer<NavigationState, Action> = .liveNavigationReducer,
        repositoryReducer: Reducer<RepositoryState, Action> = .liveRepositoryReducer,
        errorReducer: Reducer<ErrorState, Action> = .liveErrorReducer
    ) -> Reducer<AppState, Action> {

        return Reducer<AppState, Action> { state, action in

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

            return AppState(lifeCycleState: lifeCycleState,
                            chatState: chatState,
                            participantsState: participantsState,
                            navigationState: navigationState,
                            repositoryState: repositoryState,
                            errorState: errorState)
        }
    }
}
