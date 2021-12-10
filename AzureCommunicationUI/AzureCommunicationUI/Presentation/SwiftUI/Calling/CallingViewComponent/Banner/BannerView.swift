//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import SwiftUI

struct BannerView: View {
    @ObservedObject var viewModel: BannerViewModel

    var body: some View {
        if viewModel.isBannerDisplayed {
            HStack(alignment: .top) {
                BannerTextView(viewModel: viewModel.bannerTextViewModel)
                    .padding([.top, .leading, .bottom])
                Spacer()
                dismissButton
                    .padding([.top, .trailing])
            }
            .background(Color(StyleProvider.color.backgroundColor))
        } else {
            Spacer()
                .frame(height: 8)
        }
    }

    var dismissButton: some View {
        return IconButton(viewModel: viewModel.dismissButtonViewModel)
    }
}
