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

    func apply(localeConfig: LocalizationConfiguration) {
        isApplyCalled = true
    }

    func getLocalizedString(_ key: LocalizationKey) -> String {
        isGetLocalizedStringCalled = true
        return key.rawValue
    }

    func getLocalizedString(_ key: LocalizationKey, _ args: CVarArg...) -> String {
        isGetLocalizedStringWithArgsCalled = true
        return key.rawValue
    }
}
