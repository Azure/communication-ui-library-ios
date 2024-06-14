//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import FluentUI
import UIKit

class CaptionsLanguageListCell: TableViewCell {
    /// Set up the language list
    func setup(viewModel: SelectableDrawerListItemViewModel) {
        let speakerImage = StyleProvider.icon.getUIImage(for: viewModel.icon)?
            .withTintColor(StyleProvider.color.onSurface, renderingMode: .alwaysOriginal)
        let speakerImageView = UIImageView(image: speakerImage)

        var checkmarkImageView: UIImageView?
        if viewModel.isSelected {
            let checkmarkImage = StyleProvider.icon.getUIImage(for: .checkmark)?
                .withTintColor(StyleProvider.color.onSurface, renderingMode: .alwaysOriginal)
            checkmarkImageView = UIImageView(image: checkmarkImage)
            accessibilityTraits.insert(.selected)
        }

        selectionStyle = .none
        backgroundStyleType = .custom
        backgroundColor = UIDevice.current.userInterfaceIdiom == .pad
            ? StyleProvider.color.popoverColor
            : StyleProvider.color.drawerColor

        setTitleLabelTextColor(color: StyleProvider.color.onSurface)

        setup(title: viewModel.title,
              customView: speakerImageView,
              customAccessoryView: checkmarkImageView)
    }
}
