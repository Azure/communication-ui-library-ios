//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import FluentUI

class CompositeParticipantsListCell: TableViewCell {

    /// Set up the participant list item  in the participant list
    /// - Parameters:
    ///   - displayName: The display name shown on the participant list cell
    ///   - isMuted: tells whether this participant is muted
    ///   - partipantHasEmptyName: tells whether this participant had an empty name when joined the call
    ///   - accessoryType: accessory type
    func setup(displayName: String,
               isMuted: Bool,
               partipantHasEmptyName: Bool,
               accessoryType: TableViewCellAccessoryType = .none) {
        let isNameEmpty = displayName.trimmingCharacters(in: .whitespaces).isEmpty
        let avatar = MSFAvatar(style: partipantHasEmptyName ? .outlined : .accent, size: .medium)

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

        let isAnonymousUser = isNameEmpty || partipantHasEmptyName

        if isAnonymousUser {
            setTitleLabelTextColor(color: UIColor.compositeColor(CompositeColor.mute))
        } else {
            setTitleLabelTextColor(color: UIColor.compositeColor(CompositeColor.onSurface))
        }

        setup(title: isAnonymousUser ? StringConstants.defaultEmptyName : displayName,
              customView: avatarView,
              customAccessoryView: micImageView)
    }
}
