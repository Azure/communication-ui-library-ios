//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import FluentUI
import UIKit

class CompositeSupportFormCell: TableViewCell {

    /// Set up the audio device list item in the audio device list
    /// - Parameter viewModel: the audio device view model needed to set up audio device list cell
    func setup(viewModel: SupportFormViewModel) {
        selectionStyle = .none
        backgroundStyleType = .custom
        backgroundColor = UIDevice.current.userInterfaceIdiom == .pad
            ? StyleProvider.color.popoverColor
            : StyleProvider.color.drawerColor
        setup(title: "viewModel.title", subtitle: "subtitle")
    }
}
