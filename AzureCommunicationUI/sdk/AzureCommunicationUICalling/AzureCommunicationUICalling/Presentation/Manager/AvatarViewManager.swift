//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import UIKit
import AzureCommunicationCommon

protocol AvatarViewManagerProtocol {
    func getLocalParticipantViewData() -> ParticipantViewData?
}

public class CompositeAvatarViewManager: AvatarViewManagerProtocol {
    private let store: Store<AppState>
    private(set) var avatarCache = MappedSequence<String, Data>()
    private(set) var localDataOptions: CommunicationUILocalDataOptions?

    init(store: Store<AppState>,
         localDataOptions: CommunicationUILocalDataOptions?) {
        self.store = store
        self.localDataOptions = localDataOptions
    }

    func getLocalParticipantViewData() -> ParticipantViewData? {
        guard let participantViewData = localDataOptions?.participantViewData else {
            return nil
        }

        return participantViewData
    }
}
