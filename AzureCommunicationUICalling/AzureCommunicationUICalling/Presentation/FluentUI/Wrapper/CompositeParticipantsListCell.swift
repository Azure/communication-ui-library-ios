//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import FluentUI

class CompositeParticipantsListCell: TableViewCell {

    /// Set up the participant list item  in the participant list
    /// - Parameter viewModel: the participant view model needed to set up participant list cell
    func setup(viewModel: ParticipantsListCellViewModel) {
        let isNameEmpty = viewModel.displayName.trimmingCharacters(in: .whitespaces).isEmpty

        let avatar = MSFAvatar(style: isNameEmpty ? .outlined : .accent, size: .medium)
        avatar.state.primaryText = !isNameEmpty ? viewModel.displayName : nil
        let avatarView = avatar.view

        var micImageView: UIImageView?
        if viewModel.isMuted {
            let micImage = StyleProvider.icon.getUIImage(for: .micOffRegular)?
                .withTintColor(StyleProvider.color.mute, renderingMode: .alwaysOriginal)
            micImageView = UIImageView(image: micImage)
        }

        selectionStyle = .none
        backgroundColor = UIDevice.current.userInterfaceIdiom == .pad
            ? StyleProvider.color.popoverColor
            : StyleProvider.color.drawerColor

        setTitleLabelTextColor(color: isNameEmpty ?
                                UIColor.compositeColor(CompositeColor.mute)
                               :
                                UIColor.compositeColor(CompositeColor.onSurface))

        setup(title: displayName(displayName: viewModel.displayName,
                                 isLocalParticipant: viewModel.isLocalParticipant),
              customView: avatarView,
              customAccessoryView: micImageView)
    }

    private func displayName(displayName: String, isLocalParticipant: Bool) -> String {
        let isNameEmpty = displayName.trimmingCharacters(in: .whitespaces).isEmpty
        if isLocalParticipant {
            return isNameEmpty ?
            "\(StringConstants.defaultEmptyName) \(StringConstants.localParticipantNamePostfix)"
            :
            "\(displayName) \(StringConstants.localParticipantNamePostfix)"
        } else {
            return isNameEmpty ? "\(StringConstants.defaultEmptyName)"
            :
            displayName
        }
    }
}
