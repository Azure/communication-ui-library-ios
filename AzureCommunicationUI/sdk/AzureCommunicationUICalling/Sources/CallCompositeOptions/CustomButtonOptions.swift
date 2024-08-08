//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import UIKit

/// Represents the configuration options for a custom button.
public struct CustomButtonOptions {
    /// The image to be displayed on the button.
    public let image: UIImage

    /// The title to be displayed on the button.
    public let title: String

    /// A closure that will be executed when the button is clicked.
    /// The closure receives the `CustomButtonOptions` instance as a parameter.
    public let onClick: (CustomButtonOptions) -> Void

    /// A Boolean value that determines whether the button is enabled.
    /// - `true`: The button is enabled (default).
    /// - `false`: The button is disabled.
    public let enabled: Bool

    /// Initializes an instance of `CustomButtonOptions`.
    /// - Parameters:
    ///   - image: The image to be displayed on the button.
    ///   - title: The title to be displayed on the button.
    ///   - enabled: A Boolean value that determines whether the button is enabled. Default is `true`.
    ///   - onClick: A closure to be executed when the button is clicked.
    public init(image: UIImage,
                title: String,
                enabled: Bool = true,
                onClick: @escaping (CustomButtonOptions) -> Void) {
        self.image = image
        self.title = title
        self.onClick = onClick
        self.enabled = enabled
    }
}
