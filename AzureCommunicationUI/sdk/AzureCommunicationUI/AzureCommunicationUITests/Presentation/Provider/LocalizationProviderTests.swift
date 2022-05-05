//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import SwiftUI
import XCTest
@testable import AzureCommunicationUI

class LocalizationProviderTests: XCTestCase {
    private var logger: LoggerMocking!

    override func setUp() {
        super.setUp()
        logger = LoggerMocking()
    }

    func test_localizationProvider_applyRTL_when_layoutDirectionRightToLeft_then_shouldRTLReturnTrue() {
        let sut = makeSUT()
        let locale: Locale = CommunicationUISupportedLocale.en
        let layoutDirection: LayoutDirection = .rightToLeft
        let localeConfig = LocalizationConfiguration(locale: locale,
                                                     layoutDirection: layoutDirection)
        sut.apply(localeConfig: localeConfig)
        XCTAssertTrue(sut.isRightToLeft)
    }

    func test_localizationProvider_applyRTL_when_layoutDirectionLeftToRight_then_shouldRTLReturnFalse() {
        let sut = makeSUT()
        let locale: Locale = CommunicationUISupportedLocale.en
        let layoutDirection: LayoutDirection = .leftToRight
        let localeConfig = LocalizationConfiguration(locale: locale,
                                                     layoutDirection: layoutDirection)
        sut.apply(localeConfig: localeConfig)
        XCTAssertFalse(sut.isRightToLeft)
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

        let locale: Locale = CommunicationUISupportedLocale.fr
        let localeConfig = LocalizationConfiguration(locale: locale)
        sut.apply(localeConfig: localeConfig)

        XCTAssertNotEqual(sut.getLocalizedString(key), joinCallEn)
    }
}

extension LocalizationProviderTests {
    func makeSUT() -> LocalizationProviderProtocol {
        return LocalizationProvider(logger: logger)
    }
}
