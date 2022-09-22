//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import SwiftUI

public struct OverlayOptions {
    /// The transition associated with the overlay appearance
    let overlayTransition: AnyTransition // possible difference between iOS and Android? (for now)
    /// The Bool value to indicate if PIP view should shown on top of the overlay
    let showPIP: Bool
    /// PIPViewOptions used to customize PIP view for the overlay
    let pipViewOptions: PIPViewOptions?

    /// Create an instance of a OverlayOptions.
    /// - Parameters:
    ///   - transition: The transition associated with the overlay appearance
    ///   - showPIP: The Bool value to indicate if PIP view should shown on top of the overlay   
    ///   - pipViewOptions: PIPViewOptions used to customize PIP view for the overlay
    public init(overlayTransition: AnyTransition,
                showPIP: Bool,
                pipViewOptions: PIPViewOptions? = nil) {
        self.overlayTransition = overlayTransition
        self.showPIP = showPIP
        self.pipViewOptions = pipViewOptions
    }
}

public struct PIPViewOptions {
    /// Default position where the PIP view is shown
    public enum DefaultPosition {
        case topLeft, topRight,
             bottomLeft, bottomRight
    }

    /// The Bool value to indicate if PIP view is draggable
    let isDraggable: Bool
    /// The draggable area margins for PIP view
    let pipDraggableAreaMargins: UIEdgeInsets
    /// The default position of the PIP view
    let defaultPosition: DefaultPosition

    /// Create an instance of a PIPViewOptions.
    /// - Parameters:
    ///   - isDraggable: The Bool value to indicate if PIP view is draggable
    ///   - pipDraggableAreaMargins: The draggable area margins for PIP view
    ///   - defaultPosition: The default position of the PIP view
    public init(isDraggable: Bool,
                pipDraggableAreaMargins: UIEdgeInsets,
                defaultPosition: DefaultPosition) {
        self.isDraggable = isDraggable
        self.pipDraggableAreaMargins = pipDraggableAreaMargins
        self.defaultPosition = defaultPosition
    }
}
