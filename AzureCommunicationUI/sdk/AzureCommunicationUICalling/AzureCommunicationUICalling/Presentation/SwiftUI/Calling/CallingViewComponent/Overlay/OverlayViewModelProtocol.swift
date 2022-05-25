//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

protocol OverlayViewModelProtocol {
    var title: String { get }
    var subtitle: String? { get }
    var getActionButtonViewModel: PrimaryButtonViewModel? { get }
}
