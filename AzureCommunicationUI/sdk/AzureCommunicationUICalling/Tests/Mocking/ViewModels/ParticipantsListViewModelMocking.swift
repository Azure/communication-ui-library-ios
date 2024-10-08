//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
@testable import AzureCommunicationUICalling

class ParticipantsListViewModelMocking: ParticipantsListViewModel {
    var updateStates: ((LocalUserState, RemoteParticipantsState, Bool) -> Void)?

    override func update(localUserState: LocalUserState,
                         remoteParticipantsState: RemoteParticipantsState,
                         isDisplayed: Bool) {
        updateStates?(localUserState, remoteParticipantsState, isDisplayed)
    }
}
