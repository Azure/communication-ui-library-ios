//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import AzureCommunicationCommon

protocol AvatarViewManager {
    func getLocalPersonaData() -> CommunicationUIPersonaData?
}

class CompositeAvatarViewManager: AvatarViewManager {
    private let store: Store<AppState>
    private(set) var avatarCache = MappedSequence<String, Data>()
    private(set) var localDataOptions: CommunicationUILocalDataOptions?

    init(store: Store<AppState>,
         localDataOptions: CommunicationUILocalDataOptions?) {
        self.store = store
        self.localDataOptions = localDataOptions
    }

    func getLocalPersonaData() -> CommunicationUIPersonaData? {
        guard let localPersona = localDataOptions?.localPersona else {
            return nil
        }

        return localPersona
    }
}
