//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import FluentUI
import UIKit

class CompositeLeaveCallConfirmationListCell: TableViewCell {

    /// Set up the participant list item  in the participant list
    func setup(viewModel: DrawerListItemViewModel) {
        let isNameEmpty = viewModel.title.trimmingCharacters(in: .whitespaces).isEmpty
        var micImage = if let compositIcon = viewModel.compositIcon {
            StyleProvider.icon.getUIImage(for: compositIcon)
        } else if let icon = viewModel.icon {
            viewModel.icon
        } else {
            nil as UIImage?
        }
        micImage = micImage?.withTintColor(StyleProvider.color.drawerIconDark, renderingMode: .alwaysOriginal)
        let micImageView = UIImageView(image: micImage)

        selectionStyle = .none
        backgroundStyleType = .custom
        backgroundColor = UIDevice.current.userInterfaceIdiom == .pad
            ? StyleProvider.color.popoverColor
            : StyleProvider.color.drawerColor

        setTitleLabelTextColor(color: isNameEmpty
                               ? StyleProvider.color.drawerIconDark
                               : StyleProvider.color.onSurface)

        setup(title: viewModel.title,
              customView: micImageView)
        bottomSeparatorType = .none
    }
}
