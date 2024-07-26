//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import UIKit

public struct ButtonOptions {
    public let onClick: ((ButtonOptions) -> Void)?
    public let visible: Bool
    public let enabled: Bool

    public init(visible: Bool = true,
                enabled: Bool = true,
                onClick: ((ButtonOptions) -> Void)? = nil) {
        self.onClick = onClick
        self.visible = visible
        self.enabled = enabled
    }
}
