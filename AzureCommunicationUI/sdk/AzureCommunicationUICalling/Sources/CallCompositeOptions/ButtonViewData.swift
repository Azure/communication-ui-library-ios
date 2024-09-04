//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import UIKit
import Combine

/// Represents view data for a button.
public class ButtonViewData: ObservableObject {
    /// A closure that will be executed when the button is clicked.
    /// The closure receives the `ButtonViewData` instance as a parameter.
    @Published public var onClick: ((ButtonViewData) -> Void)?

    /// A Boolean value that determines whether the button is visible.
    /// - `true`: The button is visible (default).
    /// - `false`: The button is hidden.
    @Published public var visible: Bool

    /// A Boolean value that determines whether the button is enabled.
    /// - `true`: The button is enabled (default).
    /// - `false`: The button is disabled.
    @Published public var enabled: Bool

    /// Initializes an instance of `ButtonViewData`.
    /// - Parameters:
    ///   - visible: A Boolean value that determines whether the button is visible. Default is `true`.
    ///   - enabled: A Boolean value that determines whether the button is enabled. Default is `true`.
    ///   - onClick: A closure to be executed when the button is clicked. Default is `nil`.
    public init(visible: Bool = true,
                enabled: Bool = true,
                onClick: ((ButtonViewData) -> Void)? = nil) {
        self.onClick = onClick
        self.visible = visible
        self.enabled = enabled
    }
}
