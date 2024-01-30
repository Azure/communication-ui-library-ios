//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import SwiftUI
import FluentUI

struct MessageBarDiagnosticView: View {
    @ObservedObject var viewModel: MessageBarDiagnosticViewModel

    private let cornerRadius: CGFloat = 6
    private let foregroundColor: Color = .white
    private let horizontalPadding: CGFloat = 12
    private let height: CGFloat = 48

    var body: some View {
        if viewModel.isDisplayed {
            HStack(alignment: .center) {
                if let icon = viewModel.icon {
                    IconProvider().getImage(for: icon)
                        .frame(width: 24, height: 24)
                        .foregroundColor(foregroundColor)
                        .padding(
                            EdgeInsets(
                                top: 0, leading: horizontalPadding, bottom: 0, trailing: 0)
                        )
                        .accessibilityHidden(true)
                }
                Text(viewModel.text)
                    .font(Fonts.footnote.font)
                    .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 16))
                    .multilineTextAlignment(.center)
                    .foregroundColor(foregroundColor)
                    .accessibilitySortPriority(2)

                Spacer()
                Button(action: {
                    viewModel.callDiagnosticViewModel?
                        .dismissMessageBar(diagnostic: viewModel.mediaDiagnostic)
                }, label: {
                    IconProvider().getImage(for: .dismiss)
                        .frame(width: 16, height: 16)
                        .foregroundColor(foregroundColor)
                })
                .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: horizontalPadding))
                .accessibilityIdentifier(
                    AccessibilityIdentifier.callDiagnosticMessageBarAccessibilityID.rawValue)
                .accessibilityAddTraits(.isButton)
                .accessibilityLabel(Text(viewModel.dismissAccessibilitylabel))
                .accessibilityHint(Text(viewModel.dismissAccessibilityHint))
                .accessibilitySortPriority(0)
            }
            .frame(height: height)
            .background(Color(StyleProvider.color.surfaceDarkColor))
            .cornerRadius(cornerRadius)
            .accessibilityAddTraits(.isStaticText)
            .accessibilityIdentifier(
                AccessibilityIdentifier.callDiagnosticMessageBarAccessibilityID.rawValue)
        }
    }
}
