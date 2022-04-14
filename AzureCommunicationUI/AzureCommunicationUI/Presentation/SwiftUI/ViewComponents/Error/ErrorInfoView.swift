//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import SwiftUI
import FluentUI

struct ErrorInfoView: View {
    @ObservedObject var viewModel: ErrorInfoViewModel

    private let cornerRadius: CGFloat = 4

    var body: some View {
        if viewModel.isDisplayed {
            HStack {
                Text(viewModel.message)
                    .padding([.top, .leading, .bottom])
                    .font(Fonts.footnote.font)
                    .foregroundColor(Color(StyleProvider.color.onWarning))
                    .accessibilityLabel(Text(viewModel.accessibilityLabel))
                    .accessibilitySortPriority(1)
                Spacer()
                Button(action: dismissAction) {
                    Text(viewModel.dismissContent)
                        .font(Fonts.button1.font)
                        .foregroundColor(Color(StyleProvider.color.onWarning))
                }
                .padding([.top, .bottom, .trailing])
                .accessibilityLabel(Text(viewModel.dismissButtonAccessibilityLabel))
                .accessibilityHint(Text(viewModel.dismissButtonAccessibilityHint))
                .accessibilitySortPriority(0)
            }
            .background(Color(StyleProvider.color.warning))
            .cornerRadius(cornerRadius)
        }
    }

    func dismissAction() {
        viewModel.isDisplayed = false
    }
}
