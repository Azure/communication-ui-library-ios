//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import UIKit

public struct CustomButtonOptions {
    public let image: UIImage
    public let title: String
    public let onClick: (CustomButtonOptions) -> Void
    public let enabled: Bool

    public init(image: UIImage,
                title: String,
                visible: Bool = true,
                enabled: Bool = true,
                onClick: @escaping (CustomButtonOptions) -> Void) {
        self.image = image
        self.title = title
        self.onClick = onClick
        self.enabled = enabled
    }
}
