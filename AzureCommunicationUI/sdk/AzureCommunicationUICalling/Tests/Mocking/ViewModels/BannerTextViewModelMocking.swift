//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import Combine

@testable import AzureCommunicationUICalling
@_spi(CallCompositeUITest) import AzureCommunicationUICalling

class BannerTextViewModelMocking: BannerTextViewModel {
    var updateBannerInfoType: ((BannerInfoType?) -> Void)?
    var bannerType: BannerInfoType?

    init(accessibilityProvider: AccessibilityProviderProtocol = AccessibilityProvider(),
         updateBannerInfoType: ((BannerInfoType?) -> Void)? = nil) {
        self.updateBannerInfoType = updateBannerInfoType
        super.init(accessibilityProvider: accessibilityProvider,
                   localizationProvider: LocalizationProviderMocking())
    }

    override func update(bannerInfoType: BannerInfoType?) {
        updateBannerInfoType?(bannerInfoType)
    }
}
