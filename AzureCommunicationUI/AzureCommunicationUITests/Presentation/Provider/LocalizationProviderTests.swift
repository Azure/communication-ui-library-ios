//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import XCTest
@testable import AzureCommunicationUI

class LocalizationProviderTests: XCTestCase {
    private var logger: LoggerMocking!

    override func setUp() {
        super.setUp()
        logger = LoggerMocking()
    }

    func test_localizationProvider_isRightToLeft_when_applyRTLTrue_then_shouldRTLReturnTrue() {
        let sut = makeSUT()
        let locale = "en"
        let isRTL = true
        let localeConfig = LocalizationConfiguration(locale: locale,
                                                     isRightToLeft: isRTL)
        sut.apply(localeConfig: localeConfig)
        XCTAssertTrue(sut.isRightToLeft)
    }

    func test_localizationProvider_isRightToLeft_when_applyRTLFalse_then_shouldRTLReturnFalse() {
        let sut = makeSUT()
        let locale = "en"
        let isRTL = false
        let localeConfig = LocalizationConfiguration(locale: locale,
                                                     isRightToLeft: isRTL)
        sut.apply(localeConfig: localeConfig)
        XCTAssertFalse(sut.isRightToLeft)
    }

    func test_localizationProvider_getSupportedLanguages_then_shouldReturnLanguages() {
        let sut = makeSUT()
        XCTAssertNotEqual(sut.getSupportedLanguages().count, 0)
    }

    func test_localizationProvider_getLocalizedString_when_noApply_then_shouldReturnEnString() {
        let sut = makeSUT()

        let key = StringKey.joinCall
        let joinCallEn = "Join call"
        XCTAssertEqual(sut.getLocalizedString(key), joinCallEn)
    }

    func test_localizationProvider_getLocalizedString_when_applyLocaleFr_then_shouldReturnLocalePredefinedString() {
        let sut = makeSUT()

        let key = StringKey.joinCall
        let joinCallEn = "Join call"
        XCTAssertEqual(sut.getLocalizedString(key), joinCallEn)

        let locale = "fr"
        let localeConfig = LocalizationConfiguration(locale: locale)
        sut.apply(localeConfig: localeConfig)

        XCTAssertNotEqual(sut.getLocalizedString(key), joinCallEn)
    }

    func test_localizationProvider_getLocalizedString_when_applyCustomTranslations_then_shouldReturnCustomizedString() {
        let sut = makeSUT()

        let key = StringKey.joinCall
        let joinCallEn = "Join call"
        XCTAssertEqual(sut.getLocalizedString(key), joinCallEn)

        let customKey = StringKey.speaker
        let speakerEn = "Speaker"
        XCTAssertEqual(sut.getLocalizedString(customKey), speakerEn)

        let locale = "en"
        let customText = "Custom Speaker"
        let customTranslations: [String: String] = [
            customKey.rawValue: customText
        ]
        let localeConfig = LocalizationConfiguration(locale: locale,
                                                     customTranslations: customTranslations)
        sut.apply(localeConfig: localeConfig)
        XCTAssertEqual(sut.getLocalizedString(key), joinCallEn)
        XCTAssertEqual(sut.getLocalizedString(customKey), customText)
    }
}

extension LocalizationProviderTests {
    func makeSUT() -> LocalizationProvider {
        return AppLocalizationProvider(logger: logger)
    }
}
