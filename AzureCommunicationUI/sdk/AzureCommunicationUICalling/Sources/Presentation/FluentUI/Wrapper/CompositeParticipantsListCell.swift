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

        selectionStyle = .none
        backgroundColor = UIDevice.current.userInterfaceIdiom == .pad
            ? StyleProvider.color.popoverColor
            : StyleProvider.color.drawerColor

        accessibilityLabel = viewModel.getCellAccessibilityLabel(with: participantViewData)
        accessibilityTraits.remove(.button)

        let title = NSAttributedString(string: viewModel.getCellDisplayName(with: participantViewData),
                           attributes: [.foregroundColor: isNameEmpty ?
                                        StyleProvider.color.drawerIconDark :
                                        StyleProvider.color.onSurface]
        )

        let customAccessoryView = getCustomAccessoryView(isHold: viewModel.isHold,
                                                         onHoldString: viewModel.getOnHoldString(),
                                                         isMuted: viewModel.isMuted)
        setup(attributedTitle: title,
              customView: avatar,
              customAccessoryView: customAccessoryView)
        self.titleNumberOfLines = 2
    }

    func getCustomAccessoryView(isHold: Bool,
                                onHoldString: String,
                                isMuted: Bool) -> UIView {
        guard !isHold else {
            let label = Label(style: .body, colorStyle: .secondary)
            label.text = onHoldString
            label.textColor = StyleProvider.color.onHoldLabel
            label.sizeToFit()
            label.numberOfLines = 0
            return label
        }
        var micImage: UIImage?
        if isMuted {
            micImage = StyleProvider.icon.getUIImage(for: .micOffRegular)?
                .withTintColor(StyleProvider.color.drawerIconDark, renderingMode: .alwaysOriginal)
        } else {
            micImage = StyleProvider.icon.getUIImage(for: .micOnRegular)?
                .withTintColor(StyleProvider.color.drawerIconDark, renderingMode: .alwaysOriginal)
        }
        return UIImageView(image: micImage)
    }
}
