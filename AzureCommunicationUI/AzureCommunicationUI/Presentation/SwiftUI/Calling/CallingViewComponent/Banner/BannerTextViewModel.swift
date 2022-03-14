//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

class BannerTextViewModel: ObservableObject {
    private(set) var title: String = ""
    private(set) var body: String = ""
    private(set) var linkDisplay: String = ""
    private(set) var link: String = ""
    private(set) var accessibilityLabel: String = ""
    private let accessibilityProvider: AccessibilityProvider

    init(accessibilityProvider: AccessibilityProvider) {
        self.accessibilityProvider = accessibilityProvider
    }

    func update(bannerInfoType: BannerInfoType?) {
        if let bannerInfoType = bannerInfoType {
            title = bannerInfoType.title
            body = bannerInfoType.body
            linkDisplay = bannerInfoType.linkDisplay
            link = bannerInfoType.link
        } else {
            title = ""
            body = ""
            linkDisplay = ""
            link = ""
        }
        accessibilityLabel = title + body + linkDisplay
        // UIKit workaround to update accessibility when focus should be changed and isModal shouldn't be set
        // for a consistent behaviour @AccessibilityFocusState should be used when min supported version is iOS 15+
        accessibilityProvider.moveFocusToFirstElement()
        objectWillChange.send()
    }
}
