//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import FluentUI
import UIKit

class CaptionsLanguageListCell: TableViewCell {
    /// Set up the language list
    func setup(viewModel: DrawerListItemViewModel) {
        selectionStyle = .none
        backgroundStyleType = .custom
        backgroundColor = UIDevice.current.userInterfaceIdiom == .pad
            ? StyleProvider.color.popoverColor
            : StyleProvider.color.drawerColor
        setup(title: viewModel.title)
        bottomSeparatorType = .none
        titleNumberOfLines = 0
    }
}
