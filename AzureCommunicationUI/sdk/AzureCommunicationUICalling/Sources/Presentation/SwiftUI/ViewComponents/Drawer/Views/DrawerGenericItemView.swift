//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import SwiftUI

internal struct DrawerGenericItemView: View {
    let item: DrawerGenericItemViewModel

    var body: some View {
        HStack {
            if let icon = item.startIcon {
                Icon(name: icon, size: DrawerListConstants.iconSize)
                    .foregroundColor(.primary)
            }
            Text(item.title)
                .foregroundColor(.primary)
                .padding(.leading, DrawerListConstants.textPaddingLeading)
                .font(.body)
            Spacer()
        }
        .padding(.horizontal, DrawerListConstants.optionPaddingHorizontal)
        .padding(.vertical, DrawerListConstants.optionPaddingVertical)
        .frame(maxWidth: .infinity)
        .contentShape(Rectangle())
        .opacity(item.isEnabled ? 1.0 : DrawerListConstants.disabledOpacity)
        .onTapGesture {
            if item.isEnabled {
                if let action = item.action {
                    action()
                }
            }
        }
        .accessibilityIdentifier(item.accessibilityIdentifier)
    }
}
