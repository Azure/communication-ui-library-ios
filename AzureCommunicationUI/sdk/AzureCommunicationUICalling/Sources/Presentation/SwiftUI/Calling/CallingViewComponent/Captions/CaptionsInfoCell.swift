//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import FluentUI
import UIKit

class CaptionsInfoCell: TableViewCell {

    /// Set up the participant list item  in the participant list
    /// - Parameter viewModel: the participant view model needed to set up participant list cell
    /// - Parameter avatarViewManager: the avatar view manager needed to set up avatar data
    func setup(viewModel: ParticipantsListCellViewModel,
               avatarViewManager: AvatarViewManager) {
        let participantViewData = viewModel.getParticipantViewData(from: avatarViewManager)
        let avatarParticipantName = viewModel.getParticipantName(with: participantViewData)
        let isNameEmpty = avatarParticipantName.trimmingCharacters(in: .whitespaces).isEmpty

        let avatar = MSFAvatar(style: isNameEmpty ? .outlined : .accent, size: .size32)
        avatar.state.primaryText = !isNameEmpty ? avatarParticipantName : nil
        avatar.state.image = participantViewData?.avatarImage

        selectionStyle = .none
        backgroundStyleType = .custom
        backgroundColor = UIDevice.current.userInterfaceIdiom == .pad
            ? StyleProvider.color.popoverColor
            : StyleProvider.color.drawerColor

        accessibilityLabel = viewModel.getCellAccessibilityLabel(with: participantViewData)
        accessibilityTraits.remove(.button)

        setTitleLabelTextColor(color: isNameEmpty ?
                               StyleProvider.color.drawerIconDark :
                               StyleProvider.color.onSurface)

        setup(title: viewModel.getCellDisplayName(with: participantViewData),
              customView: avatar,
              customAccessoryView: customAccessoryView)

        self.titleNumberOfLines = 2
    }
}
