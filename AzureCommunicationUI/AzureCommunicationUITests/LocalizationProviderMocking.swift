//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
@testable import AzureCommunicationUI

class LocalizationProviderMocking: LocalizationProvider {
    var isApplyCalled: Bool = false
    var isGetSupportedLanguages: Bool = false
    var isGetLocalizedString: Bool = false
    var isGetLocalizedStringWithArgs: Bool = false

    var isRightToLeft: Bool {
        return false
    }

    func apply(localeConfig: LocalizationConfiguration) {
        isApplyCalled = true
    }

    func getSupportedLanguages() -> [String] {
        isGetSupportedLanguages = true
        return ["en"]
    }

    func getLocalizedString(_ key: StringKey) -> String {
        isGetLocalizedString = true
        return key.rawValue
    }

    func getLocalizedString(_ key: StringKey, _ args: CVarArg...) -> String {
        isGetLocalizedStringWithArgs = true
        return key.rawValue
    }
}
