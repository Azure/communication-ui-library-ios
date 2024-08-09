//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import UIKit

/// Represents configuration options for a button.
public struct ButtonOptions {
    /// A closure that will be executed when the button is clicked.
    /// The closure receives the `ButtonOptions` instance as a parameter.
    public let onClick: ((ButtonOptions) -> Void)?

    /// A Boolean value that determines whether the button is visible.
    /// - `true`: The button is visible (default).
    /// - `false`: The button is hidden.
    public let visible: Bool

    /// A Boolean value that determines whether the button is enabled.
    /// - `true`: The button is enabled (default).
    /// - `false`: The button is disabled.
    public let enabled: Bool

    /// Initializes an instance of `ButtonOptions`.
    /// - Parameters:
    ///   - visible: A Boolean value that determines whether the button is visible. Default is `true`.
    ///   - enabled: A Boolean value that determines whether the button is enabled. Default is `true`.
    ///   - onClick: A closure to be executed when the button is clicked. Default is `nil`.
    public init(visible: Bool = true,
                enabled: Bool = true,
                onClick: ((ButtonOptions) -> Void)? = nil) {
        self.onClick = onClick
        self.visible = visible
        self.enabled = enabled
    }
}
