//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import FluentUI
import UIKit

class CompositeParticipantsListCell: TableViewCell {

    /// Set up the participant list item  in the participant list
    /// - Parameter viewModel: the participant view model needed to set up participant list cell
    /// - Parameter avatarViewManager: the avatar view manager needed to set up avatar data
    func setup(viewModel: ParticipantsListCellViewModel,
               avatarViewManager: AvatarViewManager) {
        let participantViewData = viewModel.getParticipantViewData(from: avatarViewManager)
        let avatarParticipantName = viewModel.getParticipantName(with: participantViewData)
        let isNameEmpty = avatarParticipantName.trimmingCharacters(in: .whitespaces).isEmpty

        let avatar = MSFAvatar(style: isNameEmpty ? .outlined : .accent, size: .medium)
        avatar.state.primaryText = !isNameEmpty ? avatarParticipantName : nil
        avatar.state.image = participantViewData?.avatarImage
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

        accessibilityLabel = viewModel.getCellAccessibilityLabel(with: participantViewData)
        accessibilityTraits.remove(.button)

        setTitleLabelTextColor(color: isNameEmpty ?
                                UIColor.compositeColor(CompositeColor.mute)
                               :
                                UIColor.compositeColor(CompositeColor.onSurface))

        setup(title: viewModel.getCellDisplayName(with: participantViewData),
              customView: avatarView,
              customAccessoryView: micImageView)
        self.titleNumberOfLines = 2
    }
}
