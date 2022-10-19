//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

@_spi(common) import AzureCommunicationUICommon
import Foundation

typealias ChatActionDispatch = ActionDispatch<Action>
///
/// Action for the entire library. All actions are defined here as a heirarchy of enum types
///
enum Action: Equatable {
    case lifecycleAction(LifecycleAction)
    case chatAction(ChatAction)
    case participantsAction(ParticipantsAction)
    case repositoryAction(RepositoryAction)
    case errorAction(ErrorAction)

    case compositeExitAction
    case chatViewLaunched
    case chatViewHeadless
}
