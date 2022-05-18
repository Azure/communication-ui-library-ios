//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import SwiftUI
import FluentUI

struct BannerTextView: View {
    @ObservedObject var viewModel: BannerTextViewModel

    var body: some View {
        Group {
            Text(viewModel.title).bold()
            + Text(" ")
            + Text(viewModel.body)
            + Text(" ")
            + Text(viewModel.linkDisplay).underline()
        }
        .font(Fonts.footnote.font)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(viewModel.accessibilityLabel))
        .accessibilityAddTraits(.isLink)
        .onTapGesture {
            if let url = URL(string: viewModel.link) {
                UIApplication.shared.open(url)
            }
        }
    }
}
