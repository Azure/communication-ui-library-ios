//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import SwiftUI
import FluentUI
import Combine

struct OverlayView: View {
    let viewModel: OverlayViewModelProtocol

    private let layoutSpacing: CGFloat = 24
    private let iconImageSize: CGFloat = 24
    private let horizontalPaddingSize: CGFloat = 16

    var body: some View {
        Color(StyleProvider.color.overlay)
            .overlay(
                VStack(spacing: layoutSpacing) {
                    Icon(name: .clock, size: iconImageSize)
                        .accessibility(hidden: true)
                    Text(viewModel.title)
                        .font(Fonts.headline.font)
                    if viewModel.subtitle != nil {
                        Text(viewModel.subtitle!)
                            .font(Fonts.subhead.font)
                            .multilineTextAlignment(.center)
                    }
                    if let actionButtonViewModel = viewModel.getActionButtonViewModel {
                        PrimaryButton(viewModel: actionButtonViewModel)
                    }
                }.padding(.horizontal, horizontalPaddingSize)
                    .accessibilityElement(children: .combine)
                    .accessibility(addTraits: .isHeader)
            )
    }
}
