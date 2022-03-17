//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import SwiftUI
import FluentUI

struct JoiningCallActivityView: View {
    let viewModel: JoiningCallActivityViewModel
    let containerHeight: CGFloat = 52

    var body: some View {
        HStack {
            Spacer()
            ActivityIndicator(size: .small)
                .isAnimating(true)
            Text(viewModel.title)
                .font(Fonts.subhead.font)
                .foregroundColor(Color(StyleProvider.color.onSurfaceColor))
            Spacer()
        }.frame(height: containerHeight)
    }

}
