//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import FluentUI

class CompositeParticipantsListCell: TableViewCell {

    /// Set up the participant list item  in the participant list
    /// - Parameter viewModel: the participant view model needed to set up participant list cell
    func setup(viewModel: ParticipantsListCellViewModel,
               displayName: String) {
        let isNameEmpty = viewModel.displayName.trimmingCharacters(in: .whitespaces).isEmpty

        let avatar = MSFAvatar(style: isNameEmpty ? .outlined : .accent, size: .medium)
        avatar.state.primaryText = !isNameEmpty ? viewModel.displayName : nil
        let avatarView = avatar.view

        var micImage: UIImage?
        var micImageView: UIImageView?
        if viewModel.isMuted {
            micImage = StyleProvider.icon.getUIImage(for: .micOffRegular)?
                .withTintColor(StyleProvider.color.mute, renderingMode: .alwaysOriginal)
        } else {
            micImage = StyleProvider.icon.getUIImage(for: .micOnRegular)?
                .withTintColor(StyleProvider.color.mute, renderingMode: .alwaysOriginal)
        }
        micImageView = UIImageView(image: micImage)

        selectionStyle = .none
        backgroundColor = UIDevice.current.userInterfaceIdiom == .pad
            ? StyleProvider.color.popoverColor
            : StyleProvider.color.drawerColor

        accessibilityLabel = viewModel.getCellAccessibilityLabel()
        accessibilityTraits.remove(.button)

        setTitleLabelTextColor(color: isNameEmpty ?
                                UIColor.compositeColor(CompositeColor.mute)
                               :
                                UIColor.compositeColor(CompositeColor.onSurface))

        setup(title: displayName,
              customView: avatarView,
              customAccessoryView: micImageView)
        self.titleNumberOfLines = 2
    }
}
