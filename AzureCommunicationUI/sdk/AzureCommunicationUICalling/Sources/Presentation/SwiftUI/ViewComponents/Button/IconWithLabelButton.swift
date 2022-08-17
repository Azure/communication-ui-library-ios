//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import SwiftUI
import FluentUI

struct IconWithLabelButton: View {
    @Environment(\.sizeCategory) var sizeCategory: ContentSizeCategory

    @ObservedObject var viewModel: IconWithLabelButtonViewModel

    private let iconImageSize: CGFloat = 25
    private let verticalSpacing: CGFloat = 8
    private let width: CGFloat = 85
    private let height: CGFloat = 85
    private let buttonDisabledColor = Color(StyleProvider.color.genericIconDisabled)

    var buttonForegroundColor: Color {
        switch viewModel.buttonTypeColor {
        case .colorThemedWhite:
            return Color(StyleProvider.color.genericIcon)
        case .white:
            return Color(.white)
        }
    }

    var body: some View {
        Button(action: viewModel.action) {
            VStack(alignment: .center, spacing: verticalSpacing) {
                Icon(name: viewModel.iconName, size: iconImageSize)
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
        .foregroundColor(viewModel.isDisabled ? buttonDisabledColor : buttonForegroundColor)
        .frame(width: width, height: height, alignment: .top)
        .accessibilityLabel(Text(viewModel.accessibilityLabel ?? ""))
        .accessibilityValue(Text(viewModel.accessibilityValue ?? ""))
        .accessibilityHint(Text(viewModel.accessibilityHint ?? ""))
    }
}
