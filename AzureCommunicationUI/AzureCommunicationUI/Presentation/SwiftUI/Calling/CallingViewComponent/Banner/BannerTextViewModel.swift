//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import UIKit
import SwiftUI

class BannerTextViewModel: ObservableObject {
    private(set) var title: String = ""
    private(set) var body: String = ""
    private(set) var linkDisplay: String = ""
    private(set) var link: String = ""
    private(set) var accessibilityLabel: String = ""

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
        // this code should be replaced with @AccessibilityFocusState when min supported version is iOS 15+
        UIAccessibility.post(notification: .screenChanged,
                             argument: nil)
        objectWillChange.send()
    }
}
