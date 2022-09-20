//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import SwiftUI
import FluentUI

struct IconWithLabelButton<T: ButtonState>: View {
    @Environment(\.sizeCategory) var sizeCategory: ContentSizeCategory

    @ObservedObject var viewModel: IconWithLabelButtonViewModel<T>

    enum LayoutConstants {
        static let iconImageSize: CGFloat = 25
        static let verticalSpacing: CGFloat = 8
        static let width: CGFloat = 85
        static let height: CGFloat = 85
        static let buttonDisabledColor = Color(StyleProvider.color.disableColor)
    }

    var buttonForegroundColor: Color {
        switch viewModel.buttonTypeColor {
        case .colorThemedWhite:
            return Color(StyleProvider.color.onSurfaceColor)
        case .white:
            return Color(.white)
        }
    }

    var body: some View {
        Button(action: viewModel.action) {
            VStack(alignment: .center, spacing: LayoutConstants.verticalSpacing) {
                Icon(name: viewModel.iconName, size: LayoutConstants.iconImageSize)
                    .accessibilityHidden(true)
                if let buttonLabel = viewModel.buttonLabel {
                    if sizeCategory >= ContentSizeCategory.accessibilityMedium {
                        Text(buttonLabel)
                            .font(Fonts.button2Accessibility.font)
                    } else {
                        Text(buttonLabel)
                            .font(Fonts.button2.font)
                    }
                }
            }
        }
        .animation(nil)
        .disabled(viewModel.isDisabled)
        .foregroundColor(viewModel.isDisabled ? LayoutConstants.buttonDisabledColor : buttonForegroundColor)
        .frame(width: LayoutConstants.width, height: LayoutConstants.height, alignment: .top)
        .accessibilityLabel(Text(viewModel.accessibilityLabel ?? ""))
        .accessibilityValue(Text(viewModel.accessibilityValue ?? ""))
        .accessibilityHint(Text(viewModel.accessibilityHint ?? ""))
    }
}
