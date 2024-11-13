//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import SwiftUI
internal struct DrawerTitleView: View {
    let item: TitleDrawerListItemViewModel

    var body: some View {
        HStack {
            if let icon = item.startCompositeIcon {
                Icon(name: icon, size: DrawerListConstants.iconSize)
                    .accessibilityHidden(true)
                    .onTapGesture {
                        item.startCompositeIconAction
                    }
            }
            Text(item.title)
                .foregroundColor(.primary)
                .padding(.leading, DrawerListConstants.textPaddingLeading)
                .font(.headline)
                .accessibilityAddTraits(.isHeader)
            if let icon = item.endIcon {
                Icon(name: icon, size: DrawerListConstants.iconSize)
                    .foregroundColor( .primary)
                    .accessibilityHidden(true)
                    .onTapGesture {
                        if let action = item.endIconAction {
                            action()
                        }
                    }
            }
            if let icon = item.expandIcon {
                Icon(name: icon, size: DrawerListConstants.iconSize)
                    .foregroundColor( .primary)
                    .accessibilityHidden(true)
                    .onTapGesture {
                        if let action = item.expandIconAction {
                            action()
                        }
                    }
            }
            Spacer()
        }
        .padding(.horizontal, DrawerListConstants.optionPaddingHorizontal)
        .padding(.vertical, DrawerListConstants.optionPaddingVertical)
        .frame(maxWidth: .infinity)
        .contentShape(Rectangle())
        .accessibilityIdentifier(item.accessibilityIdentifier)
        .background(Color(StyleProvider.color.drawerColor))
    }
}
