//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import SwiftUI

protocol LocalizationProviderProtocol: BaseLocalizationProviderProtocol {
    var isRightToLeft: Bool { get }
    func apply(localeConfig: LocalizationOptions)
    func getLocalizedString(_ key: LocalizationKey) -> String
    func getLocalizedString(_ key: LocalizationKey, _ args: CVarArg...) -> String
}

class LocalizationProvider: BaseLocalizationProvider, LocalizationProviderProtocol {
    init(logger: Logger) {
        super.init(logger: logger, bundleClass: CallComposite.self)
    }
}
