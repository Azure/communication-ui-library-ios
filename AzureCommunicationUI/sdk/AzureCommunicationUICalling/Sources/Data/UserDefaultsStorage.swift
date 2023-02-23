//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

protocol UserDefaultsStorageProtocol {
    func data(forKey defaultName: String) -> Data?
    func set(_ value: Any?, forKey key: String)
}

extension UserDefaults: UserDefaultsStorageProtocol {}
