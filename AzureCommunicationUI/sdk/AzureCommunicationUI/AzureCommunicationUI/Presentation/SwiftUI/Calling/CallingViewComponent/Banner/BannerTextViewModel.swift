//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

class BannerTextViewModel: ObservableObject {
    private let accessibilityProvider: AccessibilityProviderProtocol
	private let localizationProvider: LocalizationProviderProtocol

    private(set) var title: String = ""
    private(set) var body: String = ""
    private(set) var linkDisplay: String = ""
    private(set) var link: String = ""
    private(set) var accessibilityLabel: String = ""

    init(accessibilityProvider: AccessibilityProviderProtocol,
         localizationProvider: LocalizationProviderProtocol) {
        self.accessibilityProvider = accessibilityProvider
        self.localizationProvider = localizationProvider
    }

    func update(bannerInfoType: BannerInfoType?) {
        if let bannerInfoType = bannerInfoType {
            self.title = localizationProvider.getLocalizedString(bannerInfoType.title)
            self.body = localizationProvider.getLocalizedString(bannerInfoType.body)
            self.linkDisplay = localizationProvider.getLocalizedString(bannerInfoType.linkDisplay)
            self.link = bannerInfoType.link
        } else {
            title = ""
            body = ""
            linkDisplay = ""
            link = ""
        }
        accessibilityLabel = "\(title) \(body) \(linkDisplay)"
        // UIKit workaround to update accessibility when focus should be changed and isModal shouldn't be set
        // for a consistent behaviour @AccessibilityFocusState should be used when min supported version is iOS 15+
        accessibilityProvider.moveFocusToFirstElement()
        objectWillChange.send()
    }
}
