//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import FluentUI
import UIKit

class MoreCallOptionsListCell: TableViewCell {
    /// Set up the more call options list item  in the more call options list
    func setup(viewModel: MoreCallOptionsListCellViewModel) {
        let iconImage = StyleProvider.icon.getUIImage(for: viewModel.icon)?
            .withTintColor(StyleProvider.color.drawerIconDark, renderingMode: .alwaysOriginal)
        let iconImageView = UIImageView(image: iconImage)

        selectionStyle = .none
        setup(title: viewModel.title,
              customView: iconImageView)
        bottomSeparatorType = .none
    }
}
