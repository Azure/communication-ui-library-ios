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
    private(set) var localSettings: LocalSettings?

    init(store: Store<AppState>,
         localSettings: LocalSettings?) {
        self.store = store
        self.localSettings = localSettings
    }

    func getLocalParticipantViewData() -> ParticipantViewData? {
        guard let participantViewData = localSettings?.participantViewData else {
            return nil
        }

        return participantViewData
    }
}
