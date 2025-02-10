//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import SwiftUI
import FluentUI

struct BottomToastView: View {
    @ObservedObject var viewModel: BottomToastViewModel

    private let cornerRadius: CGFloat = 6
    private let foregroundColor: Color = .white
    private let horizontalPadding: CGFloat = 10
    private let height: CGFloat = 36

    var body: some View {
        if viewModel.visible {
            HStack(alignment: .center) {
                if let icon = viewModel.icon {
                    IconProvider().getImage(for: icon)
                        .frame(width: 16, height: 16)
                        .foregroundColor(foregroundColor)
                        .padding(
                            EdgeInsets(
                                top: 0, leading: horizontalPadding, bottom: 0, trailing: 0)
                        )
                        .accessibilityHidden(true)
                }
                Text(viewModel.text)
                    .font(StyleProvider.font.caption1)
                    .padding(
                        EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: horizontalPadding))
                    .multilineTextAlignment(.center)
                    .foregroundColor(foregroundColor)
                    .accessibilitySortPriority(2)
            }
            .frame(height: height)
            .background(Color(StyleProvider.color.surfaceDarkColor))
            .cornerRadius(cornerRadius)
            .accessibilityAddTraits(.isStaticText)
            .accessibilityIdentifier(
                AccessibilityIdentifier.callBottomToastAccessibilityID.rawValue)
        }
    }
}
