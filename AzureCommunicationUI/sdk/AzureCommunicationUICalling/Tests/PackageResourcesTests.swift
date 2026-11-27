//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import AzureCommunicationCalling
import SwiftUI
import XCTest
@testable import AzureCommunicationUICalling

class PackageResourcesTests: XCTestCase {

    func test_supportedLocales_when_loadedFromResourceBundle_then_containsPredefinedTranslations() {
        let identifiers = SupportedLocale.values.map { $0.identifier }

        XCTAssertTrue(identifiers.contains("en"))
        XCTAssertTrue(identifiers.contains("fr"))
        XCTAssertTrue(identifiers.contains("zh-Hans"))
    }

    func test_localizationProvider_when_englishLocale_then_returnsTranslatedString() {
        let sut = LocalizationProvider(logger: LoggerMocking())
        sut.apply(localeConfig: LocalizationOptions(locale: Locale(identifier: "en")))

        let key = LocalizationKey.joinCall
        XCTAssertNotEqual(sut.getLocalizedString(key), key.rawValue)
    }

    func test_iconProvider_when_iconRequested_then_loadsFromResourceBundle() {
        XCTAssertNotNil(IconProvider().getUIImage(for: .endCall))
    }

    func test_compositeColor_when_colorRequested_then_loadsFromResourceBundle() {
        XCTAssertNotNil(UIColor.compositeColor(.hangup))
    }

    func test_toCapabilityResolutionReason_when_explicitConsentRequired_then_mapsWithoutCrash() {
        let reason = AzureCommunicationCalling.CapabilityResolutionReason.explicitConsentRequired

        XCTAssertEqual(reason.toCapabilityResolutionReason(), .explicitConsentRequired)
    }
}
