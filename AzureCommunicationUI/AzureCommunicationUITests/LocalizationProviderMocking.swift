//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
@testable import AzureCommunicationUI

struct LocalizationProviderMocking: LocalizationProvider {
    var isRightToLeft: Bool {
        return false
    }

    func apply(localeConfig: LocalizationConfiguration) {
        return
    }

    func getSupportedLanguages() -> [String] {
        return ["en"]
    }

    func getLocalizedString(_ key: StringKey) -> String {
        // return hard coded string
        return "ABC"
    }

    func getLocalizedString(_ key: StringKey, _ args: CVarArg...) -> String {
        // return hard coded string
        return "XYZ"
    }
}
