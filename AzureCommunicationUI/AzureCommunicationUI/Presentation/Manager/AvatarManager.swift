//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import UIKit
import AzureCommunicationCommon

public class AvatarManager {
    private let localUserAvatarKey: String = "local"

    private let store: Store<AppState>
    private var avatarCache = MappedSequence<String, Data>()

    init(store: Store<AppState>) {
        self.store = store
    }

    func setLocalAvatar(_ image: UIImage) {
        if let rawData = image.pngData() {
            avatarCache.append(forKey: localUserAvatarKey, value: rawData)
        }
    }

    func getLocalAvatar() -> UIImage? {
        if let data = avatarCache.value(forKey: localUserAvatarKey) {
            return UIImage(data: data)
        }

        return nil
    }
}
