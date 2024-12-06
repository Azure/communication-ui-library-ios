//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import SwiftUI
import FluentUI

internal struct DrawerBodyTextView: View {
    let item: BodyTextDrawerListItemViewModel

    var body: some View {
        HStack {
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
        .accessibilityIdentifier(item.accessibilityIdentifier)
        .background(Color(StyleProvider.color.drawerColor))
    }
}

internal struct DrawerBodyWithActionTextView: View {
    let item: BodyTextWithActionDrawerListItemViewModel
    @State
    var isConfirming = false

    var body: some View {
        HStack {
            Text(item.title)
                .foregroundColor(.primary)
                .padding(.leading, DrawerListConstants.textPaddingLeading)
                .font(.body)
            Spacer()
            Text(item.actionText)
                .onTapGesture {
                    isConfirming = true
                }
                .padding(.leading, DrawerListConstants.textPaddingLeading)
                .foregroundColor(Color(StyleProvider.color.primaryColor))
        }
        .padding(.horizontal, DrawerListConstants.optionPaddingHorizontal)
        .padding(.vertical, DrawerListConstants.optionPaddingVertical)
        .frame(maxWidth: .infinity)
        .contentShape(Rectangle())
        .accessibilityIdentifier(item.accessibilityIdentifier)
        .accessibilityAddTraits(.isButton)
        .background(Color(StyleProvider.color.drawerColor))
        .fullScreenCover(isPresented: $isConfirming) {
            CustomAlert(
                title: item.confirmTitle,
                agreeText: item.confirmAccept,
                denyText: item.confirmDeny,
                dismiss: {
                    isConfirming = false
                },
                agreeAction: item.accept,
                denyAction: item.deny
            )
            .background(BackgroundCleanerView())
        }
        .transaction { transaction in
            transaction.disablesAnimations = true
            // transaction.animation = .linear(duration: 1)
        }
    }
}

internal struct DrawerIconTextActionListItemView: View {
    let item: IconTextActionListItemViewModel
    @State var isConfirming = false

    var body: some View {
        HStack {
            Icon(name: item.startCompositeIcon, size: DrawerListConstants.iconSize)
                .accessibilityHidden(true)
                .foregroundColor(item.isEnabled ? .primary : .gray)
            Text(item.title)
                .foregroundColor(item.isEnabled ? .primary : .gray)
                .padding(.leading, DrawerListConstants.textPaddingLeading)
                .font(.body)
                .onTapGesture {
                    isConfirming = true
                }
            Spacer()
        }
        .padding(.horizontal, DrawerListConstants.optionPaddingHorizontal)
        .padding(.vertical, DrawerListConstants.optionPaddingVertical)
        .frame(maxWidth: .infinity)
        .contentShape(Rectangle())
        .accessibilityIdentifier(item.accessibilityIdentifier)
        .accessibilityAddTraits(.isButton)
        .background(Color(StyleProvider.color.drawerColor))
        .opacity(item.isEnabled ? 1.0 : DrawerListConstants.disabledOpacity)
        .disabled(!item.isEnabled)
        .fullScreenCover(isPresented: $isConfirming) {
            CustomAlert(
                title: item.confirmTitle,
                message: item.confirmMessage,
                agreeText: item.confirmAccept,
                denyText: item.confirmDeny,
                dismiss: {
                    isConfirming = false
                },
                agreeAction: item.accept,
                denyAction: item.deny
            )
            .background(BackgroundCleanerView())
        }
        .transaction { transaction in
            transaction.disablesAnimations = true
        }
    }
}
