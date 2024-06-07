//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import SwiftUI

// Helper to inflate DrawerListItemViewModel into a drawer
internal struct DrawerListContent: View {
    let items: [DrawerListItemViewModel]
    var body: some View {
        VStack(spacing: DrawerListConstants.vStackSpacing) {
            ForEach(items) { option in
                if let selectableItem = option as? SelectableDrawerListItemViewModel {
                    SelectableDrawerItemView(item: selectableItem)
                } else {
                    DrawerItemView(item: option)
                }
            }
        }
    }
}

internal struct SelectableDrawerItemView: View {
    let item: SelectableDrawerListItemViewModel

    var body: some View {
        HStack {
            Icon(name: item.icon, size: DrawerListConstants.iconSize)
                .foregroundColor(.primary)
            Text(item.title)
                .foregroundColor(.primary)
                .padding(.leading, DrawerListConstants.textPaddingLeading)
                .font(.system(size: DrawerListConstants.textFontSize))
            Spacer()
        }
        .padding(.horizontal, DrawerListConstants.optionPaddingHorizontal)
        .frame(maxWidth: .infinity)
        .onTapGesture {
            item.action()
        }
    }
}

internal struct DrawerItemView: View {
    let item: DrawerListItemViewModel

    var body: some View {
        HStack {
            Icon(name: item.icon, size: DrawerListConstants.iconSize)
                .foregroundColor(.primary)
            Text(item.title)
                .foregroundColor(.primary)
                .padding(.leading, DrawerListConstants.textPaddingLeading)
                .font(.system(size: DrawerListConstants.textFontSize))
            Spacer()
        }
        .padding(.horizontal, DrawerListConstants.optionPaddingHorizontal)
        .frame(maxWidth: .infinity)
        .onTapGesture {
            item.action()
        }
    }
}
internal class DrawerListConstants {
    static let vStackSpacing: CGFloat = 16
    static let titleFontSize: CGFloat = 20
    static let titlePaddingTop: CGFloat = 20
    static let iconSize: CGFloat = 24
    static let textPaddingLeading: CGFloat = 8
    static let textFontSize: CGFloat = 18
    static let optionPaddingVertical: CGFloat = 8
    static let optionPaddingHorizontal: CGFloat = 16
    static let bottomPadding: CGFloat = 24
}
