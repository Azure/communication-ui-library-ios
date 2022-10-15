//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import FluentUI
import UIKit

class CallInfoListCell: TableViewCell {

    /// Set up the participant list item  in the participant list
    func setup(viewModel: CallInfoListCellViewModel) {
        let iconImage = StyleProvider.icon.getUIImage(for: viewModel.icon)?
            .withTintColor(StyleProvider.color.drawerIconDark, renderingMode: .alwaysOriginal)
        let iconImageView = UIImageView(image: iconImage)
        var detailLabel: Label?
        if let detailTitle = viewModel.detailTitle {

            detailLabel = Label()
            detailLabel?.text = detailTitle
//            detailLabel?.textColor = StyleProvider.color.onNavigationSecondary
        } else {
            detailLabel = nil
        }

        selectionStyle = .none
        setup(title: viewModel.title,
              customView: iconImageView,
              customAccessoryView: detailLabel)
        bottomSeparatorType = .none
    }
}
