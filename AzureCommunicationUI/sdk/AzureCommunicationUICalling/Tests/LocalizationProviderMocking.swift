//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
@testable import AzureCommunicationUICalling

class LocalizationProviderMocking: BaseLocalizationProvider, LocalizationProviderProtocol {

    var isApplyCalled: Bool = false
    var isGetLocalizedStringCalled: Bool = false
    var isGetLocalizedStringWithArgsCalled: Bool = false

    init() {
        super.init(logger: LoggerMocking(), bundleClass: LocalizationProviderMocking.self)
    }

    override var isRightToLeft: Bool {
        return false
    }

    override func apply(localeConfig: LocalizationOptions) {
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
