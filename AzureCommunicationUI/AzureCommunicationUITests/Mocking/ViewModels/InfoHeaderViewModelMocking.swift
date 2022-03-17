//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
@testable import AzureCommunicationUI

class InfoHeaderViewModelMocking: InfoHeaderViewModel {
    private let updateState: ((LocalUserState, RemoteParticipantsState) -> Void)?

    init(compositeViewModelFactory: CompositeViewModelFactory,
         logger: Logger,
         localUserState: LocalUserState,
         updateState: ((LocalUserState, RemoteParticipantsState) -> Void)? = nil) {
        self.updateState = updateState
        super.init(compositeViewModelFactory: compositeViewModelFactory,
                   logger: logger,
                   localUserState: localUserState,
                   localizationProvider: LocalizationProviderMocking())
    }

    override func update(localUserState: LocalUserState, remoteParticipantsState: RemoteParticipantsState) {
        updateState?(localUserState, remoteParticipantsState)
    }
}
