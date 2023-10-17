//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import SwiftUI
import FluentUI

struct CallDiagnosticView: View {
    @ObservedObject var viewModel: CallDiagnosticViewModel

    private let cornerRadius: CGFloat = 12

    var body: some View {
        if viewModel.isDisplayed {
            HStack {
                VStack(alignment: .leading, spacing: 0) {
                    Text(viewModel.title)
                        .font(Fonts.button1.font)
                        .foregroundColor(Color(StyleProvider.color.onSurface))
                        .accessibilitySortPriority(1)

                    if !viewModel.subtitle.isEmpty {
                        Text(viewModel.subtitle)
                            .font(Fonts.subhead.font)
                            .foregroundColor(Color(StyleProvider.color.onSurface))
                            .accessibilitySortPriority(2)
                    }
                }.padding([.top, .leading, .bottom])
                Spacer()
                Button(action: viewModel.dismiss) {
                    Text(viewModel.dismissContent)
                        .font(Fonts.button1.font)
                        .foregroundColor(Color(StyleProvider.color.onSurface))
                }
                .padding([.top, .bottom, .trailing])
                .accessibilityLabel(Text(viewModel.dismissAccessibilitylabel))
                .accessibilityHint(Text(viewModel.dismissAccessibilityHint))
                .accessibilitySortPriority(0)
            }
            .background(Color(StyleProvider.color.backgroundColor))
            .cornerRadius(cornerRadius)
        }
    }
}
