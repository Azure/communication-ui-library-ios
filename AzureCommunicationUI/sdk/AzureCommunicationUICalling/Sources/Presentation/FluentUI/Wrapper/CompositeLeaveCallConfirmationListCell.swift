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
        var micImageView: UIImageView?
        let micImage = StyleProvider.icon.getUIImage(for: viewModel.icon)?
            .withTintColor(StyleProvider.color.drawerIconDark, renderingMode: .alwaysOriginal)
        micImageView = UIImageView(image: micImage)

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
