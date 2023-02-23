//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
@testable import AzureCommunicationUICalling

class UserDefaultsStorageMocking: UserDefaultsStorageProtocol {
    var values: [String: Any] = [:]

    func data(forKey defaultName: String) -> Data? {
        return values[defaultName] as? Data
    }

    func set(_ value: Any?, forKey key: String) {
        values[key] = value
    }
}
