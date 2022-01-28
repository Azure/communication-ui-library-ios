//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import FluentUI

class CompositeParticipantsListCell: TableViewCell {
    func setup(displayName: String,
               isMuted: Bool,
               partipantHasEmptyName: Bool,
               accessoryType: TableViewCellAccessoryType = .none) {
        let isNameEmpty = displayName.trimmingCharacters(in: .whitespaces).isEmpty
        let avatar = MSFAvatar(style: .accent, size: .medium)

        avatar.state.primaryText = !partipantHasEmptyName ? displayName : nil
        let avatarView = avatar.view

        var micImageView: UIImageView?
        if isMuted {
            let micImage = StyleProvider.icon.getUIImage(for: .micOffRegular)?
                .withTintColor(StyleProvider.color.mute, renderingMode: .alwaysOriginal)
            micImageView = UIImageView(image: micImage)
        }

        backgroundColor = UIDevice.current.userInterfaceIdiom == .pad
            ? StyleProvider.color.popoverColor
            : StyleProvider.color.drawerColor

        if isNameEmpty || partipantHasEmptyName {
            setTitleLabelTextColor(color: UIColor.compositeColor(CompositeColor.mute))
        } else {
            setTitleLabelTextColor(color: UIColor.compositeColor(CompositeColor.onSurface))
        }

        setup(title: isNameEmpty ? StringConstants.defaultEmptyName : displayName,
              customView: avatarView,
              customAccessoryView: micImageView)
    }
}
