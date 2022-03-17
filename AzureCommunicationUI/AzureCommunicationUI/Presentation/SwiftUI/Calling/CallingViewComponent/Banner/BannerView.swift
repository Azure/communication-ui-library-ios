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
                    .accessibility(sortPriority: 2)
                Spacer()
                dismissButton
                    .padding([.top, .trailing])
                    .accessibility(sortPriority: 1)
            }
            .background(Color(StyleProvider.color.backgroundColor))
            .accessibility(sortPriority: 1)
        } else {
            Spacer()
                .frame(height: 8)
        }
    }

    var dismissButton: some View {
        return IconButton(viewModel: viewModel.dismissButtonViewModel)
    }
}
