//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
@testable import AzureCommunicationUI

class LocalizationProviderMocking: LocalizationProvider {
    var isApplyCalled: Bool = false
    var isGetSupportedLanguagesCalled: Bool = false
    var isGetLocalizedStringCalled: Bool = false
    var isGetLocalizedStringWithArgsCalled: Bool = false

    var isRightToLeft: Bool {
        return false
    }

    func apply(localeConfig: LocalizationConfiguration) {
        isApplyCalled = true
    }

    func getSupportedLanguages() -> [String] {
        isGetSupportedLanguagesCalled = true
        return ["en"]
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
