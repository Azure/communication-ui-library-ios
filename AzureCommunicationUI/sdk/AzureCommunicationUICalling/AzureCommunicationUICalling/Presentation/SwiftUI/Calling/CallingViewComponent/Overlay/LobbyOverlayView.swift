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
                ZStack(alignment: .bottom) {
                VStack(spacing: layoutSpacing) {
                    Spacer()
                    Icon(name: .clock, size: iconImageSize)
                        .accessibility(hidden: true)
                    Text(viewModel.title)
                        .font(Fonts.title2.font)
                    if let subtitle = viewModel.subtitle {
                        Text(subtitle)
                            .font(Fonts.subhead.font)
                            .multilineTextAlignment(.center)
                    }
                    if let actionButtonViewModel = viewModel.actionButtonViewModel {
                        PrimaryButton(viewModel: actionButtonViewModel)
                            .fixedSize()
                    }
                    Spacer()
                }
                    if let errorInfoViewModel = viewModel.errorInfoViewModel {
                        VStack {
                            Spacer()
                            ErrorInfoView(viewModel: errorInfoViewModel)
                                .padding([.bottom])
                        }
                    }
                }.padding(.horizontal, horizontalPaddingSize)
                    .accessibilityElement(children: .combine)
                    .accessibility(addTraits: .isHeader)
            )
    }
}
