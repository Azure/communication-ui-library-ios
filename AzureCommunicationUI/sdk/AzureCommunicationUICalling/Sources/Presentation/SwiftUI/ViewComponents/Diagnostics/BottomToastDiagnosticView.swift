//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import SwiftUI
import FluentUI

struct BottomToastDiagnosticView: View {
    @ObservedObject var viewModel: BottomToastDiagnosticViewModel

    private let cornerRadius: CGFloat = 6
    private let foregroundColor: Color = .white
    private let horizontalPadding: CGFloat = 10
    private let height: CGFloat = 36

    var body: some View {
        HStack(alignment: .center) {
            if let icon = viewModel.icon {
                IconProvider().getImage(for: icon)
                    .frame(width: 16, height: 16)
                    .foregroundColor(foregroundColor)
                    .padding(
                        EdgeInsets(
                            top: 0, leading: horizontalPadding, bottom: 0, trailing: 0)
                    )
            }
            Text(viewModel.text)
                .font(Fonts.caption1.font)
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
            AccessibilityIdentifier.callDiagnosticBottomToastAccessibilityID.rawValue)
    }
}
