//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

class PopupMenuViewModel {
    let icon: CompositeIcon
    let title: String
    let isSelected: Bool
    let onSelected: (() -> Void)

    init(icon: CompositeIcon,
         title: String,
         isSelected: Bool,
         onSelected: @escaping (() -> Void)) {
        self.icon = icon
        self.title = title
        self.isSelected = isSelected
        self.onSelected = onSelected
    }
}
