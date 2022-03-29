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
        let languageCode = "en"
        let isRTL = true
        let localeConfig = LocalizationConfiguration(languageCode: languageCode,
                                                     isRightToLeft: isRTL)
        sut.apply(localeConfig: localeConfig)
        XCTAssertTrue(sut.layoutDirection)
    }

    func test_localizationProvider_isRightToLeft_when_applyRTLFalse_then_shouldRTLReturnFalse() {
        let sut = makeSUT()
        let languageCode = "en"
        let isRTL = false
        let localeConfig = LocalizationConfiguration(languageCode: languageCode,
                                                     isRightToLeft: isRTL)
        sut.apply(localeConfig: localeConfig)
        XCTAssertFalse(sut.layoutDirection)
    }

    func test_localizationProvider_getSupportedLanguages_then_shouldReturnLanguages() {
        let sut = makeSUT()
        XCTAssertNotEqual(sut.getSupportedLanguages().count, 0)
    }

    func test_localizationProvider_getLocalizedString_when_noApply_then_shouldReturnEnString() {
        let sut = makeSUT()

        let key = LocalizationKey.joinCall
        let joinCallEn = "Join call"
        XCTAssertEqual(sut.getLocalizedString(key), joinCallEn)
    }

    func test_localizationProvider_getLocalizedString_when_applyLocaleFr_then_shouldReturnLocalePredefinedString() {
        let sut = makeSUT()

        let key = LocalizationKey.joinCall
        let joinCallEn = "Join call"
        XCTAssertEqual(sut.getLocalizedString(key), joinCallEn)

        let languageCode = "fr"
        let localeConfig = LocalizationConfiguration(languageCode: languageCode)
        sut.apply(localeConfig: localeConfig)

        XCTAssertNotEqual(sut.getLocalizedString(key), joinCallEn)
    }
}

extension LocalizationProviderTests {
    func makeSUT() -> LocalizationProvider {
        return AppLocalizationProvider(logger: logger)
    }
}
