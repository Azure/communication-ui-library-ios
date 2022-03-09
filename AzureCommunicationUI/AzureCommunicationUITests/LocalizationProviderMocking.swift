//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
@testable import AzureCommunicationUI

struct LocalizationProviderMocking: LocalizationProvider {

    func applyLocalizationConfiguration(_ localeConfig: LocalizationConfiguration) {
        return
    }

    func getSupportedLanguages() -> [String] {
        return ["en"]
    }

    func getLocalizedString(_ key: String) -> String {
        // return hard coded string
        return "ABC"
    }

    func getLocalizedString(_ key: String, _ args: CVarArg...) -> String {
        // return hard coded string
        return "XYZ"
    }
}
