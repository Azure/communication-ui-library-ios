//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
@testable import AzureCommunicationUICalling

class LocalizationProviderMocking: LocalizationProviderProtocol {

    var isApplyCalled: Bool = false
    var isGetLocalizedStringCalled: Bool = false
    var isGetLocalizedStringWithArgsCalled: Bool = false

    var isRightToLeft: Bool {
        return false
    }

    func apply(localeConfig: LocalizationOptions) {
        isApplyCalled = true
    }

    func getLocalizedString<Key>(_ key: Key) -> String
    where Key: RawRepresentable, Key.RawValue == String {
        isGetLocalizedStringCalled = true
        return key.rawValue
    }

    func getLocalizedString<Key>(_ key: Key, _ args: CVarArg...) -> String where Key: RawRepresentable, Key.RawValue == String {
        isGetLocalizedStringWithArgsCalled = true
        return key.rawValue
    }
}
