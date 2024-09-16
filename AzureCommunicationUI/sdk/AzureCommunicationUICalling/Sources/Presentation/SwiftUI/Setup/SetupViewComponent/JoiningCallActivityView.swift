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
            /* <CUSTOM_COLOR_FEATURE> */
                .color(UIColor(dynamicColor: StyleProvider.color.primaryColor.dynamicColor!))
            /* </CUSTOM_COLOR_FEATURE> */
            Text(viewModel.title)
                .font(Fonts.subhead.font)
            /* <CUSTOM_COLOR_FEATURE> */
                .foregroundColor(Color(StyleProvider.color.primaryColor))
            /* </CUSTOM_COLOR_FEATURE> */
            Spacer()
        }.frame(height: containerHeight)
    }

}
