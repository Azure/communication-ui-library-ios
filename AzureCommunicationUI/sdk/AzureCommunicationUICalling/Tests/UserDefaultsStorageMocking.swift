//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import XCTest
@testable import AzureCommunicationUICalling

class UserDefaultsStorageMocking: UserDefaultsStorageProtocol {
    let data: (String) -> Data?
    let set: (Any?, String) -> Void

    init(data: @escaping (String) -> Data?, set: @escaping (Any?, String) -> Void) {
        self.data = data
        self.set = set
    }

    func data(forKey defaultName: String) -> Data? {
        return self.data(defaultName)
    }

    func set(_ value: Any?, forKey key: String) {
        self.set(value, key)
    }
}
