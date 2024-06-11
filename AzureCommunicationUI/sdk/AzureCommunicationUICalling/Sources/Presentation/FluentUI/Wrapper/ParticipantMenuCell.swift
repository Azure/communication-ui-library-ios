//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import FluentUI

class ParticipantMenuCell: TableViewCell {
    /// Set up the more call options list item  in the more call options list
    func setup(viewModel: DrawerListItemViewModel) {
        let iconImage = StyleProvider.icon.getUIImage(for: viewModel.icon)?
            .withTintColor(StyleProvider.color.drawerIconDark, renderingMode: .alwaysOriginal)
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
