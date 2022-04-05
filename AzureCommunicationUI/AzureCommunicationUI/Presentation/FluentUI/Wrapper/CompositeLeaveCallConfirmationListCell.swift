//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import FluentUI

class CompositeLeaveCallConfirmationListCell: TableViewCell {

    /// Set up the participant list item  in the participant list
    func setup(displayName: String) {
        let isNameEmpty = displayName.trimmingCharacters(in: .whitespaces).isEmpty
        var micImageView: UIImageView?
        let micImage = StyleProvider.icon.getUIImage(for: .micOffRegular)?
            .withTintColor(StyleProvider.color.mute, renderingMode: .alwaysOriginal)
        micImageView = UIImageView(image: micImage)

        selectionStyle = .none
        backgroundColor = UIDevice.current.userInterfaceIdiom == .pad
            ? StyleProvider.color.popoverColor
            : StyleProvider.color.drawerColor

        setTitleLabelTextColor(color: isNameEmpty ?
                                UIColor.compositeColor(CompositeColor.mute)
                               :
                                UIColor.compositeColor(CompositeColor.onSurface))

        setup(title: displayName,
              customAccessoryView: micImageView)
    }
}
