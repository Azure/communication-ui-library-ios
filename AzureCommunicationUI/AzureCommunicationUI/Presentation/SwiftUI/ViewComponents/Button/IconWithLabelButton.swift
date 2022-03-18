//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import SwiftUI
import FluentUI

struct IconWithLabelButton: View {
    @ObservedObject var viewModel: IconWithLabelButtonViewModel

    private let iconImageSize: CGFloat = 25
    private let verticalSpacing: CGFloat = 8
    private let width: CGFloat = 85
    private let height: CGFloat = 85
    private let buttonDisabledColor = Color(StyleProvider.color.onDisabled)

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
            VStack(alignment: .center, spacing: verticalSpacing) {
                Icon(name: viewModel.iconName, size: iconImageSize)
                    .accessibility(hidden: true)
                if let buttonLabel = viewModel.buttonLabel {
                    Text(buttonLabel)
                        .font(Fonts.button2.font)
                }
            }
        }
        .animation(nil)
        .disabled(viewModel.isDisabled)
        .foregroundColor(viewModel.isDisabled ? buttonDisabledColor : buttonForegroundColor)
        .frame(width: width, height: height, alignment: .top)
        .accessibility(label: Text(viewModel.accessibilityLabel ?? ""))
        .accessibility(value: Text(viewModel.accessibilityValue ?? ""))
        .accessibility(hint: Text(viewModel.accessibilityHint ?? ""))
    }
}
