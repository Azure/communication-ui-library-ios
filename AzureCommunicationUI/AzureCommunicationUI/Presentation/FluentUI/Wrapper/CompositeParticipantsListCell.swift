//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import FluentUI

class CompositeParticipantsListCell: TableViewCell {
    func setup(displayName: String, isMuted: Bool, accessoryType: TableViewCellAccessoryType = .none) {
        let isNameEmpty = displayName.trimmingCharacters(in: .whitespaces).isEmpty
        let avatar = MSFAvatar(style: .accent, size: .medium)
        avatar.state.primaryText = displayName
        let avatarView = avatar.view

        var micImageView: UIImageView?
        if isMuted {
            let micImage = StyleProvider.icon.getUIImage(for: .micOff)?
                .withTintColor(StyleProvider.color.mute, renderingMode: .alwaysOriginal)
            micImageView = UIImageView(image: micImage)
        }

        backgroundColor = UIDevice.current.userInterfaceIdiom == .pad
            ? StyleProvider.color.popoverColor
            : StyleProvider.color.drawerColor

        if isNameEmpty {
            setTitleLabelTextColor(color: UIColor.compositeColor(CompositeColor.mute))
        }

        setup(title: isNameEmpty ? "Unnamed Participant" : displayName,
              customView: avatarView,
              customAccessoryView: micImageView)
    }
}
