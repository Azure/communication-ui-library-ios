//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

class CallInfoListCellViewModel {
    let icon: CompositeIcon
    let title: String
    let detailTitle: String?
//    let accessibilityIdentifier: String
    let action: (() -> Void)?

    init(icon: CompositeIcon,
         title: String,
         detailTitle: String?,
//         accessibilityIdentifier: String,
         action: (() -> Void)?) {
        self.icon = icon
        self.title = title
        self.detailTitle = detailTitle
//        self.accessibilityIdentifier = accessibilityIdentifier
        self.action = action
    }
}
