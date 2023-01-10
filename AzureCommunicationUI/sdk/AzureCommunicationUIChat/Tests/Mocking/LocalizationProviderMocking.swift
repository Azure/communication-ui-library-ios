//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

@testable import AzureCommunicationUIChat

class LocalizationProviderMocking: BaseLocalizationProvider, LocalizationProviderProtocol {
    var isGetLocalizedStringCalled: Bool = false
    var isGetLocalizedStringWithArgsCalled: Bool = false

    override var isRightToLeft: Bool {
        return false
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
