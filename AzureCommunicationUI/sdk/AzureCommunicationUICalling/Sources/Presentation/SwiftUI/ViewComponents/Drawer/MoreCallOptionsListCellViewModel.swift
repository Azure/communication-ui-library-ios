//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

class MoreCallOptionsListCellViewModel {
    let icon: CompositeIcon
    let title: String
    let accessibilityIdentifier: String
    let action: () -> Void

    init(icon: CompositeIcon,
         title: String,
         accessibilityIdentifier: String,
         action: @escaping () -> Void) {
        self.icon = icon
        self.title = title
        self.accessibilityIdentifier = accessibilityIdentifier
        self.action = action
    }
}

extension MoreCallOptionsListCellViewModel: Equatable {
     static func == (lhs: MoreCallOptionsListCellViewModel,
                     rhs: MoreCallOptionsListCellViewModel) -> Bool {
         return lhs.title == rhs.title &&
         lhs.accessibilityIdentifier == rhs.accessibilityIdentifier &&
         lhs.icon == rhs.icon
     }
 }
