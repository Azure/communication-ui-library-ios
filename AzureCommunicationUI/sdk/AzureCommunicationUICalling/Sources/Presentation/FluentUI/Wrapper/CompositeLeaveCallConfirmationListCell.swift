//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import FluentUI
import UIKit

class CompositeLeaveCallConfirmationListCell: TableViewCell {

    /// Set up the participant list item  in the participant list
    func setup(viewModel: LeaveCallConfirmationViewModel) {
        let isNameEmpty = viewModel.title.trimmingCharacters(in: .whitespaces).isEmpty
        var micImageView: UIImageView?
        let micImage = StyleProvider.icon.getUIImage(for: viewModel.icon)?
            .withTintColor(StyleProvider.color.drawerIconDark, renderingMode: .alwaysOriginal)
        micImageView = UIImageView(image: micImage)

        selectionStyle = .none
        backgroundColor = UIDevice.current.userInterfaceIdiom == .pad
            ? StyleProvider.color.popoverColor
            : StyleProvider.color.drawerColor

        let title = NSAttributedString(
            string: viewModel.title,
            attributes: [.foregroundColor: isNameEmpty ?
                         StyleProvider.color.drawerIconDark :
                            StyleProvider.color.onSurface
                        ]
        )

        setup(attributedTitle: title, customView: micImageView)
        bottomSeparatorType = .none
    }
}
