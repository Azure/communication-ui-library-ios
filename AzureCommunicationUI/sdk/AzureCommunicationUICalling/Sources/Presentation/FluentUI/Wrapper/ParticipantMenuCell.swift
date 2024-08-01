//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import FluentUI

class ParticipantMenuCell: TableViewCell {
    /// Set up the more call options list item  in the more call options list
    func setup(viewModel: DrawerListItemViewModel) {
        var iconImage = if let compositIcon = viewModel.compositIcon {
            StyleProvider.icon.getUIImage(for: compositIcon)
        } else if let icon = viewModel.icon {
            viewModel.icon
        } else {
            nil as UIImage?
        }
        iconImage = iconImage?.withTintColor(StyleProvider.color.drawerIconDark, renderingMode: .alwaysOriginal)
        let iconImageView = UIImageView(image: iconImage)

        selectionStyle = .none
        backgroundStyleType = .custom
        backgroundColor = UIDevice.current.userInterfaceIdiom == .pad
            ? StyleProvider.color.popoverColor
            : StyleProvider.color.drawerColor
        setup(title: viewModel.title,
              customView: iconImageView)
        bottomSeparatorType = .none
        titleNumberOfLines = 1
        isEnabled = viewModel.isEnabled
    }
}
