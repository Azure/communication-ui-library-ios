//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import UIKit

class CustomButtonState: ObservableObject {
    @Published var image: UIImage!
    @Published var description: String!
    @Published var badgeNumber: Int?

    @Published var isDisabled: Bool = false

    var action: (() -> Void)
    private(set) var type: CustomButtonType

    init(type: CustomButtonType,
         image: UIImage,
         label: String,
         badgeNumber: Int? = nil,
         action: @escaping (() -> Void) = {}) {
        self.type = type
        self.image = image
        self.description = label
        self.badgeNumber = badgeNumber
        self.action = action
    }

}
