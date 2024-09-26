//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import UIKit
import Combine

/// Represents the view data for a custom button.
public class CustomButtonViewData: ObservableObject {
    /// Buttin id.
    public let id: String

    /// The image to be displayed on the button.
    @Published public var image: UIImage

    /// The title to be displayed on the button.
    @Published public var title: String

    /// A closure that will be executed when the button is clicked.
    /// The closure receives the `CustomButtonViewData` instance as a parameter.
    @Published public var onClick: (CustomButtonViewData) -> Void

    /// A Boolean value that determines whether the button is enabled.
    /// - `true`: The button is enabled (default).
    /// - `false`: The button is disabled.
    @Published public var enabled: Bool

    /// A Boolean value that determines whether the button is visible.
    /// - `true`: The button is visible (default).
    /// - `false`: The button is not visible.
    @Published public var visible: Bool

    /// Initializes an instance of `CustomButtonViewData`.
    /// - Parameters:
    ///   - id: The buttin id. Each button should have a unique id.
    ///   - image: The image to be displayed on the button.
    ///   - title: The title to be displayed on the button.
    ///   - enabled: A Boolean value that determines whether the button is enabled. Default is `true`.
    ///   - onClick: A closure to be executed when the button is clicked.
    public init(id: String,
                image: UIImage,
                title: String,
                enabled: Bool = true,
                visible: Bool = true,
                onClick: @escaping (CustomButtonViewData) -> Void) {
        self.id = id
        self.image = image
        self.title = title
        self.onClick = onClick
        self.enabled = enabled
        self.visible = visible
    }
}
