//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import SwiftUI

protocol OverlayViewModelProtocol {
    var title: String { get }
    var subtitle: String? { get }
    var background: UIColor { get }
    var actionButtonViewModel: PrimaryButtonViewModel? { get }
    var errorInfoViewModel: ErrorInfoViewModel? { get }
    var isDisplayed: Bool { get }
}

extension OverlayViewModelProtocol {
    var subtitle: String? { return nil }
    var background: UIColor { return StyleProvider.color.overlay }
    var actionButtonViewModel: PrimaryButtonViewModel? { return nil }
    var errorInfoViewModel: ErrorInfoViewModel? { return nil }
}
