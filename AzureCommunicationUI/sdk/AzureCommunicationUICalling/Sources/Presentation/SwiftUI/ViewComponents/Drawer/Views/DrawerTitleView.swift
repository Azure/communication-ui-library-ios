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
                    .foregroundColor(Color(StyleProvider.color.drawerIconDark))
                    .onTapGesture {
                        if let action = item.startCompositeIconAction {
                            action()
                        }
                    }
            }
            Spacer()

            if let icon = item.endIcon {
                Icon(name: icon, size: DrawerListConstants.iconSize)
                    .foregroundColor(Color(StyleProvider.color.drawerIconDark))
                    .accessibilityHidden(true)
                    .onTapGesture {
                        if let action = item.endIconAction {
                            action()
                        }
                    }
            }
            if let icon = item.expandIcon {
                Icon(name: icon, size: DrawerListConstants.iconSize)
                    .foregroundColor(Color(StyleProvider.color.drawerIconDark))
                    .accessibilityHidden(true)
                    .onTapGesture {
                        if let action = item.expandIconAction {
                            action()
                        }
                    }
            }
        }
        .overlay(
            // Centered title overlay
            Text(item.title)
                .foregroundColor(.primary)
                .padding(.leading, DrawerListConstants.textPaddingLeading)
                .font(.headline)
                .accessibilityAddTraits(.isHeader)
        )
        .padding(.horizontal, DrawerListConstants.optionPaddingHorizontal)
        .padding(.vertical, DrawerListConstants.optionPaddingVertical)
        .frame(maxWidth: .infinity)
        .contentShape(Rectangle())
        .accessibilityIdentifier(item.accessibilityIdentifier)
        .background(Color(StyleProvider.color.drawerColor))
    }
}
