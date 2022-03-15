//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import SwiftUI
import FluentUI

struct ErrorInfoView: View {
    @ObservedObject var viewModel: ErrorInfoViewModel

    private let cornerRaidus: CGFloat = 4

    var body: some View {
        if viewModel.isDisplayed {
            HStack {
                Text(viewModel.message)
                    .padding([.top, .leading, .bottom])
                    .font(Fonts.footnote.font)
                    .foregroundColor(Color(StyleProvider.color.onWarning))
                Spacer()
                Button(action: dismissAction) {
                    Text("Dismiss")
                        .font(Fonts.button1.font)
                        .foregroundColor(Color(StyleProvider.color.onWarning))
                }
                .padding([.top, .bottom, .trailing])
            }
            .background(Color(StyleProvider.color.warning))
            .cornerRadius(cornerRaidus)
        }
    }

    func dismissAction() {
        viewModel.isDisplayed = false
    }
}
