//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import UIKit

public struct ButtonOptions {
    public let image: UIImage?
    public let title: String?
    public let onClick: (() -> Void)?
    public let visible: Bool
    public let enabled: Bool

    public init(image: UIImage? = nil,
                title: String? = nil,
                onClick: (() -> Void)? = nil,
                visible: Bool = true,
                enabled: Bool = true) {
        self.image = image
        self.title = title
        self.onClick = onClick
        self.visible = visible
        self.enabled = enabled
    }
}
